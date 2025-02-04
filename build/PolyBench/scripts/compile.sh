#!/bin/bash

PARGS="-I utilities -DPOLYBENCH_TIME";

origDir=`pwd` ;

cd polybench-3.1 ;

suiteDir=`pwd` ;
for i in `cat utilities/benchmark_list`; do 
  echo "Compiling $i" ;
  pushd ./ ;

  benchDir=`dirname $i` ;
  benchDirName=`basename $benchDir` ;
  benchName=`basename $i` ;
  cd $benchDir ;

  # Clean
  rm -f *.bc *.ll *.o ;

  # Generate the bitcode files
  clang -O0 -Xclang -disable-O0-optnone -I ${suiteDir}/utilities -I ./ ${suiteDir}/utilities/polybench.c $benchName -DLARGE_DATASET -emit-llvm -c
  if test $? -ne 0 ; then
    rm -f *.bc *.ll ;
    popd ;
    continue ;
  fi

  # Link them
  llvm-link *.bc -o all.bc ;

  # Copy the bitcode file
  mkdir -p ${origDir}/benchmarks/$benchDirName ;
  cp all.bc ${origDir}/benchmarks/$benchDirName/  ;

  popd ;
done
