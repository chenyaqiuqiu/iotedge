<#
 # Runs all .NET Core test projects in the repo
 #>

param (
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-Path $_ -PathType Container})]
    [String] $AgentWorkFolder = $Env:AGENT_WORKFOLDER,

    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-Path $_ -PathType Container})]
    [String] $BuildRepositoryLocalPath = $Env:BUILD_REPOSITORY_LOCALPATH,
    
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-Path $_ -PathType Container})]
    [String] $BuildBinariesDirectory = $Env:BUILD_BINARIESDIRECTORY,

    [ValidateNotNullOrEmpty()]
    [String] $Filter
)

Set-StrictMode -Version "Latest"
$ErrorActionPreference = "Stop"

<#
 # Prepare environment
 #>

Import-Module ([IO.Path]::Combine($PSScriptRoot, "..", "Defaults.psm1")) -Force

if (-not $AgentWorkFolder) {
    $AgentWorkFolder = DefaultAgentWorkFolder
}

if (-not $BuildRepositoryLocalPath) {
    $BuildRepositoryLocalPath = DefaultBuildRepositoryLocalPath
}

if (-not $BuildBinariesDirectory) {
    $BuildBinariesDirectory = DefaultBuildBinariesDirectory $BuildRepositoryLocalPath
}

$TEST_PROJ_PATTERN = "Microsoft.Azure*test.csproj"
$LOGGER_ARG = "trx;LogFileName=result.trx"

$DOTNET_PATH = [IO.Path]::Combine($AgentWorkFolder, "dotnet", "dotnet.exe")

if (-not (Test-Path $DOTNET_PATH -PathType Leaf)) {
    throw "$DOTNET_PATH not found."
}

<#
 # Run tests
 #>

$BaseTestCommand = if ($Filter) {
    "test --no-build --logger `"$LOGGER_ARG`" --filter `"$Filter`"" 
}
else {
    "test --no-build --logger `"$LOGGER_ARG`""
}

Write-Host "Running tests in all test projects with filter '$Filter'."
$Success = $True

<#
foreach ($Project in (Get-ChildItem $BuildRepositoryLocalPath -Include $TEST_PROJ_PATTERN -Recurse)) {
    Write-Host "Running tests for $Project."
	Write-Host "Run command: '" + $DOTNET_PATH + "' " + $BaseTestCommand " -o " + $BuildBinariesDirectory + " " + $Project
    Invoke-Expression "&`"$DOTNET_PATH`" $BaseTestCommand -o $BuildBinariesDirectory $Project"

    $Success = $Success -and $LASTEXITCODE -eq 0
}


if (-not $Success) {
    throw "Failed tests."
}
#>

dotnet vstest "$BuildRepositoryLocalPath\edge-agent\test\Microsoft.Azure.Devices.Edge.Agent.Core.Test\bin\Release\netcoreapp2.1\Microsoft.Azure.Devices.Edge.Agent.Core.Test.dll" "$BuildRepositoryLocalPath\edge-agent\test\Microsoft.Azure.Devices.Edge.Agent.Docker.E2E.Test\bin\Release\netcoreapp2.1\Microsoft.Azure.Devices.Edge.Agent.Docker.E2E.Test.dll" "$BuildRepositoryLocalPath\edge-agent\test\Microsoft.Azure.Devices.Edge.Agent.Docker.Test\bin\Release\netcoreapp2.1\Microsoft.Azure.Devices.Edge.Agent.Docker.Test.dll" "$BuildRepositoryLocalPath\edge-agent\test\Microsoft.Azure.Devices.Edge.Agent.Edgelet.Docker.Test\bin\Release\netcoreapp2.1\Microsoft.Azure.Devices.Edge.Agent.Edgelet.Docker.Test.dll" "$BuildRepositoryLocalPath\edge-agent\test\Microsoft.Azure.Devices.Edge.Agent.Edgelet.Test\bin\Release\netcoreapp2.1\Microsoft.Azure.Devices.Edge.Agent.Edgelet.Test.dll" "$BuildRepositoryLocalPath\edge-agent\test\Microsoft.Azure.Devices.Edge.Agent.IoTHub.Test\bin\Release\netcoreapp2.1\Microsoft.Azure.Devices.Edge.Agent.IoTHub.Test.dll" "$BuildRepositoryLocalPath\edge-hub\test\Microsoft.Azure.Devices.Edge.Hub.Amqp.Test\bin\Release\netcoreapp2.1\Microsoft.Azure.Devices.Edge.Hub.Amqp.Test.dll" "$BuildRepositoryLocalPath\edge-hub\test\Microsoft.Azure.Devices.Edge.Hub.CloudProxy.Test\bin\Release\netcoreapp2.1\Microsoft.Azure.Devices.Edge.Hub.CloudProxy.Test.dll" "$BuildRepositoryLocalPath\edge-hub\test\Microsoft.Azure.Devices.Edge.Hub.Core.Test\bin\Release\netcoreapp2.1\Microsoft.Azure.Devices.Edge.Hub.Core.Test.dll" "$BuildRepositoryLocalPath\edge-hub\test\Microsoft.Azure.Devices.Edge.Hub.E2E.Test\bin\Release\netcoreapp2.1\Microsoft.Azure.Devices.Edge.Hub.E2E.Test.dll" "$BuildRepositoryLocalPath\edge-hub\test\Microsoft.Azure.Devices.Edge.Hub.Http.Test\bin\Release\netcoreapp2.1\Microsoft.Azure.Devices.Edge.Hub.Http.Test.dll" "$BuildRepositoryLocalPath\edge-hub\test\Microsoft.Azure.Devices.Edge.Hub.Mqtt.Test\bin\Release\netcoreapp2.1\Microsoft.Azure.Devices.Edge.Hub.Mqtt.Test.dll" "$BuildRepositoryLocalPath\edge-hub\test\Microsoft.Azure.Devices.Edge.Hub.Service.Test\bin\Release\netcoreapp2.1\Microsoft.Azure.Devices.Edge.Hub.Service.Test.dll" "$BuildRepositoryLocalPath\edge-hub\test\Microsoft.Azure.Devices.Routing.Core.Test\bin\Release\netcoreapp2.1\Microsoft.Azure.Devices.Routing.Core.Test.dll" "$BuildRepositoryLocalPath\edge-util\test\Microsoft.Azure.Devices.Edge.Storage.RocksDb.Test\bin\Release\netcoreapp2.1\Microsoft.Azure.Devices.Edge.Storage.RocksDb.Test.dll" "$BuildRepositoryLocalPath\edge-util\test\Microsoft.Azure.Devices.Edge.Storage.Test\bin\Release\netcoreapp2.1\Microsoft.Azure.Devices.Edge.Storage.Test.dll" "$BuildRepositoryLocalPath\edge-util\test\Microsoft.Azure.Devices.Edge.Util.Test\bin\Release\netcoreapp2.1\Microsoft.Azure.Devices.Edge.Util.Test.dll" /TestCaseFilter:"Category=Integration&Category!=Stress" /Logger:"trx" /TestAdapterPath:"$BuildRepositoryLocalPath" /Parallel

Write-Host "Done!"