param(
    [string]$SourceImagePath
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot

Push-Location $projectRoot
try {
    if ($SourceImagePath) {
        & "$PSScriptRoot\\sync_app_icon.ps1" -SourceImagePath $SourceImagePath
    } else {
        & "$PSScriptRoot\\sync_app_icon.ps1"
    }
    flutter run -d windows
} finally {
    Pop-Location
}
