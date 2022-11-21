#!/bin/bash

function runBenchmark {
  benchmarkArg="${1}" ;
  inputArg="test" ;
  timeFile=`mktemp` ;

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
  stderrFile="${pathToBenchmark}/${benchmarkArg}_${inputArg}_stderr.txt" ;
  stdoutFile="${pathToBenchmark}/${benchmarkArg}_${inputArg}_stdout.txt" ;
  rm -f ${perfStatFile} ;
  rm -f ${stderrFile} ;
  rm -f ${stdoutFile} ;
  commandToRunSplit="memorytool-run ./${benchmarkArg}" ;
  touch ./run_args.txt ;
  echo "Running: ${commandToRunSplit} in ${PWD}" ;
  cmd="eval /usr/bin/time -f %e -o ${timeFile} ${commandToRunSplit}" ;
  ${cmd} 1> >(tee -a ${stdoutFile}) 2> >(tee -a ${stderrFile} >&2) > ${perfStatFile} ;
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

