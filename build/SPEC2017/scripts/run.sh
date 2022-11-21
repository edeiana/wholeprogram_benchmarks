#!/bin/bash


function runBenchmark {
  timeFile=`mktemp` ;

	if [ ! -d "${BENCHMARKS_DIR}/${1}/${inputsize}" ]; then
		echo "Error: Run directory not found for \"${1}\". Please run \"./scripts/setup.sh ${inputsize} version\" where version = [rate, speed]"
		exit
	fi
	if [ ! -f "${BENCHMARKS_DIR}/${1}/${1}" ]; then
		echo "Warning: Binary \"${1}\" not found for \"${1}\", Skipping "
		return
	fi
	cd ${BENCHMARKS_DIR}/${1} ;
	lastline="`tail -n 1 ${BENCHMARKS_DIR}/${1}/run_${inputsize}.sh`"
	arguments="$( echo $lastline | awk -F${1} '{print $2}')"
	echo "Running \"${1}\" with \"${1} ${arguments} >${1}_${inputsize}_output.txt\""

  benchmarkArg="${1}" ;
  pathToBenchmark=${BENCHMARKS_DIR}/${benchmarkArg};
  perfStatFile="${pathToBenchmark}/${benchmarkArg}_${inputsize}_output.txt"
  stderrFile="${pathToBenchmark}/${benchmarkArg}_${inputsize}_stderr.txt" ;
  stdoutFile="${pathToBenchmark}/${benchmarkArg}_${inputsize}_stdout.txt" ;
  rm -f ${perfStatFile} ;
  rm -f ${stderrFile} ;
  rm -f ${stdoutFile} ;
  cmdToRunSplit="memorytool-run ./$1 ${arguments}" ;
  cmd="eval /usr/bin/time -f %e -o ${timeFile} ${cmdToRunSplit}" ;
  ${cmd} 1> >(tee -a ${stdoutFile}) 2> >(tee -a ${stderrFile} >&2) > ${perfStatFile} ;

  exitOutput=$? ;
  echo `tail -n 1 ${perfStatFile}` ;
	echo "--------------------------------------------------------------------------------------"
  
  echo `tail -n 1 ${timeFile}` ;
  rm ${timeFile} ;
}



# Set local variables
BUILD_DIR=`pwd`

# Check the inputs
if [ ! "${1}" == "test" ] && [ ! "${1}" == "train" ] && [ ! "${1}" == "ref" ]; then
	echo "Please provide input configuration [test,train,refspeed] for setting up run directories. For Example: \"./scripts/run.sh ref all\""
	exit
fi

if [ ! "${2}" ];  then
  echo "Error: Please provide benchmark name or 'all' for running benchmark. For Example: \"./scripts/run.sh ref mcf_r\""
  exit
fi

# Check the state
if [ ! -d "${BUILD_DIR}/SPEC2017" ]; then
	echo "Please run ./rebuild.sh first to install SPEC2017 and build benchmarks. Then run ./setupRun.sh to extract bitcodes before running this script."
	exit
fi
if [ ! -d "${BUILD_DIR}/benchmarks" ]; then
	echo "Please run ./scripts/setupRun.sh first to build benchmarks and extract bitcodes."
	exit
fi


if [ "${1}" == "ref" ] && [ "${2: -2}" == "_r" ]; then
	inputsize="refrate"
elif [ "${1}" == "ref" ] && [ "${2: -2}" == "_s" ]; then
	inputsize="refspeed"
else
	inputsize=${1}
fi


# Set local variables
if [ "${2}" == "rate" ]; then
	key="_r"
elif [ "${2}" == "speed" ]; then
	key="_s"
else
	key=""
fi

# Run generated binaries with specified workloads
BENCHMARKS_DIR=${BUILD_DIR}/benchmarks
if [ "${2}" == "all" ]; then

	for benchmark in `ls ${BENCHMARKS_DIR}`; do
		runBenchmark ${benchmark} ;
	done

else
	runBenchmark ${2} ;
fi


exit $exitOutput 
