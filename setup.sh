#!/bin/bash -e

# Check the inputs
numOfInputs=1 ;
if test $# -lt ${numOfInputs} ; then
 echo "USAGE: source `basename $0` /absolute/path/to/memorytool/root" ;
 return ;
fi

# Export memory tool repo root
export MEMORYTOOL_ROOT=${1} ;

# Add memorytool utils to path
export PATH=${MEMORYTOOL_ROOT}/utils:${PATH} ;
export PATH=${MEMORYTOOL_ROOT}/utils/prettyPrint:${PATH} ;

# Add NOELLE
export PATH=${MEMORYTOOL_ROOT}/tools/noelle/install/bin:${PATH} ;

# Add pin
source ${MEMORYTOOL_ROOT}/extra/pin/3.13/enable ;
export PIN_ROOT="${MEMORYTOOL_ROOT}/extra/pin/3.13/download" ;
