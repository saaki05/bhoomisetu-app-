param(
  [string]$OutputArchive = '..\BhoomiSetu-web-release.zip'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$appDirectory = Split-Path -Parent $PSScriptRoot
$buildDirectory = Join-Path $appDirectory 'build\web'
$versionedEntrypoint = 'main.bhoomisetu.20260805.js'

Push-Location $appDirectory
try {
  flutter build web --release --pwa-strategy=none
  Copy-Item -LiteralPath (Join-Path $buildDirectory 'main.dart.js') `
    -Destination (Join-Path $buildDirectory $versionedEntrypoint) -Force

  $resolvedArchive = [IO.Path]::GetFullPath((Join-Path $appDirectory $OutputArchive))
  if ([IO.Path]::GetExtension($resolvedArchive) -ne '.zip') {
    throw 'OutputArchive must point to a .zip file.'
  }
  if (Test-Path -LiteralPath $resolvedArchive -PathType Container) {
    throw "OutputArchive resolves to a directory: $resolvedArchive"
  }
  if (Test-Path -LiteralPath $resolvedArchive) {
    Remove-Item -LiteralPath $resolvedArchive -Force
  }

  tar.exe -a -c -f $resolvedArchive -C $buildDirectory .
  if ($LASTEXITCODE -ne 0) {
    throw "Unable to create web release archive at $resolvedArchive"
  }

  Write-Output $resolvedArchive
}
finally {
  Pop-Location
}
