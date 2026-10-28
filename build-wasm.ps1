param (
    [switch]$RebuildAssets
)

$ErrorActionPreference = "Stop"

$repoRoot = "C:\Users\Poisson\Documents\MuMain"
$stackPublic = "C:\Users\Poisson\Documents\openmu-browser-stack\public"

$env:PATH = "C:\Users\Poisson\.local\dotnet;C:\Users\Poisson\.local\cmake-3.31.5-windows-x86_64\bin;C:\Users\Poisson\.local\bin;C:\Users\Poisson\emsdk;C:\Users\Poisson\emsdk\upstream\emscripten;C:\Users\Poisson\emsdk\node\24.19.0_64bit\bin;C:\Users\Poisson\emsdk\python\3.13.3_64bit;" + $env:PATH

Write-Host "=== Compiling MuMain to WebAssembly ===" -ForegroundColor Cyan
Set-Location $repoRoot

ninja -C out/build/wasm-web
if ($LASTEXITCODE -ne 0) {
    Write-Error "Compilation failed."
    exit $LASTEXITCODE
}

Write-Host "=== Compilation Successful ===" -ForegroundColor Green

if ($RebuildAssets -or !(Test-Path "out\build\wasm-web\src\Main.data")) {
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
