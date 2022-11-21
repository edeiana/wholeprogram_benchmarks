#!/bin/bash

function runBenchmark {
  # Get function args
  inputArg="${1}" ;
  benchmarkArg="${2}" ;
  timeFile=`mktemp` ;

  # Check if paths exists
  pathToBenchmark="${benchmarksDir}/${benchmarkArg}" ;
  if ! test -d ${pathToBenchmark} ; then
    echo "ERROR: ${pathToBenchmark} not found. Skipping..." ;
    exit 1 ;
  fi

  pathToBinaryPath="${pathToBenchmark}/path.txt" ;
  if ! test -f ${pathToBinaryPath} ; then
    echo "ERROR: ${pathToBinaryPath} not found. Skipping..." ;
    exit 1 ;
  fi

  pathToBinary=`cat ${pathToBinaryPath}` ;
  if ! test -d ${pathToBinary} ; then
    echo "ERROR: ${pathToBinary} not found. Skipping..." ;
    exit 1 ;
  fi

  currBinary="${pathToBenchmark}/${benchmarkArg}" ;
  if ! test -f ${currBinary} ; then
    echo "ERROR: ${currBinary} not found. Skipping..." ;
    exit 1 ;
  fi

  pathToInputConf="${pathToBinary}/../../../parsec/${inputArg}.runconf" ;
  if ! test -f ${pathToInputConf} ; then
    echo "ERROR: ${pathToInputConf} not found. Skipping..." ;
    exit 1 ;
  fi

  # Go in the benchmark dir
  cd ${pathToBenchmark} ;

  # Extract inputs in run dir if the input archive exists
  pathToBenchmarkInput="${pathToBinary}/../../../inputs/input_${inputArg}.tar" ;
  if test -f ${pathToBenchmarkInput} ; then
    tar xf ${pathToBenchmarkInput} ;
  fi

  # Get args to run binary with
  nthreads="`grep -c ^processor /proc/cpuinfo`";
  NTHREADS=${nthreads} source ${pathToInputConf} ;

  # Run benchmark in benchmarks/${benchmark}/run dir
  perfStatFile="${pathToBenchmark}/${benchmarkArg}_${inputArg}_output.txt" ;
  commandToRunSplit="./${benchmarkArg} ${run_args}" ;
  echo "Running: ${commandToRunSplit} in ${PWD}" ;
  eval /usr/bin/time -f %e -o ${timeFile} ${commandToRunSplit} > ${perfStatFile} ;
  if [ "$?" != 0 ] ; then
    echo "ERROR: run of ${commandToRunSplit} failed." ;
    exit 1 ;
  fi

  # Print last line of perf stat output file
  echo `tail -n 1 ${perfStatFile}` ;
	echo "--------------------------------------------------------------------------------------" ;

  echo `tail -n 1 ${timeFile}` ;
  rm ${timeFile} ;

  return ;
}

# Get benchmark suite dir
PWD_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/.." ;

# Get args
inputToRun="${1}" ;
benchmarkToRun="${2}" ;

# Get benchmark dir
benchmarksDir="${PWD_PATH}/benchmarks" ;
if ! test -d ${benchmarksDir} ; then
  echo "ERROR: ${benchmarksDir} not found. Run make bitcode_copy." ;
  exit 1 ;
fi

# Run benchmark
if [ "${benchmarkToRun}" == "all" ]; then
	for benchmark in `ls ${benchmarksDir}`; do
    runBenchmark ${inputToRun} ${benchmark} ;
	done
else
  runBenchmark ${inputToRun} ${benchmarkToRun} ;
fi

exit
