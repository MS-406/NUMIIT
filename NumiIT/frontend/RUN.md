# How to Run NumiIT

## Prerequisites

- Python 3.11+ installed
- PostgreSQL running on localhost:5432
- Flutter SDK on your PATH (or at a known location)
- Android Studio + Android SDK (for phone testing)

---

## Quick Start (All Platforms)

From the project root (`d:\NumiIT`):

```bash
# One-time setup
python run.py setup

# Start the backend (runs on 0.0.0.0:8000)
python run.py backend

# In a second terminal — run the Flutter app
python run.py frontend chrome       # Web browser
python run.py frontend android      # Android (emulator auto-detects IP)
python run.py frontend android --ip 192.168.1.100  # Physical Android phone
python run.py frontend ios          # iOS device
python run.py frontend windows      # Windows desktop
```

---

## Running on Android Phone

1. Enable **USB Debugging** on your phone (Settings → Developer Options)
2. Connect phone via USB **or** ensure phone + laptop are on same WiFi
3. Start backend: `python run.py backend`
4. Note the **Network IP** printed (e.g., `192.168.1.100`)
5. Run: `python run.py frontend android --ip 192.168.1.100`

---

## Running on Web (Chrome)

```bash
python run.py backend       # Terminal 1
python run.py frontend chrome  # Terminal 2
```

Use **Gallery import** to test coin scanning (camera not available in browser).

---

## Building a Release APK

```bash
cd frontend
flutter build apk --release --dart-define=NUMIIT_API_BASE_URL=http://YOUR_SERVER_IP:8000/api/v1
```

Copy `frontend/build/app/outputs/flutter-apk/app-release.apk` to your phone.

---

## Troubleshooting

- **Backend won't start**: Check PostgreSQL is running → `psql -U postgres -c "SELECT 1;"`
- **Phone can't connect**: Ensure phone + laptop are on same WiFi network
- **Flutter not found**: Add Flutter SDK's `bin` folder to your system PATH
