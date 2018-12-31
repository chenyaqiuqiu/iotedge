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

echo "Running tests in all test projects with filter: ${TEST_FILTER#--filter }"

RES=0
#while read proj; do
#  echo "Running tests for project - $proj"
#  TESTENVIRONMENT=$ENVIRONMENT $DOTNET_ROOT_PATH/dotnet test \
#    $TEST_FILTER \
#    -p:ParallelizeTestCollections=false \
#    --no-build \
#    -v d \
#    --logger "trx;LogFileName=result.trx" \
#    -o "$OUTPUT_FOLDER" \
#    $proj
#  if [ $? -gt 0 ]
#  then
#    RES=1
#    echo "Error running test $proj, RES = $RES"
#  fi
#done < <(find $ROOTFOLDER -type f -iname $SUFFIX)

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

# dotnet vstest "$BUILD_REPOSITORY_LOCALPATH/edge-agent/test/Microsoft.Azure.Devices.Edge.Agent.Core.Test/bin/Release/netcoreapp2.1/Microsoft.Azure.Devices.Edge.Agent.Core.Test.dll" "$BUILD_REPOSITORY_LOCALPATH/edge-agent/test/Microsoft.Azure.Devices.Edge.Agent.Docker.E2E.Test/bin/Release/netcoreapp2.1/Microsoft.Azure.Devices.Edge.Agent.Docker.E2E.Test.dll" "$BUILD_REPOSITORY_LOCALPATH/edge-agent/test/Microsoft.Azure.Devices.Edge.Agent.Docker.Test/bin/Release/netcoreapp2.1/Microsoft.Azure.Devices.Edge.Agent.Docker.Test.dll" "$BUILD_REPOSITORY_LOCALPATH/edge-agent/test/Microsoft.Azure.Devices.Edge.Agent.Edgelet.Docker.Test/bin/Release/netcoreapp2.1/Microsoft.Azure.Devices.Edge.Agent.Edgelet.Docker.Test.dll" "$BUILD_REPOSITORY_LOCALPATH/edge-agent/test/Microsoft.Azure.Devices.Edge.Agent.Edgelet.Test/bin/Release/netcoreapp2.1/Microsoft.Azure.Devices.Edge.Agent.Edgelet.Test.dll" "$BUILD_REPOSITORY_LOCALPATH/edge-agent/test/Microsoft.Azure.Devices.Edge.Agent.IoTHub.Test/bin/Release/netcoreapp2.1/Microsoft.Azure.Devices.Edge.Agent.IoTHub.Test.dll" "$BUILD_REPOSITORY_LOCALPATH/edge-hub/test/Microsoft.Azure.Devices.Edge.Hub.Amqp.Test/bin/Release/netcoreapp2.1/Microsoft.Azure.Devices.Edge.Hub.Amqp.Test.dll" "$BUILD_REPOSITORY_LOCALPATH/edge-hub/test/Microsoft.Azure.Devices.Edge.Hub.CloudProxy.Test/bin/Release/netcoreapp2.1/Microsoft.Azure.Devices.Edge.Hub.CloudProxy.Test.dll" "$BUILD_REPOSITORY_LOCALPATH/edge-hub/test/Microsoft.Azure.Devices.Edge.Hub.Core.Test/bin/Release/netcoreapp2.1/Microsoft.Azure.Devices.Edge.Hub.Core.Test.dll" "$BUILD_REPOSITORY_LOCALPATH/edge-hub/test/Microsoft.Azure.Devices.Edge.Hub.E2E.Test/bin/Release/netcoreapp2.1/Microsoft.Azure.Devices.Edge.Hub.E2E.Test.dll" "$BUILD_REPOSITORY_LOCALPATH/edge-hub/test/Microsoft.Azure.Devices.Edge.Hub.Http.Test/bin/Release/netcoreapp2.1/Microsoft.Azure.Devices.Edge.Hub.Http.Test.dll" "$BUILD_REPOSITORY_LOCALPATH/edge-hub/test/Microsoft.Azure.Devices.Edge.Hub.Mqtt.Test/bin/Release/netcoreapp2.1/Microsoft.Azure.Devices.Edge.Hub.Mqtt.Test.dll" "$BUILD_REPOSITORY_LOCALPATH/edge-hub/test/Microsoft.Azure.Devices.Edge.Hub.Service.Test/bin/Release/netcoreapp2.1/Microsoft.Azure.Devices.Edge.Hub.Service.Test.dll" "$BUILD_REPOSITORY_LOCALPATH/edge-hub/test/Microsoft.Azure.Devices.Routing.Core.Test/bin/Release/netcoreapp2.1/Microsoft.Azure.Devices.Routing.Core.Test.dll" "$BUILD_REPOSITORY_LOCALPATH/edge-util/test/Microsoft.Azure.Devices.Edge.Storage.RocksDb.Test/bin/Release/netcoreapp2.1/Microsoft.Azure.Devices.Edge.Storage.RocksDb.Test.dll" "$BUILD_REPOSITORY_LOCALPATH/edge-util/test/Microsoft.Azure.Devices.Edge.Storage.Test/bin/Release/netcoreapp2.1/Microsoft.Azure.Devices.Edge.Storage.Test.dll" "$BUILD_REPOSITORY_LOCALPATH/edge-util/test/Microsoft.Azure.Devices.Edge.Util.Test/bin/Release/netcoreapp2.1/Microsoft.Azure.Devices.Edge.Util.Test.dll" /TestCaseFilter:"Category=Integration&Category!=Stress" /Logger:"trx" /TestAdapterPath:"$BUILD_REPOSITORY_LOCALPATH" /Parallel

dotnet vstest $testProjectDlls /TestCaseFilter:"Category=Integration&Category!=Stress" /Logger:"trx" /TestAdapterPath:"$BUILD_REPOSITORY_LOCALPATH" /Parallel

if [ $? -gt 0 ]
then
  RES=1
fi

echo "Edge runtime tests result RES = $RES"

exit $RES
