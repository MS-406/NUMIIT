# NumiIT

**AI‑powered ancient Indian coin inscription recognition**

NumiIT lets you scan ancient Indian coins, detects the script (Brahmi, Kharoshthi, Persian, etc.), transliterates the inscription, and provides an English translation, identifying the dynasty and era. The app works natively on Android, iOS, Windows, and the Web.

---

## 📦 Tech Stack

| Layer    | Technology                                      |
| -------- | ----------------------------------------------- |
| Frontend | Flutter (Dart) — Android, iOS, Web, Desktop     |
| Backend  | FastAPI (Python 3.11) — REST API                 |
| Database | PostgreSQL + SQLAlchemy 2 + Alembic              |
| Auth     | JWT (python-jose) + bcrypt password hashing      |
| State    | Riverpod (Flutter) + Dio HTTP client             |

---

## 🛠 Prerequisites

Before running the app, you need to set up the development environment.

| Platform | Requirement |
|----------|-------------|
| **Windows** | 1. Administrator rights<br>2. PowerShell or CMD<br>3. Stable internet connection |
| **macOS** (for iOS) | 1. macOS 12+<br>2. Xcode 15+ (App Store)<br>3. Ruby (for CocoaPods) |

### 1. Install Base Requirements
* **Python 3.11+**: Required for the FastAPI backend and AI model.
* **Flutter SDK**: Required for building and running the mobile/web frontend.
  - Download the stable Flutter SDK: [Windows](https://flutter.dev/docs/get-started/install/windows) / [macOS](https://flutter.dev/docs/get-started/install/macos).
  - Extract and add `flutter/bin` to your **PATH**.
  - Verify your installation by running `flutter doctor` in a new terminal and resolving any issues.
  - Accept Android licenses: `flutter doctor --android-licenses`
* **PostgreSQL**: Required for the backend database.

### 2. Database Setup (PostgreSQL)
Ensure the PostgreSQL service is running on `localhost:5432` with a database named `numiit`.
* **On Windows**: Start it via Services (`services.msc`) or command line: `net start postgresql-x64-15` (version number may vary).
* **Create the database**:
  ```bash
  psql -U postgres -c "CREATE DATABASE numiit;"
  ```

---

## ⚙️ Project Setup

### 1. One-Time Installation
Run the included python setup script to automatically create the Python virtual environment and install base dependencies, or run the standard Flutter setup commands.

**The Automated Way:**
```bash
python run.py setup
```
**The Manual Way:**
```bash
# Install Dart/Flutter dependencies
flutter pub get
# Generate localisation files (the project uses flutter_gen for l10n)
flutter gen-l10n
```

### 2. Machine Learning Dependencies
The ML dependencies (PyTorch, Ultralytics) are large and must be installed manually into the backend's virtual environment for the AI models to work properly.
```bash
cd backend
.\.venv\Scripts\activate  # (or source .venv/bin/activate on Mac/Linux)
pip install ultralytics torch torchvision
cd ..
```

---

## 🚀 Step-by-Step: How to Run the App (Backend + Android)

To successfully run the mobile app and connect it to the AI backend, you must run both the backend server and the frontend app at the same time. 

### Step 1: Start the Backend Server
You must start the FastAPI backend service first so the mobile app has an AI to talk to.
Open a terminal in the root folder of the project and run:
```bash
python run.py backend
```
*(Leave this terminal window open! The backend must stay running.)*

### Step 2: Prepare Your Android Phone
1. Connect your Android phone to your computer with a **USB cable**.
2. On your phone, go to **Settings → About phone** and tap **Build number** 7 times to enable Developer Options.
3. Go back to **Settings → System → Developer options** and turn on **USB debugging**.
4. When prompted on your phone screen, tap **Allow** to trust your computer.
5. Verify your computer sees your phone by opening a *new* terminal and running:
   ```bash
   adb devices
   ```
   *(You should see a device ID listed next to the word `device`).*

### Step 3: Run the Frontend (Mobile App)
With your backend running (Step 1) and your phone connected via USB (Step 2), you can now build and launch the app directly onto your phone.

In a **new terminal window**, run:
```bash
flutter run
```
*(If you have multiple devices connected, it might ask you to choose one. Press the number corresponding to your physical Android phone).*

**⚠️ Important Note on Connecting the Backend:** 
When running on a physical Android phone, the app automatically knows to connect to your computer's backend over the USB connection. If you decide to run the app over Wi-Fi (Wireless Debugging) instead of USB, you must tell the app your computer's IP address by running: `python run.py frontend android --ip <YOUR_PC_WIFI_IP>`.

---

## 📦 Step-by-Step: How to Build & Install the Android APK

If you want to build a standalone APK file that you can share with others or install permanently on your phone without needing a computer, follow these steps:

### Step 1: Build the Release APK
Open a terminal in the root folder and run:
```bash
flutter build apk --release
```
*(This process may take a few minutes as it compiles the entire app).*

### Step 2: Locate the APK File
Once the build is complete, you can find the generated APK file at this exact location:
`build/app/outputs/flutter-apk/app-release.apk`

### Step 3: Install the APK on Your Phone
You can either email this file to yourself, upload it to Google Drive, or transfer it directly via USB to your phone.
To install it directly via USB using your terminal, run:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```
*(Make sure your phone is connected and USB debugging is enabled).*

---

## 🌐 Running on Other Platforms

**A. Locally on Windows / Web**
- **Web**: `python run.py frontend chrome` 
  *(Note: The camera is not available in the browser; the UI falls back to Pick from Gallery).*
- **Windows Desktop**: `python run.py frontend windows`

**B. iPhone / iOS Device (Native via macOS)**
Ensure your iPhone is connected via USB or Network.
```bash
flutter run -d <ios-device-id>
```

**C. GitHub Codespaces**
1. Build Web Frontend: `python run.py build-web`
2. Start Backend: `python run.py backend`
3. The FastAPI server automatically serves the Flutter web build on port 8000.

---

## 🛠 Common Troubleshooting

- **`adb: command not found`** – make sure the Android SDK platform‑tools are in your PATH (`<android‑sdk>/platform-tools`).
- **Device shows as `offline`** – toggle *USB debugging* off/on, or restart adb:
  ```bash
  adb kill-server && adb start-server
  ```
- **Wireless connection fails** – ensure both PC and phone are on the **same Wi‑Fi network** and that no VPN/firewall blocks port **5555**.
- **Flutter doctor shows missing Xcode** – install Xcode and run `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`.
- **Dependency version conflicts** – run `flutter pub outdated` and update the packages with `flutter pub upgrade`.
- **Cross-Origin (CORS) issues (Web)** – ensure your backend is running at the correct IP/Port defined in your environment configs.

---

## 📂 Project Structure

```
NumiIT/
├── backend/          # FastAPI service
│   ├── src/numiit_backend/
│   │   ├── api/v1/routes/   # health, auth, users, uploads, scans
│   │   ├── core/            # config, security
│   │   ├── db/              # SQLAlchemy base + session
│   │   ├── models/          # User, Scan ORM models
│   │   ├── schemas/         # Pydantic request/response schemas
│   │   └── main.py          # FastAPI app entry point
│   └── .env                 # environment config
├── frontend/         # Flutter app
│   ├── lib/
│   │   ├── core/            # services, providers, models, database
│   │   ├── features/        # auth, camera, detection, history, etc.
│   │   └── shared/          # reusable widgets
│   ├── android/             # Android platform config
│   └── ios/                 # iOS platform config
└── run.py            # Cross-platform project runner
```

---

## 🔌 API Endpoints

| Method | Endpoint                | Auth     | Description            |
| ------ | ----------------------- | -------- | ---------------------- |
| GET    | `/api/v1/health`        | —        | Health check           |
| POST   | `/api/v1/auth/register` | —        | Create account         |
| POST   | `/api/v1/auth/login`    | —        | Login → JWT token      |
| GET    | `/api/v1/users/me`      | Bearer   | Current user profile   |
| POST   | `/api/v1/uploads`       | Optional | Upload coin image      |
| GET    | `/api/v1/scans`         | Optional | List scan history      |
| POST   | `/api/v1/scans`         | Optional | Save a scan            |
| GET    | `/api/v1/scans/{id}`    | Optional | Get scan by ID         |
| PUT    | `/api/v1/scans/{id}`    | Bearer   | Update scan            |
| DELETE | `/api/v1/scans/{id}`    | Bearer   | Delete scan            |

---

## 🗄️ Database Configuration

Edit `backend/.env` to change the PostgreSQL connection:

```env
DATABASE_URL=postgresql+psycopg://postgres:postgres@localhost:5432/numiit
SECRET_KEY=your-secret-key-here
```

---

## 🔐 Permissions (after `flutter create`)

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>NumiIT needs camera access to scan coin inscriptions</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>NumiIT needs photo library access to import coin images</string>
```

---
*Version 1.0.0 – NumiIT*
