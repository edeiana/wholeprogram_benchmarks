#!/bin/bash

function runBenchmark {
  # Get function args
  benchmarkArg="${1}" ;

  # Check if paths exists
  pathToBenchmark="${PWD_PATH}/benchmarks/${benchmarkArg}" ;
  if ! test -d ${pathToBenchmark} ; then
    echo "WARNING: ${pathToBenchmark} not found. Skipping..." ;
    return ;
  fi

  pathToBinaryPath="${pathToBenchmark}/path.txt" ;
  if ! test -f ${pathToBinaryPath} ; then
    echo "WARNING: ${pathToBinaryPath} not found. Skipping..." ;
    return ;
  fi

  pathToBinary=`cat ${pathToBinaryPath}` ;
  if ! test -d ${pathToBinary} ; then
    echo "WARNING: ${pathToBinary} not found. Skipping..." ;
    return ;
  fi

  currBinary="${pathToBenchmark}/${benchmarkArg}" ;
  if ! test -f ${currBinary} ; then
    echo "WARNING: ${currBinary} not found. Skipping..." ;
    return ;
  fi

  # Copy binary into benchmark suite
  cp ${currBinary} ${pathToBinary} ;
  echo "Executing ${pathToBinary}/${benchmarkArg}" ;

  # Go in the benchmark suite and run the binary
  pushd . &> /dev/null ;
  cd ${pathToBinary} ;

  runScript="./runme_${benchmarkArg}.sh" ;
  if ! test -f ${runScript} ; then
    echo "WARNING: ${runScript} not found. Going up one dir." ;
    cd ../ ;
    if ! test -f ${runScript} ; then
      echo "WARNING: ${runScript} not found. Skipping..." ;
      popd  &> /dev/null;
      return ;
    fi
  fi

  perfStatFile="${PWD_PATH}/benchmarks/${benchmarkArg}/${benchmarkArg}_large_output.txt" ;
  perf stat ${runScript} > ${perfStatFile} ;
  if [ "$?" != 0 ] ; then
    echo "ERROR: run of ${runScript} failed." ;
  fi

  # Print last line of perf stat output file
  echo `tail -n 1 ${perfStatFile}` ;
	echo "--------------------------------------------------------------------------------------" ;

  popd &> /dev/null ;
}

# Get benchmark suite dir
PWD_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/.." ;

# Get args
inputToIgnore="${1}" ;
benchmarkToRun="${2}" ;

# Get bitcode benchmark dir
benchmarksDir="${PWD_PATH}/benchmarks" ;
if ! test -d ${benchmarksDir} ; then
  echo "ERROR: ${benchmarksDir} not found. Run make setup." ;
  exit 1 ;
fi

# Run benchmark
if [ "${benchmarkToRun}" == "all" ]; then
	for benchmark in `ls ${benchmarksDir}`; do
		runBenchmark ${benchmark} ;
	done
else
	runBenchmark ${benchmarkToRun} ;
fi

echo "DONE" 
exit
