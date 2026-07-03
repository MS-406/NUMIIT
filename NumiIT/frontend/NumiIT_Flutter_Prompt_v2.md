# NumiIT — Flutter Mobile App: Complete Build Prompt (v2)

> Copy this entire prompt into your Flutter AI assistant (Cursor, Claude Code, GitHub Copilot, etc.) to scaffold the complete NumiIT coin inscription recognition app.

---

## ⚠️ CRITICAL CONSTRAINTS — READ FIRST

1. **Pure Flutter only.** Do NOT write any Kotlin, Java, Swift, or Objective-C code anywhere. No platform channels, no method channels, no native Android/iOS modules. Every single feature — camera, permissions, storage, file handling — must be implemented using Flutter/Dart packages only.

2. **No ML / AI / detection APIs.** Do NOT integrate TensorFlow Lite, ML Kit, Google Vision, Firebase ML, OpenCV, any REST-based AI/OCR APIs, or any other ML framework. The detection and recognition logic will be provided later as a backend + ML API by the developer. For now, build a **clean stub (`MLService`)** that returns hardcoded mock data. All ML call sites must be clearly marked with `// TODO: Replace with real ML API call` comments so integration is seamless later.

3. **No external API calls of any kind** in the current build — no HTTP calls, no network requests. The app must work fully offline with mock data only.

---

## PROJECT OVERVIEW

Build **NumiIT** — a Flutter mobile-first app for AI-powered recognition of inscriptions on ancient Indian coins. The app captures coin photos, passes them to the ML service (stubbed for now), displays detection bounding boxes, transliterates & translates inscriptions from 6 ancient scripts (Brahmi, Kharoshthi, Persian, Urdu, Arabic, Pali), and maintains a local scan history.

**Platform target:** Android & iOS — implemented 100% in Flutter/Dart. No native code.

**Tech Stack:**
- Flutter (latest stable, null-safe) — **pure Dart/Flutter only**
- `sqflite` for local SQLite persistence
- `camera` package for live viewfinder
- `image_picker` for gallery import
- `flutter_riverpod` for state management
- `shared_preferences` for settings/language
- `intl` for i18n (English, Hindi, Gujarati)
- `share_plus` for native share sheet
- `path_provider` for file storage
- `google_fonts` for typography
- `lottie` for loading animations
- `fl_chart` for confidence bar visuals
- `permission_handler` for runtime permissions (Flutter package only — no native code)

---

## DESIGN SYSTEM

### Colors (define as `AppColors` constants)
```dart
const Color primaryDark    = Color(0xFF1A1A2E);   // Deep navy — primary bg
const Color primaryMid     = Color(0xFF16213E);   // Slightly lighter navy
const Color accent         = Color(0xFFE9C46A);   // Gold — CTAs, highlights
const Color accentAlt      = Color(0xFFF4A261);   // Warm amber — secondary accent
const Color surface        = Color(0xFFF8F9FC);   // Light bg for content screens
const Color surfaceCard    = Color(0xFFFFFFFF);   // Card white
const Color textPrimary    = Color(0xFF1A1A2E);
const Color textSecondary  = Color(0xFF888888);
const Color successGreen   = Color(0xFF2E7D32);
const Color warningOrange  = Color(0xFFE65100);
const Color confHighBg     = Color(0xFFE8F5E9);
const Color confMedBg      = Color(0xFFFFF3E0);
const Color brahmiBlue     = Color(0xFF4A6CF7);   // Script label color
```

### Typography
- Display/titles: `GoogleFonts.playfairDisplay` (serif, regal feel for numismatic theme)
- Body/UI: `GoogleFonts.dmSans` (clean, readable)
- Script text (Brahmi, Arabic etc.): `GoogleFonts.notoSans` (covers Unicode ancient scripts)

### Spacing (use `AppSpacing` constants)
```dart
const double xs = 4, sm = 8, md = 16, lg = 24, xl = 32, xxl = 48;
```

### Border Radius
```dart
const double radiusSm = 8, radiusMd = 12, radiusLg = 16, radiusXl = 20, radiusFull = 100;
```

---

## APP ARCHITECTURE

```
lib/
├── main.dart
├── app.dart                        # MaterialApp, theme, routes
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   └── app_spacing.dart
│   ├── models/
│   │   ├── scan_result.dart        # Main data model
│   │   ├── detected_region.dart    # Bounding box + script detection
│   │   └── coin_inscription.dart   # Translation result model
│   ├── database/
│   │   ├── db_helper.dart          # SQLite setup, CRUD
│   │   └── scan_repository.dart    # Repository pattern
│   ├── services/
│   │   ├── ml_service.dart         # STUB ONLY — returns mock data, ML will be plugged in later
│   │   ├── image_service.dart      # Camera + gallery + preprocessing (Flutter only)
│   │   └── share_service.dart      # Share sheet logic
│   └── providers/
│       ├── scan_provider.dart
│       ├── history_provider.dart
│       └── settings_provider.dart
├── features/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── widgets/
│   │       ├── scan_hero_card.dart
│   │       ├── quick_action_grid.dart
│   │       ├── recent_scans_list.dart
│   │       └── stats_bar.dart
│   ├── camera/
│   │   ├── camera_screen.dart
│   │   └── widgets/
│   │       ├── viewfinder_overlay.dart
│   │       ├── corner_brackets.dart
│   │       ├── camera_controls.dart
│   │       └── mode_selector.dart
│   ├── detection/
│   │   ├── detection_screen.dart
│   │   └── widgets/
│   │       ├── bounding_box_overlay.dart
│   │       ├── detection_card.dart
│   │       └── processing_steps.dart
│   ├── result/
│   │   ├── result_screen.dart
│   │   └── widgets/
│   │       ├── coin_image_preview.dart
│   │       ├── result_tab_bar.dart
│   │       ├── translation_tab.dart
│   │       ├── transliteration_tab.dart
│   │       ├── details_tab.dart
│   │       └── confidence_bar.dart
│   ├── history/
│   │   ├── history_screen.dart
│   │   └── widgets/
│   │       ├── history_card.dart
│   │       ├── script_filter_chips.dart
│   │       └── search_bar.dart
│   └── settings/
│       └── settings_screen.dart
└── shared/
    ├── widgets/
    │   ├── app_bottom_nav.dart
    │   ├── gold_button.dart
    │   ├── ghost_button.dart
    │   ├── confidence_badge.dart
    │   ├── script_tag.dart
    │   └── empty_state.dart
    └── utils/
        ├── date_formatter.dart
        └── confidence_utils.dart
```

---

## ML SERVICE — STUB SPECIFICATION

> **This is the most important architectural piece.** Build it as a clean interface so the real ML backend can be dropped in later without touching any other file.

```dart
// lib/core/services/ml_service.dart

abstract class MLService {
  /// Takes a local image file path, returns detected regions.
  /// TODO: Replace stub implementation with real ML API call when backend is ready.
  Future<List<DetectedRegion>> analyzeImage(String imagePath);
}

/// Stub implementation — returns hardcoded mock data.
/// Replace this class body entirely when integrating the real ML API.
class MLServiceStub implements MLService {
  @override
  Future<List<DetectedRegion>> analyzeImage(String imagePath) async {
    // Simulate network/processing delay
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Replace with real ML API call
    // The real implementation will:
    //   1. Send imagePath (or base64 image bytes) to the ML backend
    //   2. Receive bounding boxes, script labels, transcriptions, translations
    //   3. Map the response to List<DetectedRegion>

    return _mockRegions;
  }

  static final List<DetectedRegion> _mockRegions = [
    DetectedRegion(
      regionIndex: 0,
      boundingBox: const Rect.fromLTWH(0.1, 0.15, 0.8, 0.3),
      scriptName: 'Brahmi',
      originalText: '𑀅𑀲𑁄𑀓',
      transliteration: 'Asoka',
      translation: 'King Ashoka',
      dynastyContext: 'Maurya Empire (~268–232 BCE)',
      confidence: 0.92,
      glyphCount: 4,
    ),
    DetectedRegion(
      regionIndex: 1,
      boundingBox: const Rect.fromLTWH(0.1, 0.55, 0.8, 0.25),
      scriptName: 'Pali',
      originalText: 'धम्म',
      transliteration: 'Dhamma',
      translation: 'Righteousness / The Teaching',
      dynastyContext: 'Maurya Empire (~268–232 BCE)',
      confidence: 0.85,
      glyphCount: 3,
    ),
  ];
}
```

The `MLService` abstract class must be registered via Riverpod so the stub can be swapped to a real implementation with a single line change:

```dart
// lib/core/providers/scan_provider.dart
final mlServiceProvider = Provider<MLService>((ref) => MLServiceStub());
// When backend is ready, change to: => MLServiceReal(baseUrl: '...')
```

---

## DATA MODELS

### `ScanResult` (core model)
```dart
class ScanResult {
  final int? id;
  final String imageLocalPath;      // saved to app documents dir
  final String imageThumbnailPath;
  final DateTime scannedAt;
  final List<DetectedRegion> regions;
  final String primaryScript;       // highest-confidence script
  final double primaryConfidence;
  final String? notes;              // user-added notes
  bool isSaved;                     // pinned to history

  // computed
  String get confidenceLabel => primaryConfidence >= 0.8 ? 'high' : 'med';
}
```

### `DetectedRegion`
```dart
class DetectedRegion {
  final int regionIndex;
  final Rect boundingBox;           // normalized 0..1 coordinates
  final String scriptName;          // 'Brahmi' | 'Kharoshthi' | 'Persian' | 'Urdu' | 'Arabic' | 'Pali'
  final String originalText;        // Unicode inscription
  final String transliteration;     // Romanized
  final String translation;         // English
  final String dynastyContext;      // e.g. "Kushan Empire"
  final double confidence;
  final int glyphCount;
}
```

### SQLite Schema
```sql
CREATE TABLE scans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  image_path TEXT NOT NULL,
  thumbnail_path TEXT NOT NULL,
  scanned_at TEXT NOT NULL,
  primary_script TEXT,
  primary_confidence REAL,
  regions_json TEXT,   -- JSON-encoded List<DetectedRegion>
  notes TEXT,
  is_saved INTEGER DEFAULT 0
);
```

---

## SCREEN-BY-SCREEN SPECIFICATION

---

### SCREEN 1 — Splash / Welcome

**File:** `lib/features/splash/splash_screen.dart`

**Design:**
- Full screen gradient background: `LinearGradient([primaryDark, primaryMid], begin: top, end: bottom)`
- Center-aligned content with staggered fade-in animations (use `AnimationController` with sequential delays: 300ms, 600ms, 900ms, 1200ms)

**Elements:**
1. **Logo container** (120×120, borderRadius 28, `Colors.white10` bg, gold dashed border)
   - Icon: coin outline with "N" monogram in accent gold (Flutter `CustomPaint` or `Icon`)
   - Add subtle rotation animation on load (0° → 360° over 1.2s, ease-out)

2. **App title** "NumiIT" — `PlayfairDisplay`, 38sp, bold, white, letterSpacing -1

3. **Tagline** "Decoding India's Numismatic Heritage\nAI-powered coin inscription recognition"
   - `DmSans`, 14sp, `Colors.white60`, centered, lineHeight 1.6

4. **Primary CTA** — `GoldButton(label: 'Scan a Coin', icon: Icons.camera_alt)`
   - Background: accent (#E9C46A), text: primaryDark, radius 14, padding 16v×32h
   - onTap → navigate to CameraScreen

5. **Secondary CTA** — `GhostButton(label: 'Browse History')`
   - Border: `Colors.white24`, text: white, same sizing
   - onTap → navigate to HistoryScreen

6. **Language selector row** — "English · हिन्दी · ગુજરાતી"
   - Small text, tapping each sets locale via `SettingsProvider`
   - Currently active language highlighted in accent gold

7. **Version tag** at very bottom — `v1.0.0 · NumiIT`, 11sp, white30

**Extra feature:** On first launch only, show a 3-step onboarding overlay (slide-up modal) explaining: Scan → Detect → Translate. After "Got It", mark `onboarding_done = true` in SharedPreferences and never show again.

---

### SCREEN 2 — Home Dashboard

**File:** `lib/features/home/home_screen.dart`

**Design:**
- Background: `surface` (#F8F9FC)
- Scrollable `CustomScrollView` with `SliverAppBar` (collapsing)

**Elements:**

1. **SliverAppBar** (collapsing, not pinned)
   - Expanded: greeting "Hello, Researcher 👋" + date subtitle
   - Collapsed: "NumiIT" centered title + avatar icon (right)
   - Avatar: 40×40 circle, initials or profile emoji, taps → SettingsScreen

2. **Hero Scan Card** (`scan_hero_card.dart`)
   - Full-width card, gradient `primaryDark → primaryMid`, border-radius 20
   - Coin watermark icon (top-right, white10)
   - "Ready to decode ancient inscriptions?" headline
   - Sub-text: "Point your camera at a coin inscription"
   - `GoldButton('Start Scanning')` → CameraScreen
   - Animated shimmer effect on the card on first render

3. **Quick Actions Grid** (2×2) — `quick_action_grid.dart`
   - "Scan Coin" (camera icon, accent bg)
   - "Gallery Import" (photo icon)
   - "Coin Encyclopedia" (book icon)
   - "Statistics" (bar chart icon)
   - Tapping each navigates to the respective screen

4. **Stats Bar** — `stats_bar.dart`
   - 3 columns: Total Scans | Scripts Found | This Week
   - Values animated (count-up on first render)

5. **Recent Scans** (last 5 from SQLite) — `recent_scans_list.dart`
   - "Recent Scans" header + "See All →" link
   - Each item: thumbnail | script tag | confidence badge | timestamp
   - Taps → ResultScreen with that ScanResult
   - Empty state widget if no history yet

---

### SCREEN 3 — Camera Capture

**File:** `lib/features/camera/camera_screen.dart`

**Implementation notes:**
- Use the `camera` Flutter package only. No native camera code.
- Request camera permission using `permission_handler` Flutter package.
- If permission denied, show an in-app error widget (not a native dialog) with a "Open Settings" button using `permission_handler`'s `openAppSettings()`.

**Elements:**

1. **Full-screen camera preview** (`CameraPreview` widget)
   - Black letterbox areas filled with `primaryDark`

2. **Viewfinder Overlay** — `viewfinder_overlay.dart`
   - Semi-transparent dark vignette around the circular/oval coin guide
   - Animated corner brackets (gold, `CustomPaint`) that pulse on idle
   - Center guide oval: dashed gold border, "Position coin here" text below

3. **Mode Selector** (top) — `mode_selector.dart`
   - Toggle pills: "Photo" | "Live" (Live mode is UI-only for now, disabled with "Coming Soon" tooltip)

4. **Camera Controls** (bottom bar) — `camera_controls.dart`
   - Left: Gallery import button (opens `image_picker`) — Flutter package only
   - Center: Shutter button (60px, white, scale-bounce animation on press)
   - Right: Flip camera button (front/back toggle)
   - On capture: brief flash overlay animation, then navigate to DetectionScreen

5. **Top bar**
   - Back arrow, "Scan Coin" title, flash toggle icon

---

### SCREEN 4 — Detection / Processing

**File:** `lib/features/detection/detection_screen.dart`

**Flow:**
```
Receive imagePath → Show processing UI → Call MLService.analyzeImage(imagePath) → Show results overlay
```

**Processing UI (while awaiting MLService):**
- Full-screen dark bg with the captured coin image (slightly dimmed)
- Animated scanning line sweeping top-to-bottom (looping, Lottie or custom `AnimationController`)
- Processing steps list (fade in one by one, 400ms each):
  1. ✓ Image captured
  2. ⟳ Preprocessing image...
  3. ⟳ Detecting inscription regions...
  4. ⟳ Identifying scripts...
  5. ⟳ Preparing translations...
- Bottom card: "Analyzing ancient inscriptions..." with `LinearProgressIndicator`

**Results UI (after MLService returns):**
- Coin image displayed with **bounding box overlays** (`bounding_box_overlay.dart`)
  - Each box: colored border matching script color, staggered scale-in animation
  - Small script label chip floating above each box
- Bottom sheet (draggable): list of `DetectionCard` widgets per region
  - Each card: region number, script tag, confidence badge, inscription preview
  - Tapping "View Full Result →" navigates to ResultScreen

**Empty detection state:**
- "No inscriptions detected" illustration + "Try Again" button

---

### SCREEN 5 — Result Detail

**File:** `lib/features/result/result_screen.dart`

**Elements:**

1. **Coin Image Preview** — `coin_image_preview.dart`
   - Full-width image with bounding boxes drawn via `CustomPaint`
   - Tap to open full-screen `photo_view` zoom viewer

2. **Primary result header**
   - Script tag + confidence badge + dynasty context text

3. **Tab Bar** — `result_tab_bar.dart`
   - 3 tabs: Translation | Transliteration | Details

4. **Translation Tab** — `translation_tab.dart`
   - Original inscription (large, NotoSans, RTL support where needed)
   - Divider
   - English translation (DmSans, body text)
   - Dynasty/historical context card (amber accent bg)

5. **Transliteration Tab** — `transliteration_tab.dart`
   - Original script → Romanized text side by side
   - Glyph count badge
   - "Copy to clipboard" button

6. **Details Tab** — `details_tab.dart`
   - Confidence bar (`fl_chart` horizontal bar, animated)
   - Script info (period, Unicode block)
   - Scan metadata (date, image dimensions)

7. **Action bar (bottom)**
   - "Save to History" (`GoldButton`)
   - "Share" (ghost button → `share_plus`)
   - "Scan Again" (text button)

8. **Researcher Notes** field
   - Expandable text input, saves to SQLite via `ScanRepository`

---

### SCREEN 6 — History

**File:** `lib/features/history/history_screen.dart`

**Elements:**

1. **Search bar** — `search_bar.dart`
   - Filters history list in real time (by script, translation text, date)

2. **Script filter chips** — `script_filter_chips.dart`
   - Horizontal scrollable chips: All | Brahmi | Kharoshthi | Persian | Urdu | Arabic | Pali
   - Active chip: accent gold bg

3. **History list** — `HistoryCard` per item
   - Thumbnail (60×60, rounded) | Script tag | Confidence badge
   - Primary inscription preview (1 line, NotoSans)
   - Relative timestamp (e.g. "2 days ago")
   - Swipe-to-delete with confirmation
   - Long-press → context menu: View, Share, Delete, Add Note

4. **Sort options** (dropdown): Newest | Oldest | Highest Confidence | Script A–Z

5. **Empty state**: illustration + "No scans yet. Start by scanning a coin!"

6. **Shimmer skeleton** loading while SQLite query runs

---

### SCREEN 7 — Settings

**File:** `lib/features/settings/settings_screen.dart`

**Sections:**

1. **App Language** — English / हिन्दी / ગુજરાતી (radio tiles, persisted in SharedPreferences)
2. **Appearance** — Light / Dark / System (theme toggle)
3. **Confidence Threshold** — Slider 50%–95%, below which results show a warning
4. **Data Management**
   - Export history (CSV) via `share_plus`
   - Export history (JSON) via `share_plus`
   - Clear all history (confirmation dialog)
5. **About** — App version, build number, "About NumiIT" text
6. **Onboarding** — "Show intro again" button (resets SharedPreferences flag)

---

### SCREEN 8 — Coin Encyclopedia (static)

**File:** `lib/features/encyclopedia/encyclopedia_screen.dart`

Static data screen — no API calls. Data hardcoded in Dart.

**For each of the 6 scripts:**
- Script name + native name
- Historical period
- Sample coin inscription text (Unicode) + transliteration + English meaning
- Unicode block reference
- Color-coded `ScriptTag`

---

### SCREEN 9 — Statistics Dashboard

**File:** `lib/features/stats/stats_screen.dart`

Uses `fl_chart` only (no external APIs).

- **Pie chart**: breakdown of scans by script type (reads from SQLite)
- **Bar chart**: scans per day over last 7 days
- **Summary cards**: total scans, most common script, average confidence

---

## ROUTING (go_router)

```dart
final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/camera', builder: (_, __) => const CameraScreen()),
    GoRoute(
      path: '/detection',
      builder: (_, state) => DetectionScreen(imagePath: state.extra as String),
    ),
    GoRoute(
      path: '/result',
      builder: (_, state) => ResultScreen(scanResult: state.extra as ScanResult),
    ),
    GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/encyclopedia', builder: (_, __) => const EncyclopediaScreen()),
    GoRoute(path: '/stats', builder: (_, __) => const StatsScreen()),
  ],
);
```

---

## STATE MANAGEMENT (Riverpod)

```dart
final mlServiceProvider    = Provider<MLService>((ref) => MLServiceStub());
// ↑ When backend is ready, swap to: MLServiceReal(baseUrl: 'https://...')

final scanRepositoryProvider = Provider<ScanRepository>((ref) => ScanRepository());
final historyProvider      = AsyncNotifierProvider<HistoryNotifier, List<ScanResult>>(...);
final currentScanProvider  = StateProvider<ScanResult?>((ref) => null);
final settingsProvider     = NotifierProvider<SettingsNotifier, AppSettings>(...);
```

---

## DATABASE HELPER

```dart
class DbHelper {
  static final DbHelper instance = DbHelper._();
  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'numiit.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_path TEXT NOT NULL,
        thumbnail_path TEXT NOT NULL,
        scanned_at TEXT NOT NULL,
        primary_script TEXT,
        primary_confidence REAL,
        regions_json TEXT,
        notes TEXT,
        is_saved INTEGER DEFAULT 0
      )
    ''');
  }

  // CRUD methods: insertScan, getAllScans, getScanById,
  // searchScans(query, scripts), updateScan, deleteScan, clearAll
}
```

---

## SHARED WIDGETS

### `GoldButton`
```dart
ElevatedButton with:
  - background: AppColors.accent
  - foreground: AppColors.primaryDark
  - borderRadius: 14
  - padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32)
  - textStyle: DmSans bold 15sp
  - optional leading icon
  - loading state (CircularProgressIndicator replacing icon)
```

### `ConfidenceBadge`
```dart
// Green if >= 0.8, orange if >= 0.6, red otherwise
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  decoration: BoxDecoration(
    color: high ? confHighBg : confMedBg,
    borderRadius: BorderRadius.circular(6),
  ),
  child: Text('${(confidence * 100).round()}%', style: ...),
)
```

### `ScriptTag`
```dart
final scriptColors = {
  'Brahmi':     Color(0xFF4A6CF7),
  'Kharoshthi': Color(0xFF9C27B0),
  'Persian':    Color(0xFF00897B),
  'Urdu':       Color(0xFFE91E63),
  'Arabic':     Color(0xFF1565C0),
  'Pali':       Color(0xFF6D4C41),
};
```

### `AppBottomNav`
- 4 items: Home (house), Scan (camera, FAB-style elevated), History (clock), Settings (gear)
- Active indicator: small gold dot above icon
- Scan button: slightly elevated, accent gold background

---

## PERMISSIONS

Use `permission_handler` Flutter package for all permissions. **No native Android/iOS permission code.**

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<!-- Only declare permissions here; all runtime request logic is in Flutter via permission_handler -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

```
<!-- ios/Runner/Info.plist -->
NSCameraUsageDescription → "NumiIT needs camera access to scan coin inscriptions"
NSPhotoLibraryUsageDescription → "NumiIT needs photo library access to import coin images"
```

Permission request logic in Dart:
```dart
// lib/core/services/image_service.dart
Future<bool> requestCameraPermission() async {
  final status = await Permission.camera.request();
  return status.isGranted;
}
```

---

## pubspec.yaml DEPENDENCIES

```yaml
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.11.0
  image_picker: ^1.0.0
  sqflite: ^2.3.0
  path_provider: ^2.1.0
  path: ^1.8.0
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  go_router: ^13.0.0
  google_fonts: ^6.1.0
  share_plus: ^7.2.0
  shared_preferences: ^2.2.0
  intl: ^0.18.0
  lottie: ^3.0.0
  fl_chart: ^0.66.0
  photo_view: ^0.14.0
  image: ^4.1.0
  permission_handler: ^11.0.0
  flutter_animate: ^4.3.0
  shimmer: ^3.0.0
  uuid: ^4.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
```

> **Do not add** `tflite_flutter`, `google_mlkit_*`, `firebase_ml_vision`, `http`, `dio`, or any networking/ML package. These will be added later when the backend is ready.

---

## ANIMATION GUIDELINES

- Screen transitions: `FadeTransition` + slight `SlideTransition` (subtle, 250ms)
- Detection bounding boxes: staggered `ScaleTransition` + `FadeTransition`
- Confidence bars: `Tween<double>` animated on mount (500ms, ease-out)
- Home stats counter: `AnimatedCounter` widget (count up from 0)
- Card entrance: `SlideTransition` from bottom (index * 80ms delay)
- Shutter button: scale bounce on press (`ScaleTransition`, 0.95 → 1.05 → 1.0)
- Processing scanner line: looping `AnimationController` (linear, 1.5s cycle)

---

## LOCALIZATION

Create `lib/l10n/` with `app_en.arb`, `app_hi.arb`, `app_gu.arb`:

```json
{
  "appTitle": "NumiIT",
  "scanNow": "Scan Now",
  "browseHistory": "Browse History",
  "detectingScript": "Detecting script regions...",
  "translationResult": "Translation Result",
  "saveToHistory": "Save to History",
  "scanAgain": "Scan Again",
  "confidence": "Confidence",
  "detectedScript": "Detected Script",
  "originalInscription": "Original Inscription",
  "transliteration": "Transliteration",
  "englishTranslation": "English Translation"
}
```

---

## EXTRA FEATURES (implement all)

1. **Onboarding Flow** — 3-screen walkthrough on first launch (SharedPreferences flag)
2. **Dark Mode** — full dark theme using `ThemeData.dark()` with custom color overrides
3. **Coin Encyclopedia** — static screen for all 6 scripts (hardcoded Dart data, no API)
4. **Statistics Dashboard** — pie/bar charts using `fl_chart` (reads from local SQLite only)
5. **CSV/JSON Export** — exports all history via `share_plus`
6. **Image Zoom Viewer** — full-screen zoomable image via `photo_view` package
7. **Batch Gallery Import** — pick multiple images, queue them (ML stub processes each sequentially)
8. **Researcher Notes** — add free-text notes to any saved scan
9. **Bookmark/Starred Scans** — pin important scans to top of history
10. **Confidence Threshold Setting** — user sets minimum confidence to auto-save results
11. **Haptic Feedback** — on scan capture, detection complete, save (Flutter `HapticFeedback` class)
12. **Deep Links** — `numiit://result/:id` opens specific scan result
13. **Accessibility** — semantic labels on all interactive elements, minimum 44px touch targets
14. **Error States** — no camera permission, blurry image (mock), ML stub failure — all handled with clear UX
15. **Shimmer Loading** — skeleton loaders while history loads from SQLite

---

## TESTING CHECKLIST

- [ ] Camera permission denied → graceful in-app error screen (Flutter only, no native dialogs)
- [ ] Image captured → MLServiceStub returns mock data correctly
- [ ] MLServiceStub delay simulates real processing (2s)
- [ ] Bounding boxes render correctly on image
- [ ] SQLite CRUD (insert, fetch, delete, search)
- [ ] Export generates valid CSV and JSON
- [ ] Dark mode correct on all screens
- [ ] Bottom nav preserves scroll state when switching tabs
- [ ] Back navigation from result → does not re-run MLService
- [ ] Large history list (100+ mock items) scrolls smoothly
- [ ] No `http`, `dio`, or network calls anywhere in the codebase
- [ ] No Kotlin/Java/Swift/ObjC files created or modified

---

## ML INTEGRATION GUIDE (for later)

When the backend and ML APIs are ready, only these changes are needed:

1. Create `lib/core/services/ml_service_real.dart` implementing `MLService`
2. In `ml_service_real.dart`, make HTTP POST to your backend with image bytes
3. Map the response JSON to `List<DetectedRegion>`
4. In `scan_provider.dart`, change one line:
   ```dart
   // Before:
   final mlServiceProvider = Provider<MLService>((ref) => MLServiceStub());
   // After:
   final mlServiceProvider = Provider<MLService>((ref) => MLServiceReal(baseUrl: 'https://your-api.com'));
   ```
5. Add `http` or `dio` to pubspec.yaml at that point

No other files need to change.

---

*NumiIT Flutter Prompt v2.0 — Pure Flutter, ML Stub Architecture*
*Ready for ML backend integration when APIs are available*
