param (
    [switch]$RebuildAssets
)

$ErrorActionPreference = "Stop"

$repoRoot = $PSScriptRoot
$stackPublic = Join-Path (Split-Path $PSScriptRoot -Parent) "openmu-browser-stack\public"

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

$mainData = "out\build\wasm-web\src\Main.data"
$shaderStage = "out\build\wasm-web\shaders"
$vfsNeedsRebuild = $RebuildAssets -or -not (Test-Path $mainData)
if (-not $vfsNeedsRebuild -and (Test-Path $shaderStage)) {
    # The VFS is preloaded once; deploy new or changed shader blobs without
    # forcing a full 700 MB repack on every build that did not touch them.
    $mainDataTime = (Get-Item $mainData).LastWriteTimeUtc
    $vfsNeedsRebuild = [bool](Get-ChildItem $shaderStage -File -Recurse |
        Where-Object { $_.LastWriteTimeUtc -gt $mainDataTime } |
        Select-Object -First 1)
}

if ($vfsNeedsRebuild) {
    Write-Host "=== Packaging VFS Assets (Data, fonts, shaders, config.ini) ===" -ForegroundColor Cyan
    python C:\Users\Poisson\emsdk\upstream\emscripten\tools\file_packager.py out\build\wasm-web\src\Main.data `
      --preload "out\build\wasm-web\shaders@shaders" `
      --preload "src\bin\fonts@fonts" `
      --preload "out\build\wasm-web\src\config.ini@config.ini" `
      --preload "src\bin\Data@Data" `
      --js-output=out\build\wasm-web\src\Main.data.js
}

Write-Host "=== Deploying to openmu-browser-stack/public ===" -ForegroundColor Cyan
if (Test-Path $stackPublic) {
    Copy-Item "out\build\wasm-web\src\Main.wasm" "$stackPublic\Main.wasm" -Force
    Copy-Item "out\build\wasm-web\src\Main.js" "$stackPublic\Main.js" -Force
    Copy-Item "out\build\wasm-web\src\Main.data.js" "$stackPublic\Main.data.js" -Force
    Copy-Item "out\build\wasm-web\src\Main.data" "$stackPublic\Main.data" -Force
    Write-Host "Deployed successfully to $stackPublic" -ForegroundColor Green
} else {
    Write-Warning "Stack public directory not found at $stackPublic"
}
