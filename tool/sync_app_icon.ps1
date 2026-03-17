param(
    [string]$SourceImagePath
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$preparedIconSource = Join-Path $projectRoot "assets\\branding\\app_icon_source.png"
$windowsIcon = Join-Path $projectRoot "windows\\runner\\resources\\app_icon.ico"
$androidIcon = Join-Path $projectRoot "android\\app\\src\\main\\res\\mipmap-xxxhdpi\\ic_launcher.png"
$prepareScript = Join-Path $PSScriptRoot "prepare_app_icon.py"

if ($SourceImagePath) {
    if (-not (Test-Path $SourceImagePath)) {
        Write-Host "Provided source image not found: $SourceImagePath"
        exit 1
    }

    Write-Host "Preparing square icon source from $SourceImagePath ..."
    python $prepareScript $SourceImagePath $preparedIconSource
}

if (-not (Test-Path $preparedIconSource)) {
    Write-Host "App icon source not found: $preparedIconSource"
    Write-Host "Either place the processed image there or pass -SourceImagePath to this script."
    exit 1
}

$needsUpdate = $true
if ((Test-Path $windowsIcon) -and (Test-Path $androidIcon)) {
    $sourceTime = (Get-Item $preparedIconSource).LastWriteTimeUtc
    $windowsTime = (Get-Item $windowsIcon).LastWriteTimeUtc
    $androidTime = (Get-Item $androidIcon).LastWriteTimeUtc
    $needsUpdate = $sourceTime -gt $windowsTime -or $sourceTime -gt $androidTime
}

if (-not $needsUpdate) {
    Write-Host "App icons are already up to date."
    exit 0
}

Write-Host "Generating launcher icons from $preparedIconSource ..."
Push-Location $projectRoot
try {
    dart run flutter_launcher_icons
} finally {
    Pop-Location
}
