#!/bin/sh

# This scrips starts the Azure Edge service

# generate SSL self signed certificate
./scripts/generate-cert.sh

# start service
exec dotnet Microsoft.Azure.Devices.Edge.Service.dll