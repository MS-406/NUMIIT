# NumiIT — quick run script (uses local Flutter SDK)
# Run from D:\numiit to avoid path-with-spaces build errors
$flutter = "d:\college 3rd year\coin\flutter_sdk\bin\flutter.bat"
$projectDir = if (Test-Path "D:\numiit") { "D:\numiit" } else { $PSScriptRoot }
Set-Location $projectDir

param(
    [ValidateSet("chrome", "phone", "windows")]
    [string]$Target = "chrome"
)

if (-not (Test-Path $flutter)) {
    Write-Host "Flutter SDK not found. Run setup first or install Flutter." -ForegroundColor Red
    exit 1
}

& $flutter pub get

switch ($Target) {
    "chrome" { & $flutter run -d chrome }
    "phone"  { & $flutter run }
    "windows" { & $flutter run -d windows }
}
