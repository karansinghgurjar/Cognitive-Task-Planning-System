param(
    [string]$Version = '1.2.0+12'
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$releaseDir = Join-Path $repoRoot 'build\windows\x64\runner\Release'
$installerDir = Join-Path $repoRoot 'build\windows_installer'
$payloadDir = Join-Path $installerDir 'payload'
$payloadZip = Join-Path $installerDir 'payload.zip'
$sedPath = Join-Path $installerDir 'cogniplan_installer.sed'
$outputExe = Join-Path $installerDir ("CogniPlan-Setup-$Version.exe")
$installPs1 = Join-Path $PSScriptRoot 'install_cogniplan.ps1'
$installCmd = Join-Path $PSScriptRoot 'install_cogniplan.cmd'

if (-not (Test-Path (Join-Path $releaseDir 'cogniplan.exe'))) {
    throw "Windows release build not found at $releaseDir"
}

New-Item -ItemType Directory -Force -Path $installerDir | Out-Null
if (Test-Path $payloadDir) { Remove-Item -LiteralPath $payloadDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $payloadDir | Out-Null
Copy-Item -Path (Join-Path $releaseDir '*') -Destination $payloadDir -Recurse -Force
if (Test-Path $payloadZip) { Remove-Item -LiteralPath $payloadZip -Force }
Compress-Archive -Path (Join-Path $payloadDir '*') -DestinationPath $payloadZip -Force
if (Test-Path $outputExe) { Remove-Item -LiteralPath $outputExe -Force }

$sed = @"
[Version]
Class=IEXPRESS
SEDVersion=3
[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=1
HideExtractAnimation=0
UseLongFileName=1
InsideCompressed=0
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=
DisplayLicense=
FinishMessage=CogniPlan has been installed successfully.
TargetName=$outputExe
FriendlyName=CogniPlan Installer
AppLaunched=install_cogniplan.cmd
PostInstallCmd=<None>
AdminQuietInstCmd=
UserQuietInstCmd=
SourceFiles=SourceFiles
SelfDelete=0
FILE0=payload.zip
FILE1=install_cogniplan.cmd
FILE2=install_cogniplan.ps1
[Strings]
FILE0=payload.zip
FILE1=install_cogniplan.cmd
FILE2=install_cogniplan.ps1
[SourceFiles]
SourceFiles0=$installerDir
SourceFiles1=$PSScriptRoot
[SourceFiles0]
%FILE0%=
[SourceFiles1]
%FILE1%=
%FILE2%=
"@
Set-Content -Path $sedPath -Value $sed
& 'C:\Windows\System32\iexpress.exe' /N $sedPath | Out-Null
if (-not (Test-Path $outputExe)) {
    throw "Installer was not created at $outputExe"
}
Write-Output $outputExe
