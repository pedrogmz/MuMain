param (
    [switch]$RebuildAssets
)

$ErrorActionPreference = "Stop"

$repoRoot = $PSScriptRoot
# The proxy repo lives next to this checkout; it was renamed from
# openmu-browser-stack to open-mu-browser-proxy, so accept either name.
$workspace = Split-Path $PSScriptRoot -Parent
$stackPublic = @("open-mu-browser-proxy", "openmu-browser-stack") |
    ForEach-Object { Join-Path $workspace "$_\public" } |
    Where-Object { Test-Path $_ } |
    Select-Object -First 1
if (-not $stackPublic) { $stackPublic = Join-Path $workspace "open-mu-browser-proxy\public" }

$env:PATH = "C:\Users\Poisson\.local\dotnet;C:\Users\Poisson\.local\cmake-3.31.5-windows-x86_64\bin;C:\Users\Poisson\.local\bin;C:\Users\Poisson\emsdk;C:\Users\Poisson\emsdk\upstream\emscripten;C:\Users\Poisson\emsdk\node\24.19.0_64bit\bin;C:\Users\Poisson\emsdk\python\3.13.3_64bit;" + $env:PATH

Write-Host "=== Compiling MuMain to WebAssembly ===" -ForegroundColor Cyan
Set-Location $repoRoot

# out/build/wasm-web was configured against C:\Users\Poisson\Documents\MuMain, so an
# incremental ninja run only works while that path still resolves to this checkout
# (an NTFS junction was created for it). Re-run cmake into a fresh build directory to
# drop the dependency; that forces a full rebuild.
ninja -C out/build/wasm-web
if ($LASTEXITCODE -ne 0) {
    Write-Error "Compilation failed."
    exit $LASTEXITCODE
}

Write-Host "=== Compilation Successful ===" -ForegroundColor Green

# Main.data only carries the small, build-generated files (shaders and
# config.ini, well under 1 MB), so it is cheap to repack on every build.
# Data/ and fonts/ ship as content-addressed buckets built straight into the
# stack (see openmu-browser-stack/scripts/build-data-buckets.js): unchanged
# buckets are left untouched, so a rebuild only replaces what changed and
# browsers keep the rest cached. -RebuildAssets is kept for compatibility;
# both steps now always run.
Write-Host "=== Packaging Main.data (shaders, config.ini) ===" -ForegroundColor Cyan
python C:\Users\Poisson\emsdk\upstream\emscripten\tools\file_packager.py out\build\wasm-web\src\Main.data `
  --preload "out\build\wasm-web\shaders@shaders" `
  --preload "out\build\wasm-web\src\config.ini@config.ini" `
  --js-output=out\build\wasm-web\src\Main.data.js
if ($LASTEXITCODE -ne 0) {
    Write-Error "file_packager failed."
    exit $LASTEXITCODE
}

Write-Host "=== Deploying to $stackPublic ===" -ForegroundColor Cyan
if (Test-Path $stackPublic) {
    Write-Host "=== Packaging data buckets (Data, fonts) ===" -ForegroundColor Cyan
    $bucketScript = Join-Path (Split-Path $stackPublic -Parent) "scripts\build-data-buckets.js"
    node $bucketScript --out "$stackPublic\assets" `
      --add "src\bin\Data@/Data" `
      --add "src\bin\fonts@/fonts"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Data bucket build failed."
        exit $LASTEXITCODE
    }

    Copy-Item "out\build\wasm-web\src\Main.wasm" "$stackPublic\Main.wasm" -Force
    Copy-Item "out\build\wasm-web\src\Main.js" "$stackPublic\Main.js" -Force
    Copy-Item "out\build\wasm-web\src\Main.data.js" "$stackPublic\Main.data.js" -Force
    Copy-Item "out\build\wasm-web\src\Main.data" "$stackPublic\Main.data" -Force
    Write-Host "Deployed successfully to $stackPublic" -ForegroundColor Green
} else {
    Write-Warning "Stack public directory not found at $stackPublic"
}
