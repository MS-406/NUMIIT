# How to Run NumiIT

Setup is already done on this machine. Flutter SDK: `d:\college 3rd year\coin\flutter_sdk`

**Important:** Always run commands from **`D:\numiit`** (shortcut without spaces).  
The folder `college 3rd year` breaks some Flutter builds.

---

## Option A — Web (Chrome) — works now

1. Open PowerShell
2. Run:

```powershell
cd D:\numiit
d:\college` 3rd` year\coin\flutter_sdk\bin\flutter.bat run -d chrome
```

Or:

```powershell
cd D:\numiit
.\run.ps1 -Target chrome
```

3. Chrome opens with the app. Use **Gallery import** to test (camera is not available in browser).

---

## Option B — Android phone

You need **Android Studio** + Android SDK first:

1. Install [Android Studio](https://developer.android.com/studio)
2. Open Android Studio → SDK Manager → install Android SDK
3. In terminal:

```powershell
d:\college` 3rd` year\coin\flutter_sdk\bin\flutter.bat doctor --android-licenses
```

4. Enable **USB debugging** on your phone and connect USB
5. Run:

```powershell
cd D:\numiit
d:\college` 3rd` year\coin\flutter_sdk\bin\flutter.bat devices
d:\college` 3rd` year\coin\flutter_sdk\bin\flutter.bat run
```

---

## Option C — Install APK on phone (no USB after build)

```powershell
cd D:\numiit
d:\college` 3rd` year\coin\flutter_sdk\bin\flutter.bat build apk --release
```

Copy `build\app\outputs\flutter-apk\app-release.apk` to your phone.

---

## Add Flutter to PATH (optional)

Add to Windows Environment Variables → Path:

```
d:\college 3rd year\coin\flutter_sdk\bin
```

Then you can use `flutter` from any folder.

---

## Enable Developer Mode (recommended)

Settings → System → For developers → **Developer Mode** ON  
(Helps Flutter plugins on Windows.)
