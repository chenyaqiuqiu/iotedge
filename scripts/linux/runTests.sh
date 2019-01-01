#!/bin/bash

# This script runs all the .Net Core test projects (*test*.csproj) in the
# repo by recursing from the repo root.
# This script expects that .Net Core is installed at
# $AGENT_WORKFOLDER/dotnet and output binaries are at $BUILD_BINARIESDIRECTORY

# Get directory of running script
DIR=$(cd "$(dirname "$0")" && pwd)

# Check if Environment variables are set.
BUILD_REPOSITORY_LOCALPATH=${BUILD_REPOSITORY_LOCALPATH:-$DIR/../..}
AGENT_WORKFOLDER=${AGENT_WORKFOLDER:-/usr/share}
BUILD_BINARIESDIRECTORY=${BUILD_BINARIESDIRECTORY:-$BUILD_REPOSITORY_LOCALPATH/target}

# Process script arguments
TEST_FILTER="$1"

SUFFIX='Microsoft.Azure*test.csproj'
ROOTFOLDER=$BUILD_REPOSITORY_LOCALPATH
IOTEDGECTL_DIR=$ROOTFOLDER/edge-bootstrap/python
DOTNET_ROOT_PATH=$AGENT_WORKFOLDER/dotnet
OUTPUT_FOLDER=$BUILD_BINARIESDIRECTORY
ENVIRONMENT=${TESTENVIRONMENT:="linux"}

if [ ! -d "$ROOTFOLDER" ]; then
  echo "Folder $ROOTFOLDER does not exist" 1>&2
  exit 1
fi

if [ ! -f "$DOTNET_ROOT_PATH/dotnet" ]; then
  echo "Path $DOTNET_ROOT_PATH/dotnet does not exist" 1>&2
  exit 1
fi

if [ ! -d "$BUILD_BINARIESDIRECTORY" ]; then
  echo "Path $BUILD_BINARIESDIRECTORY does not exist" 1>&2
  exit 1
fi

testFilterValue="${TEST_FILTER#--filter }"
echo "Running tests in all test projects with filter: $testFilterValue"

RES=0

# Find all test project dlls
testProjectDlls = ""
while read proj; do
  fileParentDirectory="$(dirname -- "$proj")"
  fileName="$(basename -- "$proj")"
  fileBaseName="${fileName%.*}"
  
  currentTestProjectDll="$fileParentDirectory/bin/Release/netcoreapp2.1/$fileBaseName.dll"
  echo "Found test project:$currentTestProjectDll"
  testProjectDlls="$testProjectDlls $currentTestProjectDll"
done < <(find $ROOTFOLDER -type f -iname $SUFFIX)

echo "test project dlls:$testProjectDlls"

if [ -z "$testFilterValue" ]
then
      dotnet vstest $testProjectDlls /Logger:"trx" /TestAdapterPath:"$BUILD_REPOSITORY_LOCALPATH" /Parallel
else
      dotnet vstest $testProjectDlls /TestCaseFilter:"$testFilterValue" /Logger:"trx" /TestAdapterPath:"$BUILD_REPOSITORY_LOCALPATH" /Parallel
fi

if [ $? -gt 0 ]
then
  RES=1
fi

echo "Edge runtime tests result RES = $RES"

exit $RES
