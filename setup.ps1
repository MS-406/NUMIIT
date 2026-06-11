# NumiIT — one-time project setup (run in PowerShell)
# Requires Flutter SDK: https://docs.flutter.dev/get-started/install

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Write-Host "NumiIT setup..." -ForegroundColor Cyan

# Find Flutter (local SDK in parent folder, or PATH)
$flutter = $null
$localSdk = "d:\college 3rd year\coin\flutter_sdk\bin\flutter.bat"
if (Test-Path $localSdk) {
    $flutter = $localSdk
} elseif (Get-Command flutter -ErrorAction SilentlyContinue) {
    $flutter = "flutter"
} else {
    $candidates = @(
        "$env:LOCALAPPDATA\flutter\bin\flutter.bat",
        "$env:USERPROFILE\flutter\bin\flutter.bat",
        "C:\flutter\bin\flutter.bat",
        "D:\flutter\bin\flutter.bat"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { $flutter = $c; break }
    }
}

if (-not $flutter) {
    Write-Host "ERROR: Flutter not found. Install from https://docs.flutter.dev/get-started/install" -ForegroundColor Red
    Write-Host "Then add flutter\bin to your PATH and run this script again."
    exit 1
}

Write-Host "Using: $flutter"
& $flutter doctor

# Create android / ios / web folders if missing
if (-not (Test-Path "android")) {
    Write-Host "Creating platform folders..."
    & $flutter create . --org com.numiit --project-name numiit
}

# Dependencies
& $flutter pub get
& $flutter gen-l10n

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "Run on phone:  flutter run"
Write-Host "Run on web:    flutter run -d chrome"
Write-Host "List devices:  flutter devices"
