param(
    [string]$InstallRoot = "$env:LOCALAPPDATA\Programs\CogniPlan"
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$payloadZip = Join-Path $scriptDir 'payload.zip'
$startMenuDir = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\CogniPlan'
$desktopShortcut = Join-Path ([Environment]::GetFolderPath('Desktop')) 'CogniPlan.lnk'
$startMenuShortcut = Join-Path $startMenuDir 'CogniPlan.lnk'

if (-not (Test-Path $payloadZip)) {
    throw "Installer payload not found: $payloadZip"
}

if (Test-Path $InstallRoot) {
    Remove-Item -LiteralPath $InstallRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $InstallRoot | Out-Null
Expand-Archive -Path $payloadZip -DestinationPath $InstallRoot -Force

New-Item -ItemType Directory -Force -Path $startMenuDir | Out-Null
$wsh = New-Object -ComObject WScript.Shell
foreach ($shortcutPath in @($desktopShortcut, $startMenuShortcut)) {
    $shortcut = $wsh.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = (Join-Path $InstallRoot 'cogniplan.exe')
    $shortcut.WorkingDirectory = $InstallRoot
    $shortcut.IconLocation = (Join-Path $InstallRoot 'cogniplan.exe')
    $shortcut.Save()
}

Start-Process -FilePath (Join-Path $InstallRoot 'cogniplan.exe')
