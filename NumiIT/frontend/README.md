# NumiIT

**AI‑powered Flutter app for recognizing and translating inscriptions on ancient Indian coins**

---

## 📦 Overview

NumiIT lets you scan ancient Indian coins, detects the script, transliterates the inscription, and provides an English translation. This guide covers running the app on:

- **Android** — wired USB from a Windows PC
- **iOS** — wired USB from a MacBook

---

## 🛠 Prerequisites

| Platform | Requirements |
|----------|-------------|
| **Windows (Android)** | Administrator rights · PowerShell or CMD · Stable internet · Android Studio · USB-C cable |
| **macOS (iOS)** | macOS 12+ · Xcode 15+ · CocoaPods · USB cable · Ruby (pre-installed on macOS) |

---

## 1️⃣ Install Flutter

### Windows

1. Download the latest stable Flutter SDK:
   https://flutter.dev/docs/get-started/install/windows
2. Extract to a path without spaces, e.g. `C:\src\flutter`.
3. Add `C:\src\flutter\bin` to your **System PATH** (search *Environment Variables* in Start).
4. Open a **new** PowerShell window and verify:
   ```powershell
   flutter doctor
   ```
5. Accept Android licenses:
   ```powershell
   flutter doctor --android-licenses
   ```

### macOS

1. Download the latest stable Flutter SDK:
   https://flutter.dev/docs/get-started/install/macos
2. Extract to `~/development/flutter`.
3. Add to `~/.zshrc`:
   ```bash
   export PATH="$PATH:$HOME/development/flutter/bin"
   ```
4. Open a **new** terminal and verify:
   ```bash
   flutter doctor
   ```

---

## 2️⃣ Project Setup (one-time)

Run these commands in the project root on either OS:

```bash
git clone https://github.com/your-org/numiit.git   # replace with actual repo URL
cd numiit
flutter pub get
flutter gen-l10n
```

---

## 3️⃣ Running on Android — Wired (Windows)

### A. Install Android Studio & SDK

1. Download and install **Android Studio**: https://developer.android.com/studio
2. On first launch, let it install the **Android SDK** and **Command-line tools**.
3. Go to **Preferences → Appearance & Behavior → System Settings → Android SDK** and confirm **Android 13 (API 33)** (or your target version) is installed.

### B. Enable Developer Options on your phone

1. **Settings → About phone** — tap **Build number** seven times.
2. You'll see *"You are now a developer!"*
3. Go to **Settings → System → Developer options**.
4. Turn on **USB debugging**.

### C. Connect via USB

1. Plug your phone into the Windows PC with a USB-C cable.
2. On the phone, tap **Allow USB debugging** when prompted. Tick *Always allow from this computer*.
3. Verify the connection:
   ```powershell
   adb devices
   ```
   Expected output:
   ```
   List of devices attached
   XXXXXXXX    device
   ```
   > **`adb: command not found`?** Add `<Android SDK>\platform-tools` to your System PATH.

4. List Flutter-visible devices:
   ```powershell
   flutter devices
   ```

### D. Run the app

```powershell
flutter run
```

If multiple devices are listed, target your phone explicitly:

```powershell
flutter run -d <device-id>
```

### E. Build a release APK (optional)

```powershell
flutter build apk --release
```

APK location: `build\app\outputs\flutter-apk\app-release.apk`

Copy it to your phone and install (enable **Install unknown apps** in Settings if needed).

---

## 4️⃣ Running on iOS — Wired (macOS)

### A. Install Xcode

1. Install **Xcode 15+** from the Mac App Store.
2. Open Xcode once to accept the license agreement.
3. Switch the command-line tools path:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   ```

### B. Install CocoaPods

```bash
sudo gem install cocoapods
```

### C. Enable Developer Mode on your iPhone

1. **Settings → Privacy & Security → Developer Mode** — toggle **On**.
2. Restart the iPhone when prompted.

### D. Connect via USB

1. Plug your iPhone into the MacBook with a USB cable.
2. On the iPhone, tap **Trust** when the *Trust This Computer?* prompt appears.
3. Enter your iPhone passcode to confirm.
4. Verify Flutter can see the device:
   ```bash
   flutter devices
   ```
   Your iPhone should appear in the list.

### E. Run the app

```bash
flutter run
```

Target your iPhone explicitly if multiple devices are listed:

```bash
flutter run -d <ios-device-id>
```

> **First run only:** Flutter will open Xcode automatically to sign the app. In Xcode go to **Signing & Capabilities**, select your Apple ID under **Team**, then re-run `flutter run`.

### F. Build a release IPA (optional)

```bash
flutter build ios --release
```

Open the generated Xcode workspace, then **Product → Archive** to distribute via Ad-hoc or the App Store.

---

## 5️⃣ Required Permissions

Add these after running `flutter create`:

**Android** — `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

**iOS** — `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>NumiIT needs camera access to scan coin inscriptions</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>NumiIT needs photo library access to import coin images</string>
```

---

## 6️⃣ Plug in Your ML Model

Edit `lib/core/services/ml_service.dart` — replace `MLServiceStub` and register in `lib/core/providers/history_provider.dart`:

```dart
final mlServiceProvider = Provider<MLService>((ref) => YourMLService());
```

---

## 7️⃣ Project Structure

```
lib/
├── main.dart, app.dart
├── core/       # models, database, services, providers
├── features/   # splash, home, camera, detection, result, history, settings
└── shared/     # widgets, utils
```

---

## 🔧 Common Troubleshooting

| Problem | Fix |
|---------|-----|
| `adb: command not found` | Add `<Android SDK>/platform-tools` to your PATH |
| Device shows as `offline` | Toggle USB debugging off/on, then restart ADB: `adb kill-server && adb start-server` |
| Flutter doctor shows missing Xcode | Run `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer` |
| iOS app fails to sign | Open Xcode → **Signing & Capabilities** → set your Apple ID as the Team |
| Dependency conflicts | Run `flutter pub outdated`, then `flutter pub upgrade` |
| CocoaPods install fails | Try `sudo gem install cocoapods --user-install` or use Homebrew: `brew install cocoapods` |

---

*Version 1.0.0 · NumiIT*
