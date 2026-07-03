# NumiIT - Complete Technical & Architecture Report
**Project Name:** NumiIT (AI-Powered Ancient Indian Coin Recognition App)  
**Date Generated:** June 10, 2026  
**Project Version:** 1.0.0  
**Primary Language:** Dart (Flutter Framework)  
**Supported Platforms:** Android, iOS, Web

---

## 1. Executive Summary

**NumiIT** is a cross-platform mobile application built using **Flutter** (Dart language) for recognizing and translating inscriptions on ancient Indian coins. The project uses a **Clean Architecture** pattern with feature-based modularity and modern reactive state management.

### Technology Stack Overview:
- **Frontend Framework:** Flutter (Dart)
- **Architecture Pattern:** Clean Architecture + MVVM
- **State Management:** Riverpod (reactive)
- **Routing:** GoRouter (declarative)
- **Database:** SQLite (mobile) + SQLite FFI (web)
- **UI System:** Material Design 3
- **Testing:** Flutter Test Framework
- **Languages Used:** Dart, Kotlin (Android), Swift (iOS), JavaScript (Web), SQL

---

## 2. ARCHITECTURE OVERVIEW

### 2.1 Architectural Pattern: Clean Architecture

**What it means:**
Clean Architecture separates the app into distinct layers with specific responsibilities and dependencies flowing inward.

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI Screens, Widgets, Navigation)      │
│  Language: Dart (Flutter)               │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│      Application/Features Layer         │
│  (Feature Screens, State Management)    │
│  Language: Dart (Flutter + Riverpod)    │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│      Domain/Business Logic Layer        │
│  (Services, Providers, Models)          │
│  Language: Dart                         │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│    Infrastructure/Data Layer            │
│  (Database, APIs, External Services)    │
│  Language: Dart, SQL, Native Bindings   │
└─────────────────────────────────────────┘
```

### 2.2 Layer Responsibilities

| Layer | Responsibility | Language | Location |
|-------|----------------|----------|----------|
| **Presentation** | Display UI, handle user interaction | Dart/Flutter | `features/` folders |
| **Application** | Feature logic, UI state management | Dart | `features/*/providers/` |
| **Domain** | Business logic, data models, state | Dart | `core/` |
| **Infrastructure** | Database, APIs, device access | Dart + Native | `core/database/`, plugins |

---

## 3. DETAILED LIBRARY BREAKDOWN WITH LANGUAGES

### SECTION A: CORE FRAMEWORK & BASE LIBRARIES

#### 3.A.1 `flutter` (SDK)
**Language:** Dart (wrapper) + Native code (execution)  
**Native Implementation:** 
- Android: Dart VM compiled to native code + Kotlin/Java interop
- iOS: Dart compiled to native ARM code + Swift interop
- Web: Dart compiled to JavaScript via dart2js

**Version:** Latest (SDK)  
**Platform:** Android (Kotlin), iOS (Swift), Web (JavaScript)

**What it is:**
Flutter is Google's UI framework for building natively compiled applications.

**Provides:**
- Dart compiler and runtime environment
- Widget system for UI building  
- Material Design and Cupertino widgets
- Platform channel APIs for native code communication

**How it works (Architecture):**
```
Dart Code (Flutter App)
    ↓
Dart2Native Compiler (Android/iOS) or dart2js (Web)
    ↓
Platform Specific Execution:
    ├─ Android: Runs in Dart VM → communicates with Kotlin/Android Framework
    ├─ iOS: Compiled to native ARM code → calls Swift via platform channel
    └─ Web: JavaScript → DOM + Canvas rendering
    ↓
Native UI Rendering Engine (Skia)
```

**Why it's used:**
- ✅ Single codebase, multiple platforms (Android, iOS, Web)
- ✅ Native performance (not WebView-based like React Native)
- ✅ Hot reload for faster development iteration
- ✅ Rich component library (300+ widgets)
- ✅ Officially backed by Google with large community

**Where used:**
- Every screen and UI component
- All user interaction handling
- Cross-platform code sharing

---

#### 3.A.2 `flutter_localizations` (SDK)
**Language:** Dart  
**Platform:** All (Android, iOS, Web, Desktop)  
**Version:** Latest (SDK)

**What it is:**
Flutter's built-in internationalization (i18n) infrastructure.

**Provides:**
- Locale data for 100+ languages
- Date/time formatting rules
- Number formatting rules
- Plural forms for different languages
- Text direction (LTR/RTL)

**How it works:**
```
App requests locale information
    ↓
flutter_localizations provides data for that locale
    ↓
User sees UI in their language with proper formatting
```

**Why it's used:**
- ✅ Built into Flutter (no external dependency)
- ✅ Support for English, Hindi, Gujarati
- ✅ Automatic date/number formatting per locale
- ✅ Proper RTL support for Indian languages
- ✅ Lightweight and optimized

**Where used:**
- App-wide localization system
- Settings screen (language selection)
- Date/time displays throughout app

---

#### 3.A.3 `cupertino_icons` (^1.0.8)
**Language:** Dart (icon font asset)  
**Platform:** All platforms  
**Version:** 1.0.8 or compatible

**What it is:**
Icon font library with iOS (Cupertino) style icons.

**Provides:**
- 900+ iOS-style icons as vector font
- Cross-platform icon access via Dart

**How it works:**
```
IconData("icon_name") from cupertino_icons
    ↓
Flutter Text Widget renders font glyph
    ↓
Vector icon displayed on screen
```

**Why it's used:**
- ✅ iOS apps expect familiar iOS icon style
- ✅ Lightweight (font-based, not image files)
- ✅ Scalable without quality loss
- ✅ Works on all platforms uniformly

**Where used:**
- Navigation bar icons
- Button icons throughout app
- iOS-specific UI elements

---

### SECTION B: STATE MANAGEMENT & REACTIVITY

#### 3.B.1 `flutter_riverpod` (^2.5.1)
**Language:** Dart  
**Platform:** All (Android, iOS, Web, Desktop)  
**Version:** 2.5.1 or higher

**What it is:**
Modern reactive programming library for Dart/Flutter state management.

**Provides:**
- Provider concept (data containers)
- Reactive state updates
- Automatic dependency injection
- Caching and invalidation
- AsyncValue for handling async data
- Testing utilities and mocking

**Architecture Pattern (Riverpod):**
```
┌──────────────────────────────────────┐
│     UI Widgets (Screen)              │
│  (Watching Providers via WidgetRef)  │
└────────────────┬─────────────────────┘
                 │ watches/reads
┌────────────────▼─────────────────────┐
│  Riverpod Providers (State Logic)     │
│  ├─ StateProvider (mutable state)     │
│  ├─ Provider (computed/immutable)     │
│  ├─ FutureProvider (async data)       │
│  └─ StreamProvider (continuous data)  │
└────────────────┬─────────────────────┘
                 │ depends on
┌────────────────▼─────────────────────┐
│  Services & Repositories              │
│  (Business Logic - Dart)              │
└────────────────┬─────────────────────┘
                 │ uses
┌────────────────▼─────────────────────┐
│  Data Sources (SQLite, APIs, etc)     │
└──────────────────────────────────────┘
```

**How it works (Dart Code):**
```dart
// Define provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});

// In UI (Dart):
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);  // Watch state
    
    return Text(settings.themeMode);  // Auto-rebuilds on change
  }
}
```

**Why it's used:**
- ✅ Modern immutable state patterns
- ✅ Better performance (only affected widgets rebuild)
- ✅ Easy testing (mock providers)
- ✅ Automatic code splitting and lazy loading
- ✅ Official recommended by Flutter team

**Use Cases in NumiIT:**
- `settingsProvider` - User preferences (theme, language)
- `authProvider` - Authentication state
- `scanHistoryProvider` - Fetching scan records
- `detectionProvider` - Current detection state

**Where used:**
- app.dart - Router and theme switching
- Every feature screen
- All state management logic

---

### SECTION C: NAVIGATION & ROUTING

#### 3.C.1 `go_router` (^14.2.7)
**Language:** Dart  
**Platform:** All (Android, iOS, Web, Desktop)  
**Version:** 14.2.7 or higher

**What it is:**
Declarative routing library replacing Flutter's traditional Navigator API.

**Provides:**
- URL-based routing system
- Deep linking support for external links
- Nested routing with Shell routes
- Type-safe route parameters
- Automatic back button handling
- Programmatic and URL-based navigation

**How it works (Dart):**
```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => SplashScreen()),
      GoRoute(path: '/login', builder: (_, state) => AuthScreen()),
      ShellRoute(  // Wrapper for bottom nav
        builder: (context, state, child) => AppLayout(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => HomeScreen()),
          GoRoute(path: '/camera', builder: (_, __) => CameraScreen()),
          GoRoute(path: '/result/:id', builder: (_, state) {
            final id = state.pathParameters['id']!;
            return ResultScreen(scanId: id);
          }),
        ],
      ),
    ],
  );
});
```

**Navigation Structure:**
```
/ (Splash) 
  → /login (Auth) 
    → /home (Dashboard) ├─ Shell
      /camera (Camera) ├─ Navigation
      /detection ├─ (Bottom Nav)
      /result/:id ├─ Wrapper
      /history ├─
      /settings ├─
      /statistics ├─
      /encyclopedia ├─
      /profile ├─
```

**Why it's used:**
- ✅ Modern declarative approach (cleaner than imperative)
- ✅ Deep linking out of the box
- ✅ Type-safe route parameters
- ✅ Web URL support (Flutter web shows actual URLs)
- ✅ Officially recommended by Flutter team

**Where used:**
- app.dart - Route definitions
- Navigation between all screens
- Deep linking for notifications

---

### SECTION D: CAMERA & IMAGE HANDLING

#### 3.D.1 `camera` (^0.11.0+2)
**Language:** Dart (wrapper) + Native code  
**Native Implementation:**
- Android: Kotlin using Camera2 API
- iOS: Swift using AVFoundation framework

**Platform:** Android (Kotlin), iOS (Swift) only  
**Version:** 0.11.0+2 or higher

**What it is:**
Official Flutter plugin for accessing device camera hardware.

**Native Code Flow:**
```
Dart: camera.initialize()
  ↓ Platform Channel
Android (Kotlin):
  └─ CameraManager → Camera2 API
     └─ CameraDevice → Hardware camera
     
iOS (Swift):
  └─ AVCaptureDevice → Hardware camera
     └─ AVCaptureSession
```

**How it works:**
```
1. Dart calls camera plugin
   ↓
2. Platform-specific code initializes hardware:
   - Android: Kotlin code uses Camera2 API
   - iOS: Swift code uses AVFoundation
   ↓
3. Camera stream sent back to Dart
   ↓
4. Flutter displays video preview in UI
   ↓
5. User captures photo
   ↓
6. Image returned to Dart app
```

**Why it's used:**
- ✅ Main feature of app (coin scanning)
- ✅ Official, well-maintained plugin
- ✅ Hardware optimization (uses native code)
- ✅ Access to camera features (focus, flash, exposure)
- ✅ High performance for real-time preview

**Where used:**
- Camera screen (features/camera/)
- Primary coin scanning workflow
- Real-time preview rendering

---

#### 3.D.2 `image_picker` (^1.1.2)
**Language:** Dart (wrapper) + Native code  
**Native Implementation:**
- Android: Kotlin with Intent(ACTION_PICK)
- iOS: Swift using UIImagePickerController
- Web: JavaScript using HTML file input

**Platform:** Android (Kotlin), iOS (Swift), Web (JavaScript)  
**Version:** 1.1.2 or higher

**What it is:**
Official Flutter plugin for selecting images/videos from device gallery.

**Platform Implementation:**
```
Android (Kotlin):
  └─ Intent(ACTION_PICK) → Android Gallery app
     └─ Returns image file path

iOS (Swift):
  └─ UIImagePickerController → Photos framework
     └─ Returns image data

Web (JavaScript):
  └─ <input type="file"> → Browser file picker
     └─ Returns File object
```

**Why it's used:**
- ✅ Flexibility for users to scan existing coin images
- ✅ Native UI (users familiar with gallery app)
- ✅ Cross-platform support (works on web too)
- ✅ Official plugin (maintained by Google/Flutter)

**Where used:**
- Camera screen - "Pick from Gallery" button
- Batch scanning feature
- Alternative when camera not available

---

#### 3.D.3 `image` (^4.2.0)
**Language:** Pure Dart (no native code)  
**Platform:** All (Android, iOS, Web, Desktop)  
**Version:** 4.2.0 or higher

**What it is:**
Pure Dart library for image manipulation and processing.

**Supported Formats & Operations:**
```
Decode: PNG, JPEG, WebP, BMP, TIFF, ICO, TGA, PSD

Operations:
├─ Resize (Lanczos, nearest, linear algorithms)
├─ Crop (select regions)
├─ Rotate (0-360°)
├─ Flip (horizontal/vertical)
├─ Scale (maintain aspect ratio)
├─ Color operations (brightness, contrast, hue)
└─ Pixel-level manipulation
```

**How it works (Pure Dart):**
```dart
import 'package:image/image.dart' as img;

// Load image from bytes
List<int> imageBytes = await File(path).readAsBytes();
img.Image? image = img.decodeImage(imageBytes);

// Resize for ML model (224x224)
img.Image resized = img.copyResize(image!, width: 224, height: 224);

// Encode back to JPEG
List<int> finalBytes = img.encodeJpg(resized, quality: 85);

// Send to AI detection
sendToDetectionAPI(finalBytes);
```

**Why it's used:**
- ✅ Optimize images before sending to backend
- ✅ Reduce bandwidth (resize large photos)
- ✅ Format conversion if needed
- ✅ Works on all platforms including web
- ✅ Pure Dart (no native dependencies)

**Where used:**
- Image preprocessing before AI detection
- Gallery image optimization
- Image format conversion

---

#### 3.D.4 `photo_view` (^0.15.0)
**Language:** Dart (Flutter widget)  
**Platform:** All (Android, iOS, Web, Desktop)  
**Version:** 0.15.0 or higher

**What it is:**
Flutter widget for zooming and panning images.

**Gesture Support:**
```
├─ Pinch-to-zoom (two-finger pinch)
├─ Double-tap zoom (toggle between fit and zoom)
├─ Drag/pan (move around image)
├─ Rotation gesture
└─ Fling animation (momentum scrolling)
```

**How it works (Dart):**
```dart
PhotoView(
  imageProvider: FileImage(File(imagePath)),
  minScale: PhotoViewComputedScale.contained * 0.8,
  maxScale: PhotoViewComputedScale.covered * 2,
  enableRotation: true,
)
```

**Why it's used:**
- ✅ Users can examine detection results closely
- ✅ Intuitive touch gestures (like native gallery apps)
- ✅ Built-in performance optimization
- ✅ Works on all platforms uniformly

**Where used:**
- Result screen - Zoom into detection results
- History screen - View scan images
- Encyclopedia - View reference coin images

---

### SECTION E: DATA STORAGE & PERSISTENCE

#### 3.E.1 `sqflite` (^2.3.3+1)
**Language:** Dart (wrapper) + Native code  
**Native Implementation:**
- Android: Kotlin using Android SQLite API
- iOS: Swift using CoreData or direct SQLite C library

**Platform:** Android (Kotlin), iOS (Swift)  
**Version:** 2.3.3+1 or higher

**What it is:**
Flutter plugin providing access to SQLite database on mobile devices.

**Database Implementation Architecture:**
```
┌─────────────────────────────────────────┐
│   Dart Code (sqflite plugin code)       │
└────────────────┬────────────────────────┘
                 │ Platform Channel
                 │
┌────────────────▼────────────────────────────────┐
│  SQLite Engine (C/C++ - Pre-installed on OS)   │
│  ├─ Query execution with ACID properties      │
│  ├─ Transaction management                    │
│  ├─ B-tree indexing                           │
│  ├─ Thread-safe operations                    │
│  └─ Full-text search support                  │
└────────────────┬────────────────────────────────┘
                 │ Persistent Storage
                 ▼
┌────────────────────────────────────────────────┐
│  Device File System                            │
│  ├─ Android: /data/data/com.numiit/app.db     │
│  └─ iOS: /Documents/app.db                     │
└────────────────────────────────────────────────┘
```

**Database Schema (NumiIT):**
```sql
-- Scan History
CREATE TABLE scans (
  id TEXT PRIMARY KEY,
  timestamp DATETIME,
  coinType TEXT,
  inscriptionText TEXT,
  confidenceScore REAL,
  imagePath TEXT
);

-- User Profile
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  username TEXT,
  email TEXT
);

-- Encyclopedia
CREATE TABLE coins (
  id INTEGER PRIMARY KEY,
  name TEXT,
  period TEXT,
  description TEXT
);
```

**How it works (Dart):**
```dart
// Open database
final db = await openDatabase(join(await getDatabasesPath(), 'app.db'));

// Execute SQL
await db.insert('scans', scanMap);
List<Map> results = await db.query('scans', where: 'confidence > ?', whereArgs: [0.8]);
await db.transaction((txn) async { ... });
```

**Why it's used:**
- ✅ Persistent storage for scan history
- ✅ Structured data (better than key-value)
- ✅ Offline-first (works without internet)
- ✅ Fast queries with indexing
- ✅ ACID compliance (data integrity)
- ✅ Cross-platform (same code Android & iOS)

**Where used:**
- History screen - Storing/retrieving scans
- Statistics screen - Querying analytics
- Detection screen - Saving new scans
- core/database/ - Database configuration

---

#### 3.E.2 `sqflite_common_ffi_web` (^0.4.5+4)
**Language:** Dart + WebAssembly  
**Implementation:** Dart FFI calling WASM-compiled SQLite  
**Platform:** Web (browsers) only  
**Version:** 0.4.5+4 or higher

**What it is:**
Bridge library enabling SQLite on web via FFI (Foreign Function Interface).

**How it works (Web SQLite):**
```
Dart Code
   ↓
sqflite_common_ffi_web (Dart FFI)
   ↓
SQLite compiled to WebAssembly (WASM binary)
   ↓
Browser JavaScript engine executes WASM
   ↓
Data stored in:
├─ IndexedDB (preferred, persistent)
└─ LocalStorage (fallback, limited size)
```

**Why it's used:**
- ✅ Web version has same database as mobile
- ✅ Data stays on device (privacy)
- ✅ Consistent user experience across platforms
- ✅ Offline capability in browser
- ✅ Same Dart code runs everywhere

**Where used:**
- main.dart - Conditional database initialization for web
- Web version of app - All database operations
- Enables `flutter run -d chrome` with full features

---

#### 3.E.3 `shared_preferences` (^2.3.2)
**Language:** Dart (wrapper) + Native code  
**Native Implementation:**
- Android: Java/Kotlin using SharedPreferences
- iOS: Swift using UserDefaults (NSUserDefaults)
- Web: JavaScript using localStorage

**Platform:** Android, iOS, Web, partially Desktop  
**Version:** 2.3.2 or higher

**What it is:**
Plugin for lightweight key-value data persistence.

**Platform Storage:**
```
Android (Kotlin):
  └─ SharedPreferences API
     └─ Stored in: /data/data/com.app/shared_prefs/

iOS (Swift):
  └─ UserDefaults
     └─ Stored in: ~/Library/Preferences/

Web (JavaScript):
  └─ localStorage API
     └─ Stored in: Browser's persistent storage
```

**How it works (Dart):**
```dart
import 'package:shared_preferences/shared_preferences.dart';

final prefs = await SharedPreferences.getInstance();

// Save
await prefs.setString('theme', 'dark');
await prefs.setBool('notifications', true);
await prefs.setInt('language', 1);  // 1 = Hindi

// Load
String theme = prefs.getString('theme') ?? 'light';
bool notifications = prefs.getBool('notifications') ?? true;
int language = prefs.getInt('language') ?? 0;  // 0 = English
```

**Data stored in NumiIT:**
- Theme mode (Light/Dark/System)
- Language selection (0=English, 1=Hindi, 2=Gujarati)
- Notification settings
- User session tokens

**Why it's used:**
- ✅ Perfect for simple settings (not complex data)
- ✅ Faster than querying SQLite for single values
- ✅ Uses native APIs (optimal performance)
- ✅ Synchronous access (no async overhead)
- ✅ Works completely offline

**Where used:**
- Settings screen - Save user preferences
- App startup - Load theme and language
- Profile screen - User choices
- Persistent user state

---

#### 3.E.4 `path_provider` (^2.1.4)
**Language:** Dart (wrapper) + Native code  
**Native Implementation:**
- Android: Kotlin using Context methods
- iOS: Swift using FileManager
- Web: JavaScript using browser APIs

**Platform:** Android, iOS, Web, Desktop (partial)  
**Version:** 2.1.4 or higher

**What it is:**
Plugin for getting platform-specific directory paths.

**Directory Paths Provided:**
```
Android (Kotlin):
├─ getApplicationDocumentsDirectory()
│  └─ /data/data/com.app/files
├─ getTemporaryDirectory()
│  └─ /data/data/com.app/cache
└─ getApplicationSupportDirectory()
   └─ /data/data/com.app/app_flutter

iOS (Swift):
├─ getApplicationDocumentsDirectory()
│  └─ /var/mobile/Containers/Data/Documents
├─ getTemporaryDirectory()
│  └─ /var/mobile/Containers/Data/tmp
└─ getLibraryDirectory()
   └─ /var/mobile/Containers/Data/Library

Web (JavaScript):
└─ Browser-specific storage
```

**How it works (Dart):**
```dart
import 'package:path_provider/path_provider.dart';

// Get documents directory
final docDir = await getApplicationDocumentsDirectory();
final dbPath = '${docDir.path}/app.db';

// Get temp directory for cache
final tempDir = await getTemporaryDirectory();
final cachePath = '${tempDir.path}/temp_image.jpg';
```

**Why it's used:**
- ✅ Platform-agnostic (same code everywhere)
- ✅ OS-appropriate directories
- ✅ Proper permissions pre-configured
- ✅ Database files stored correctly
- ✅ Supports all platforms uniformly

**Where used:**
- Database initialization - Finding database location
- Image caching - Temporary storage
- File export - Saving to documents
- core/database/ - Database path setup

---

#### 3.E.5 `path` (^1.9.0)
**Language:** Pure Dart (no native code)  
**Platform:** All (Android, iOS, Web, Desktop)  
**Version:** 1.9.0 or higher

**What it is:**
Pure Dart library for cross-platform path manipulation.

**Capabilities:**
```dart
import 'package:path/path.dart' as p;

// Join paths (handles separators correctly)
final dbPath = p.join(docDir.path, 'app', 'data', 'app.db');
// Result on Unix: /documents/app/data/app.db
// Result on Windows: C:\documents\app\data\app.db

// Extract components
p.basename('/path/to/file.db');    // → 'file.db'
p.extension('/path/to/image.jpg'); // → '.jpg'
p.dirname('/path/to/file.db');     // → '/path/to'
p.normalize('/path//to///file.db'); // → '/path/to/file.db'
```

**Why it's used:**
- ✅ Cross-platform path handling
- ✅ Safe concatenation (handles separators)
- ✅ Pure Dart (works everywhere)
- ✅ Prevents path-related bugs

**Where used:**
- Database initialization
- Image file management
- File operations throughout app

---

### SECTION F: UI & DESIGN SYSTEM

#### 3.F.1 `google_fonts` (^6.2.1)
**Language:** Dart (Flutter widget)  
**Platform:** All (Android, iOS, Web, Desktop)  
**Version:** 6.2.1 or higher

**What it is:**
Flutter package for accessing Google Fonts library (1000+ free fonts).

**How it works:**
```
Option 1: Download at runtime (default)
  ├─ App makes HTTP request to Google Fonts API
  ├─ Downloads font file (.ttf, .woff2)
  └─ Cached locally for offline use

Option 2: Bundle fonts locally
  ├─ Copy font files to assets/fonts/
  ├─ Use GoogleFonts.getFont('fontName')
  └─ Zero network calls
```

**Usage in NumiIT (Dart):**
```dart
import 'package:google_fonts/google_fonts.dart';

// In typography constants
TextStyle displayLarge = GoogleFonts.inter(
  fontSize: 32,
  fontWeight: FontWeight.bold,
);

TextStyle bodyMedium = GoogleFonts.openSans(
  fontSize: 14,
);

// Apply to widgets
Text('Coin Details', style: GoogleFonts.poppins(fontSize: 20));
```

**Why it's used:**
- ✅ Professional appearance
- ✅ Consistency across all platforms
- ✅ 1000+ curated fonts
- ✅ Easy integration with Flutter
- ✅ Improves user experience

**Where used:**
- App-wide typography
- core/constants/app_typography.dart
- All Text widgets

---

#### 3.F.2 `fl_chart` (^0.69.0)
**Language:** Dart (Flutter widgets)  
**Platform:** All (Android, iOS, Web, Desktop)  
**Version:** 0.69.0 or higher

**What it is:**
Flutter package for creating animated, interactive charts.

**Chart Types:**
```
├─ LineChart (trend lines, curves)
├─ BarChart (vertical/horizontal bars)
├─ PieChart (pie slices)
├─ ScatterChart (data points)
├─ RadarChart (spider/web charts)
└─ CandelChart (candlestick for finance)
```

**How it works (Dart):**
```dart
LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: [
          FlSpot(0, 3),
          FlSpot(2.6, 2),
          FlSpot(4.9, 5),
        ],
        isCurved: true,
        color: Colors.blue,
      ),
    ],
  ),
);
```

**Data Visualized in NumiIT:**
- Scan frequency over time (line)
- Detection confidence distribution (bar)
- Coin type breakdown (pie)
- Historical trends

**Why it's used:**
- ✅ Beautiful chart rendering
- ✅ Built for Flutter
- ✅ Interactive (touch events)
- ✅ Animated transitions
- ✅ Handles large datasets efficiently

**Where used:**
- Statistics screen
- Dashboard summaries
- Results visualization

---

#### 3.F.3 `lottie` (^3.1.2)
**Language:** Dart (Flutter widget) + JSON animation format  
**Platform:** All (Android, iOS, Web, Desktop)  
**Version:** 3.1.2 or higher

**What it is:**
Flutter package for rendering Adobe After Effects animations.

**Animation Format:**
```
Designer creates animation in After Effects
    ↓ (exports with Bodymovin plugin)
JSON animation definition file (.json)
    ↓ (includes paths, timing, colors, keyframes)
Lottie Player interprets JSON
    ↓
Renders as vector animation (Skia)
    ↓
Hardware accelerated on GPU
```

**File Size Comparison:**
```
Traditional Frame Animation:
  60 frames × 30fps = 1800 images
  Total size: ~100MB

Lottie Animation:
  Single JSON file: < 50KB
  Same 1-second animation
  ```

**Usage (Dart):**
```dart
Lottie.asset(
  'assets/animations/loading.json',
  width: 200,
  height: 200,
  repeat: true,
  animate: true,
);
```

**Why it's used:**
- ✅ Professional animations
- ✅ Polished user experience
- ✅ Efficient rendering (vector-based)
- ✅ Small file sizes
- ✅ Designer collaboration (create in After Effects)

**Where used:**
- Splash screen animation
- Detection processing animation
- Loading state animations

---

### SECTION G: PLATFORM FEATURES

#### 3.G.1 `permission_handler` (^11.3.1)
**Language:** Dart (wrapper) + Native code  
**Native Implementation:**
- Android: Kotlin using ActivityCompat / ContextCompat
- iOS: Swift using AVFoundation / Photos framework

**Platform:** Android (Kotlin), iOS (Swift)  
**Version:** 11.3.1 or higher

**What it is:**
Plugin for requesting and checking runtime permissions.

**Android Implementation (Kotlin):**
```kotlin
// Android 6+ requires runtime permission requests
if (ActivityCompat.checkSelfPermission(
    context, Manifest.permission.CAMERA
) != PackageManager.PERMISSION_GRANTED) {
  // Request permission
  ActivityCompat.requestPermissions(
    activity,
    arrayOf(Manifest.permission.CAMERA),
    CAMERA_PERMISSION_CODE
  )
}
```

**iOS Implementation (Swift):**
```swift
// iOS shows native permission dialog
AVCaptureDevice.requestAccess(for: .video) { granted in
  if granted {
    // Permission granted
    startCamera()
  }
}
```

**Permissions Managed:**
```
├─ CAMERA - Access device camera
├─ PHOTO_LIBRARY - Access photo gallery
├─ STORAGE - Access device storage
├─ MICROPHONE - Access microphone
└─ LOCATION - Access GPS location
```

**How it works (Dart):**
```dart
import 'package:permission_handler/permission_handler.dart';

PermissionStatus status = await Permission.camera.request();

if (status.isDenied) {
  showDialog('Camera permission required');
} else if (status.isGranted) {
  startCamera();
}
```

**Why it's used:**
- ✅ Legal requirement (Android 6+, iOS)
- ✅ User privacy (explicit consent)
- ✅ App store compliance
- ✅ User trust (transparent permissions)

**Where used:**
- Camera screen - Request camera permission
- Image picker - Request gallery permission
- Before sensitive hardware features

---

#### 3.G.2 `share_plus` (^10.0.2)
**Language:** Dart (wrapper) + Native code  
**Native Implementation:**
- Android: Kotlin using Intent.ACTION_SEND
- iOS: Swift using UIActivityViewController  
- Web: JavaScript using Web Share API

**Platform:** Android (Kotlin), iOS (Swift), Web (JavaScript)  
**Version:** 10.0.2 or higher

**What it is:**
Official plugin for native sharing functionality.

**Platform Implementation:**
```
Android (Kotlin):
  └─ Intent.ACTION_SEND → Native share sheet
     └─ Can share to: WhatsApp, Email, Drive, etc.

iOS (Swift):
  └─ UIActivityViewController → Native share menu
     └─ Can share to: Messages, Mail, AirDrop, etc.

Web (JavaScript):
  └─ navigator.share() API
     └─ Native browser share (if available)
```

**How it works (Dart):**
```dart
import 'package:share_plus/share_plus.dart';

// Share text
Share.share(
  'Check out this coin: ${coin.name}',
  subject: 'NumiIT - Coin Detection Result',
);

// Share files
Share.shareFiles(
  ['/path/to/coin_image.jpg'],
  text: 'Ancient coin from ${coin.period}',
);
```

**Why it's used:**
- ✅ Native UX (platform-specific UI)
- ✅ User empowerment
- ✅ Marketing (sharing promotes app)
- ✅ Engagement (users share discoveries)

**Where used:**
- Result screen - "Share Result" button
- History screen - Share past scans
- Encyclopedia - Share coin information

---

#### 3.G.3 `universal_io` (^2.2.2)
**Language:** Dart (wrapper around dart:io)  
**Platform:** All (Android, iOS, Web, Desktop)  
**Version:** 2.2.2 or higher

**What it is:**
Dart package providing platform-agnostic file I/O and HTTP.

**Problem it solves:**
```
dart:io (Native I/O)
├─ Works on: Android, iOS, Desktop
├─ Does NOT work on: Web
└─ Creates platform inconsistency

Solution: universal_io
├─ Provides same API for all platforms
├─ Uses dart:io on native
├─ Uses alternatives on web
└─ Single codebase for everything
```

**Features:**
```
File Operations:
├─ Read/write files
├─ Delete files
├─ File permissions
└─ Directory operations

HTTP Client:
├─ GET/POST/PUT/DELETE
├─ Custom headers
├─ Multipart uploads
└─ Streaming responses
```

**Why it's used:**
- ✅ Cross-platform consistency
- ✅ Web compatibility
- ✅ Future-proofing
- ✅ Abstraction of platform differences

**Where used:**
- File I/O operations
- API client creation
- Database file operations

---

## 4. SUMMARY & KEY TAKEAWAYS

### Languages Used:
- **Dart:** Main app code (all platforms)
- **Kotlin:** Android native code (camera, permissions)
- **Swift:** iOS native code (camera, permissions)
- **JavaScript:** Web platform (browser)
- **SQL:** Database queries (SQLite)
- **C/C++:** SQLite engine (preinstalled on OS)

### Architecture Layers:
1. **Presentation (Dart/Flutter):** UI widgets, screens
2. **Application (Dart/Riverpod):** Feature state, logic
3. **Domain (Dart):** Business logic, models
4. **Infrastructure (Dart + Native):** Database, APIs, plugins

### Total Dependencies: 26 packages
- Core: 3 (Flutter, localizations, icons)
- State/Navigation: 2 (Riverpod, GoRouter)
- Media: 4 (Camera, picker, image, photo_view)
- Storage: 5 (SQLite, FFI web, preferences, paths, path)
- UI/Design: 5 (Fonts, charts, animations)
- Platform: 3 (Permissions, sharing, I/O)
- Utilities: 2 (intl, uuid)
- Development: 2 (Lints, tests)

---

## 5. RUNNING THE APP - QUICK START GUIDE

### 5.1 Prerequisites
**Required:**
- Flutter SDK installed and in PATH
- Visual Studio Code or Android Studio
- Project setup: `flutter pub get` and `flutter gen-l10n` already run

**Check setup:**
```powershell
flutter doctor
```

---

### 5.2 RUN IN CHROME (Web Browser)

#### Step 1: Open PowerShell in project folder
```powershell
cd d:\antigrapp
```

#### Step 2: Run in Chrome
```powershell
flutter run -d chrome
```

**Output:**
```
Launching lib/main.dart on Chrome in debug mode...
Building Chrome application for debug...
✓ Build complete! (XX.XXs)

Waiting for connection from debug service on Chrome...
✓ Connected!
```

#### Step 3: Access the app
- Chrome opens automatically at: **http://localhost:53131/**
- App displays with full features:
  - ✅ Gallery/image picker works
  - ✅ SQLite database works (via FFI/WASM)
  - ✅ All UI features work
  - ❌ Live camera NOT available (use gallery instead)

#### Step 4: Hot reload
- Press **R** in terminal to reload code changes
- Press **Q** to quit

**Keyboard shortcuts:**
```
R - Hot reload
Q - Quit
L - Toggle debug logs
P - Toggle performance overlay
```

---

### 5.3 RUN ON ANDROID PHONE (Wireless)

#### Option A: First Time (USB Required)

**Step 1: Enable USB Debugging on Phone**
```
Settings → About Phone → Tap "Build Number" 7 times
  → Developer options appears
  → Settings → Developer Options → USB Debugging → ON
  → Settings → Developer Options → Wireless Debugging → ON
```

**Step 2: Connect via USB**
```powershell
# Plug phone into computer via USB
# Allow debugging prompt on phone → Tap "Allow"

# Verify connection
flutter devices
# Output should show: device_id  •  Your Phone Model (Android X.X)
```

**Step 3: Get phone IP address**
```powershell
# On phone: Settings → Developer Options → Wireless Debugging
# Note the IP address and port (e.g., 192.168.1.100:5555)
```

**Step 4: Connect wirelessly (one-time setup)
```powershell
# While connected via USB:
adb tcpip 5555

# Connect to phone's IP
adb connect 192.168.1.100:5555
# Replace with your phone's IP from step 3

# Verify connection
adb devices
# Output: 192.168.1.100:5555 device
```

**Step 5: Disconnect USB and run app
```powershell
# Now you can disconnect USB cable

flutter run
# Select your phone if multiple devices

# OR specify device ID
flutter run -d 192.168.1.100:5555
```

#### Option B: Reconnect Wireless (Next Time)

**Quick reconnect:**
```powershell
# Open phone Developer Options → Wireless Debugging
# Note IP address shown

adb connect 192.168.1.100:5555  # Use your phone's IP
flutter run -d 192.168.1.100:5555
```

#### Troubleshooting Android

**Problem: "adb: command not found"**
```powershell
# Add Android SDK tools to PATH
# Or use full path: C:\Android\platform-tools\adb
```

**Problem: "Connection refused"**
```powershell
# Make sure Wireless Debugging is ON on phone
# Make sure phone and PC on same WiFi network
# Try restarting adb:
adb kill-server
adb devices
```

**Problem: App won't start**
```powershell
# Clear app data
flutter clean
flutter pub get
flutter run -d 192.168.1.100:5555
```

---

### 5.4 RUN ON iOS PHONE (Wireless)

#### Prerequisites (Mac Required)
- **iOS development requires a Mac** (Windows cannot build for iOS natively)
- Xcode installed on Mac
- Apple Developer account (free or paid)
- iPhone with iOS 12.0+

#### Option A: From Mac (if available)

**Step 1: Enable Developer Mode on iPhone**
```
Settings → Privacy & Security → Developer Mode → ON
  → Restart phone
```

**Step 2: Trust certificate**
```
Settings → General → Device Management
  → Trust your Apple Developer Certificate
```

**Step 3: Run from Mac**
```bash
cd /path/to/antigrapp

# List iOS devices
flutter devices

# Run on phone
flutter run
# OR specify device
flutter run -d <device_id>
```

**Step 4: Keep phone on same WiFi**
- Make sure iPhone and Mac on same WiFi network
- Phone can be locked, but must stay awake initially

#### Option B: Remote Build from Windows (Advanced)

If you have a Mac available remotely:

**Step 1: On Mac - Enable SSH**
```bash
System Preferences → Sharing → Remote Login → ON
```

**Step 2: On Windows - Connect via SSH**
```powershell
ssh user@mac_ip_address
cd /path/to/antigrapp
flutter run
```

**Step 3: Follow prompts on Mac**

#### iOS Build for Release

```bash
# On Mac:
flutter build ios --release

# Output: build/ios/iphoneos/Runner.app
# Can be submitted to App Store
```

#### Troubleshooting iOS

**Problem: "iOS deployment target must be 11.0 or greater"**
```bash
# Update iOS minimum version in Xcode
# Or edit: ios/Podfile
platform :ios, '12.0'
flutter pub get
```

**Problem: Xcode build fails**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

**Problem: Device not showing in flutter devices**
```bash
# Unplug and replug phone
# Tap "Trust" on phone
# Run: killall -9 usbmuxd
```

---

### 5.5 COMPARISON TABLE

| Platform | Setup Time | Wireless | Camera | Database | Best For |
|----------|-----------|----------|--------|----------|----------|
| **Chrome (Web)** | 1 minute | ✅ | ❌ (use gallery) | ✅ (FFI) | Quick testing, UI work |
| **Android** | 10 minutes | ✅ | ✅ | ✅ | Main testing, real hardware |
| **iOS** | 30 minutes | ✅ (needs Mac) | ✅ | ✅ | Apple device testing |

---

### 5.6 QUICK START COMMANDS

**Chrome:**
```powershell
flutter run -d chrome
```

**Android (first time):**
```powershell
# USB cable required first
adb tcpip 5555
adb connect YOUR_PHONE_IP:5555
flutter run -d YOUR_PHONE_IP:5555
```

**Android (next times):**
```powershell
adb connect YOUR_PHONE_IP:5555
flutter run
```

**iOS (Mac only):**
```bash
flutter run
```

---

### 5.7 CHECKING CONNECTED DEVICES

```powershell
flutter devices

# Output example:
# 2 connected devices:
#
# Chrome (web)                     • chrome                    • web-javascript    • Google Chrome 120.0
# Samsung SM-G991B (mobile)        • 192.168.1.100:5555       • android-arm64     • Android 13 (API 33)
```

---

### 5.8 COMMON ISSUES & SOLUTIONS

| Issue | Cause | Solution |
|-------|-------|----------|
| `flutter: command not found` | Flutter not in PATH | Add Flutter bin to PATH |
| `adb: command not found` | ADB not in PATH | Use full path to adb or add to PATH |
| Chrome not opening | Port conflict | Try: `flutter run -d chrome --web-port=7777` |
| Phone not found | Not on same network | Check WiFi connection |
| Build fails | Outdated packages | Run: `flutter clean && flutter pub get` |
| App crashes on startup | Database error | Clear app data on phone |

---

### 5.9 DEVELOPMENT WORKFLOW

**Typical development loop:**

```powershell
# 1. Start app on device
flutter run -d 192.168.1.100:5555

# 2. Make code changes in VS Code

# 3. Save file → Flutter hot reloads automatically

# 4. See changes instantly on device

# 5. Press 'R' in terminal to force reload if needed

# 6. Press 'Q' to stop when done
```

---

### 5.10 BUILDING FOR PRODUCTION

**Android APK (shareable file):**
```powershell
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
# ~50MB file - can install on any Android phone
```

**Android App Bundle (for Google Play Store):**
```powershell
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
# Google Play handles device-specific versions
```

**iOS App (Mac required):**
```bash
flutter build ios --release
# Output: build/ios/iphoneos/Runner.app
# Can submit to App Store
```

**Web (for hosting):**
```powershell
flutter build web --release
# Output: build/web/
# Deploy to Firebase Hosting, Vercel, etc.
```

---

## 6. ADVANCED CONFIGURATIONS

### 6.1 Custom Web Port
```powershell
flutter run -d chrome --web-port=8000
# Runs on http://localhost:8000/
```

### 6.2 Run with VM Service Port
```powershell
flutter run --web-port=8080 -d chrome
```

### 6.3 Disable Hot Reload
```powershell
flutter run --no-hot
```

### 6.4 Run with Verbose Logging
```powershell
flutter run -v
# Shows detailed debug information
```

### 6.5 Profile Mode (Performance Testing)
```powershell
flutter run --profile -d 192.168.1.100:5555
# Optimized for performance testing
```

---

**END OF REPORT**

*This comprehensive technical report covers architecture patterns, programming languages, library selection, implementation details, and step-by-step instructions for running the NumiIT Flutter project on multiple platforms.*
