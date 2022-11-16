#!/bin/bash

function runBenchmark {
  benchmarkArg="${1}" ;
  inputArg="test" ;

  # Check if paths exists
  pathToBenchmark="${benchmarksDir}/${1}" ;
  if ! test -d ${pathToBenchmark} ; then
    echo "ERROR: ${pathToBenchmark} not found. Skipping..." ;
    exit 1 ;
  fi

  # Go in the benchmark dir
  cd ${pathToBenchmark} ;

  # Run benchmark in benchmarks/${benchmark}/run dir
  perfStatFile="${pathToBenchmark}/${benchmarkArg}_${inputArg}_output.txt" ;
  commandToRunSplit="./${benchmarkArg}" ;
  echo "Running: ${commandToRunSplit} in ${PWD}" ;
  touch ./run_args.txt ;
  eval perf stat ${commandToRunSplit} > ${perfStatFile} ;
  if [ "$?" != 0 ] ; then
    echo "ERROR: run of ${commandToRunSplit} failed." ;
    exit 1 ;
  fi

  # Print last line of perf stat output file
  echo `tail -n 1 ${perfStatFile}` ;
        echo "--------------------------------------------------------------------------------------" ;

  return ;

}


# Get benchmark suite dir
PWD_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/.." ;

# Get args
inputToRun="${2}" ;
benchmarkToRun="${1}" ;

# Get benchmark dir
benchmarksDir="${PWD_PATH}/benchmarks" ;
if ! test -d ${benchmarksDir} ; then
  echo "ERROR: ${benchmarksDir} not found. Run make bitcode_copy." ;
  exit 1 ;
fi
echo "${inputToRun} ${benchmarkToRun}"
# Run benchmark
if [ "${benchmarkToRun}" == "all" ]; then
  for benchmark in `ls ${benchmarksDir}` ; do
    runBenchmark ${benchmark} ;
  done
else
  runBenchmark ${benchmarkToRun};
fi

