# NumiIT

**AI‑powered Flutter app for recognizing and translating inscriptions on ancient Indian coins**

---

## 📦 Overview
NumiIT lets you scan ancient Indian coins, detects the script, transliterates the inscription and provides an English translation. The app works on Android, iOS and the web.

---

## 🛠 Prerequisites
| Platform | Requirement |
|----------|-------------|
| **Windows** | 1. Administrator rights<br>2. PowerShell or CMD<br>3. Stable internet connection |
| **macOS** (for iOS) | 1. macOS 12+<br>2. Xcode 15+ (App Store)<br>3. Ruby (for CocoaPods) |

> **Note:** iOS builds can only be performed on macOS.

---

## 1️⃣ Install Flutter (if not already installed)
1. **Download** the latest stable Flutter SDK for your OS:
   - Windows: https://flutter.dev/docs/get-started/install/windows
   - macOS: https://flutter.dev/docs/get-started/install/macos
2. **Extract** the zip to a location you have write access to, e.g. `C:\src\flutter` (Windows) or `~/development/flutter` (macOS).
3. **Add to PATH**
   - Windows: add `<flutter‑dir>\bin` to the *System* PATH.
   - macOS: add `export PATH="$PATH:`pwd`/flutter/bin"` to `~/.zshrc`.
4. Open a **new terminal** and run:
   ```bash
   flutter doctor
   ```
   Resolve any reported issues (Android toolchain, Xcode, etc.).
5. Accept Android licenses (required for Android builds):
   ```bash
   flutter doctor --android-licenses
   ```

---

## 2️⃣ Set up Android development environment
### Android Studio & SDK
1. Install **Android Studio** from https://developer.android.com/studio.
2. During the first launch let it install the Android SDK and the **Command‑line tools**.
3. In Android Studio go to **Preferences → Appearance & Behavior → System Settings → Android SDK** and ensure **Android 13 (API 33)** (or the version you plan to target) is installed.

### Enable Developer options on the phone
1. Open **Settings → About phone**.
2. Tap **Build number** seven times → you will see *You are now a developer*.
3. Go back to **Settings → System → Developer options**.
4. **Turn on**:
   - **USB debugging** (required for the first connection)
   - **Wireless debugging** (recommended for day‑to‑day work)

### Connect via **USB** (first time only)
1. Connect the phone to your PC with a USB‑C cable.
2. When prompted on the phone, **Allow USB debugging** and tick *Always allow from this computer*.
3. Verify the connection:
   ```bash
   adb devices
   ```
   You should see a line like `xxxxxx    device`.
4. Run the app:
   ```bash
   flutter run
   ```
   If you have multiple devices, specify the device ID:
   ```bash
   flutter run -d <device-id>
   ```

### Switch to **Wireless debugging** (recommended)
> After a successful USB run you can disconnect the cable.
1. In **Developer options → Wireless debugging** tap **Pair device with pairing code**.
2. On the phone note the **IP address** and **pairing code** (e.g. `192.168.1.100:5555`).
3. In a terminal run the pairing commands (replace with the values shown on your phone):
   ```bash
   adb pair 192.168.1.100:5555   # enter the pairing code when asked
   adb connect 192.168.1.100:5555
   ```
4. Verify the wireless device appears:
   ```bash
   adb devices
   ```
   You should see `192.168.1.100:5555   device`.
5. Run the app **wirelessly**:
   ```bash
   flutter run -d 192.168.1.100:5555
   ```
   The app will now launch on the phone without a cable.

---

## 3️⃣ Set up iOS development environment (macOS only)
1. **Install Xcode** from the App Store and open it once to accept the license.
2. Install **CocoaPods** (required for Flutter iOS plugins):
   ```bash
   sudo gem install cocoapods
   ```
3. Enable **Developer mode** on the iPhone:
   - Settings → Privacy & Security → Developer Mode → Turn on and restart the phone.
4. **Connect via USB** the first time (same as Android) to trust the Mac.
5. **Wireless debugging** (optional, recommended):
   1. Open **Xcode → Window → Devices and Simulators**.
   2. Select your iPhone, check **Connect via network**.
   3. In Terminal run:
      ```bash
      flutter devices   # your iPhone should appear as a network device
      flutter run -d <device-id>
      ```
   The device will stay connected over Wi‑Fi as long as both the Mac and iPhone are on the same network.

---

## 4️⃣ Project setup (once only)
```bash
# Clone the repository (or copy the folder you already have)
git clone https://github.com/your‑org/numiit.git   # replace with actual repo URL
cd numiit

# Install Dart/Flutter dependencies
flutter pub get

# Generate localisation files (the project uses flutter_gen for l10n)
flutter gen-l10n
```

---

## 5️⃣ Running the app
### List available devices
```bash
flutter devices
```
You should see your Android phone (USB or wireless), iPhone (if on macOS), Android emulator, and Chrome.

### Run on **Android phone (wireless – recommended)**
```bash
flutter run -d 192.168.1.100:5555
```
### Run on **iPhone (wireless)**
```bash
flutter run -d <ios-device-id>
```
### Run on **Android emulator**
```bash
# Start an emulator from Android Studio or CLI
flutter emulators --launch <emulator-id>
flutter run
```
### Run on **Chrome (web)**
```bash
flutter run -d chrome
```
> **Web note:** The camera is not available in the browser; the UI falls back to *Pick from Gallery*.

---

## 6️⃣ Build a release package
### Android APK
```bash
flutter build apk --release
```
The APK will be located at `build/app/outputs/flutter-apk/app-release.apk`. Transfer it to the phone and install (enable *Install unknown apps* if needed).

### iOS (macOS)
```bash
flutter build ios --release
```
Open the generated Xcode workspace and archive for the App Store or Ad‑hoc distribution.

---

## 7️⃣ Common troubleshooting
- **`adb: command not found`** – make sure the Android SDK platform‑tools are in your PATH (`<android‑sdk>/platform-tools`).
- **Device shows as `offline`** – toggle *USB debugging* off/on, or restart `adb`:
  ```bash
  adb kill-server && adb start-server
  ```
- **Wireless connection fails** – ensure both PC and phone are on the **same Wi‑Fi network** and that no VPN or firewall blocks port **5555**.
- **Flutter doctor shows missing Xcode** – install Xcode and run `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`.
- **Dependency version conflicts** – run `flutter pub outdated` and update the packages with `flutter pub upgrade`.

---

## 📂 Project structure
```
lib/
├─ core/        # models, services, providers
├─ features/    # splash, home, camera, detection, result, history, settings
└─ shared/      # reusable widgets, utils
```

---

## 🔐 Permissions (after `flutter create`)
### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```
### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>NumiIT needs camera access to scan coin inscriptions</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>NumiIT needs photo library access to import coin images</string>
```

---

## 🎉 Get started!
Now you have a full, step‑by‑step guide to install Flutter, set up Android/iOS devices (both USB and wireless), run the app on all platforms and build release binaries. Happy hacking!  

---

*Version 1.0.0 – NumiIT*

AI-powered Flutter app for recognizing and translating inscriptions on ancient Indian coins.

## Quick start

### 1. Install Flutter (if not installed)

1. Download Flutter: https://docs.flutter.dev/get-started/install/windows
2. Extract and add `flutter\bin` to your **PATH**
3. Verify: open a new terminal and run `flutter doctor`
4. For **Android phone**: install Android Studio, accept SDK licenses (`flutter doctor --android-licenses`)
5. For **iPhone**: requires a Mac with Xcode (Windows cannot build for iOS locally)

### 2. One-time project setup

Open PowerShell in this folder:

```powershell
cd "d:\college 3rd year\coin\cursorapp"
.\setup.ps1
```

Or manually:

```powershell
flutter create . --org com.numiit --project-name numiit
flutter pub get
flutter gen-l10n
```

### 3. Run the app

```powershell
flutter devices          # list phones, emulators, Chrome
```

---

## Run on Android phone (recommended)

1. On your phone: **Settings → Developer options → USB debugging** (ON)
2. Connect phone via USB; allow debugging when prompted
3. Run:

```powershell
flutter run
```

If multiple devices appear, pick your phone:

```powershell
flutter run -d <device-id>
```

**Wireless (optional):** after first USB run:

```powershell
adb tcpip 5555
adb connect <phone-ip>:5555
flutter run
```

---

## Run on Android emulator

1. Open Android Studio → **Device Manager** → create/start a virtual device
2. Run:

```powershell
flutter run
```

---

## Run in Chrome (web)

```powershell
flutter run -d chrome
```

**Web notes:**

- Live **camera** is not available in the browser; use **Pick from Gallery** on the camera screen
- Gallery import, detection UI, results, encyclopedia, and statistics work
- History is stored in browser SQLite (FFI)

---

## Build release APK (share/install on phone)

```powershell
flutter build apk --release
```

APK path: `build\app\outputs\flutter-apk\app-release.apk`

Copy to your phone and install (enable “Install unknown apps” if needed).

---

## Plug in your ML model

Edit `lib/core/services/ml_service.dart` — replace `MLServiceStub` and register in `lib/core/providers/history_provider.dart`:

```dart
final mlServiceProvider = Provider<MLService>((ref) => YourMLService());
```

---

## Project structure

```
lib/
├── main.dart, app.dart
├── core/       models, database, services, providers
├── features/   splash, home, camera, detection, result, history, settings
└── shared/     widgets, utils
```

## Permissions (after flutter create)

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

v1.0.0 · NumiIT
