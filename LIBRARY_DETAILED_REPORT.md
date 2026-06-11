# NumiIT Project - Detailed Library & Dependency Report
**Project Name:** NumiIT (AI-powered Ancient Indian Coin Recognition App)  
**Framework:** Flutter  
**Dart SDK Version:** >=3.2.0 <4.0.0  
**Report Date:** June 10, 2026

---

## Overview

This document provides a comprehensive breakdown of every library/dependency used in the NumiIT Flutter project, explaining:
- **What it is:** The library's purpose
- **What it does:** Its functionality
- **Why it's used:** Business/technical justification
- **Where it's used:** Which features depend on it

---

## 1. CORE FRAMEWORK LIBRARIES

### 1.1 `flutter` (SDK)
**Version:** SDK (Latest)  
**Category:** Core Framework

**What it is:**
Flutter is the primary development framework created by Google.

**What it does:**
- Provides the foundation for building multi-platform apps from a single codebase
- Compiles Dart code into native code for Android, iOS, and web platforms
- Supplies the Material Design UI components and rendering engine
- Handles app lifecycle management, widgets, and rendering

**Why it's used:**
- **Cross-platform development:** One codebase runs on Android, iOS, and web simultaneously
- **Performance:** Compiles to native code instead of interpreting (unlike React Native)
- **Hot reload:** Instant code changes during development (speeds up iteration)
- **Rich component library:** Pre-built widgets save development time
- **Industry adoption:** Widely used; large community support and documentation

**Where it's used:**
- Every screen and widget in the app
- All UI rendering and interaction handling

---

### 1.2 `flutter_localizations` (SDK)
**Version:** SDK (Latest)  
**Category:** Localization

**What it is:**
Built-in Flutter library for internationalization support.

**What it does:**
- Provides localized strings for Flutter's built-in widgets (Material Design text, dialogs, buttons)
- Handles locale-specific formatting for dates, numbers, and text direction
- Manages language switching at runtime

**Why it's used:**
- **Multi-language support:** App supports English, Hindi, and Gujarati
- **Regional compliance:** Proper formatting for Indian languages and locales
- **User experience:** Automatic translations for system UI elements
- **Built-in solution:** No need for external localization package for core Flutter widgets

**Where it's used:**
- Settings screen (language selection)
- All localized app strings
- Date/time formatting in history and results

---

### 1.3 `cupertino_icons` (^1.0.8)
**Version:** 1.0.8 or compatible  
**Category:** UI Assets

**What it is:**
Icon set from Apple's iOS design system (Cupertino).

**What it does:**
- Provides Apple-style icons used in iOS apps
- Includes common icons (back arrow, menu, settings, etc.)
- Ensures iOS-native look and feel when needed

**Why it's used:**
- **iOS compatibility:** When running on iPad/iPhone, provides native-looking icons
- **Consistency:** Matches user expectations on Apple devices
- **Fallback icons:** Available for both iOS and Android UI styles
- **Performance:** Lightweight icon font, no image files

**Where it's used:**
- Navigation bar icons (on iOS devices)
- Button icons throughout the app

---

## 2. STATE MANAGEMENT & REACTIVITY

### 2.1 `flutter_riverpod` (^2.5.1)
**Version:** 2.5.1 or higher  
**Category:** State Management

**What it is:**
A modern, reactive state management solution for Flutter apps.

**What it does:**
- Manages app state (user settings, scan results, authentication status)
- Provides reactive updates when state changes
- Handles dependency injection and provider creation
- Enables code splitting and lazy loading of dependencies
- Automatically rebuilds only affected widgets when state changes
- Provides caching and invalidation mechanisms

**Why it's used:**
- **Modern architecture:** Replaces older Provider package; uses immutable state patterns
- **Better performance:** Only rebuilds widgets that depend on changed state
- **Testability:** Easily inject mock providers for testing
- **Code organization:** Centralized state management in providers
- **Type-safe:** Full type safety for state and arguments
- **Future-proof:** Official recommended state management solution

**Key providers in project:**
- `settingsProvider` - User theme, language, preferences
- `routerProvider` - Navigation state
- Scan result providers - History, detection results
- User authentication provider

**Where it's used:**
- [app.dart](app.dart) - Router and theme switching
- All feature screens - Reading and updating state
- Settings screen - Persisting user preferences
- History screen - Managing scan records

---

## 3. NAVIGATION & ROUTING

### 3.1 `go_router` (^14.2.7)
**Version:** 14.2.7 or higher  
**Category:** Navigation

**What it is:**
A declarative routing library for Flutter that replaces the traditional Navigator API.

**What it does:**
- Manages app navigation and screen transitions
- Handles deep linking (navigating to specific screens via URLs)
- Supports nested navigation with shell routes
- Maintains navigation state and back stack
- Enables parameterized routes (e.g., `/result/:id`)
- Provides type-safe route building

**Why it's used:**
- **Modern approach:** Declarative routing is cleaner than imperative Navigator
- **Deep linking:** Built-in support for sharing/notification links
- **Type safety:** Route parameters are type-checked
- **Shell routes:** Enables consistent layout wrapping (bottom nav, app bar persistence)
- **Web compatibility:** Works seamlessly on web platform
- **Future-proof:** Actively maintained; recommended by Flutter team

**Navigation structure:**
```
/ (Splash) → /login (Auth) → /home (Dashboard)
                            → /camera (Camera)
                            → /detection (Processing)
                            → /result/:id (Results)
                            → /history (Scan History)
                            → /settings (Settings)
                            → /encyclopedia (Reference)
                            → /statistics (Analytics)
                            → /profile (Profile)
```

**Where it's used:**
- [app.dart](app.dart) - Route definitions
- Navigation between screens
- Deep linking for notifications/share links
- URL-based navigation on web version

---

## 4. MEDIA & IMAGE CAPTURE

### 4.1 `camera` (^0.11.0+2)
**Version:** 0.11.0 or higher  
**Category:** Media Access

**What it is:**
Official Flutter plugin for accessing device camera hardware.

**What it does:**
- Accesses device camera hardware (front/back)
- Provides live camera preview stream
- Captures photos or videos
- Handles camera permissions
- Provides camera resolution control
- Manages flash and exposure settings

**Why it's used:**
- **Core feature:** The app's main purpose is scanning coin inscriptions with camera
- **Official support:** Created and maintained by Flutter/Google team
- **Hardware access:** Native bindings to Android/iOS camera APIs
- **Performance:** Direct hardware access without WebView limitations
- **Live preview:** Enables real-time camera feed display

**Where it's used:**
- Camera screen (features/camera/) - Live preview and photo capture
- Coin scanning workflow - Capturing images for detection
- Main feature: Camera app integration for inscriptions

---

### 4.2 `image_picker` (^1.1.2)
**Version:** 1.1.2 or higher  
**Category:** Media Access

**What it is:**
Official Flutter plugin for selecting images/videos from device gallery.

**What it does:**
- Opens device photo gallery/file picker
- Allows user to select existing images
- Supports multiple file format selection
- Returns image file path or bytes
- Shows native iOS/Android picker UI

**Why it's used:**
- **Flexibility:** Users can scan coins from their gallery without taking new photos
- **Offline support:** Can use previously saved coin images
- **Better UX:** Native picker ensures familiar user experience
- **Web support:** File picker works on browsers (camera doesn't)
- **Common need:** Standard feature for image-based apps

**Where it's used:**
- Camera screen - "Pick from Gallery" button
- Image selection for batch scanning
- Alternative to camera for detection

---

### 4.3 `image` (^4.2.0)
**Version:** 4.2.0 or higher  
**Category:** Image Processing

**What it is:**
Pure Dart library for image manipulation and processing.

**What it does:**
- Decodes images (PNG, JPEG, WebP, etc.)
- Encodes images to different formats
- Resizes, crops, and rotates images
- Applies filters and transformations
- Extracts image metadata
- Performs pixel-level operations

**Why it's used:**
- **Pre-processing:** Optimize images before sending to AI detection service
- **Performance:** Resize large photos to reduce bandwidth
- **Format conversion:** Convert between image formats if needed
- **Pure Dart:** No native dependencies; works on all platforms including web
- **Local processing:** Image processing doesn't require backend calls

**Where it's used:**
- Image preprocessing before sending to AI detection
- Gallery image optimization
- Photo viewing and manipulation
- Detection screen - Image preparation

---

### 4.4 `photo_view` (^0.15.0)
**Version:** 0.15.0 or higher  
**Category:** UI Component

**What it is:**
Flutter widget for viewing and interacting with images.

**What it does:**
- Displays images with pinch-to-zoom gesture support
- Enables pan (drag) functionality for large images
- Supports rotation and fit modes
- Handles double-tap to zoom
- Provides smooth animations

**Why it's used:**
- **UX enhancement:** Users can zoom into detection results to see details
- **Inspection:** Allows zooming on coin inscription results
- **Gestures:** Provides intuitive touch interactions
- **Performance:** Optimized image rendering for smooth interaction

**Where it's used:**
- Result screen - Viewing and zooming detection results
- History screen - Zooming into previous scan images
- Encyclopedia screen - Zooming reference coin images

---

## 5. LOCAL DATA STORAGE & PERSISTENCE

### 5.1 `sqflite` (^2.3.3+1)
**Version:** 2.3.3+1 or higher  
**Category:** Database

**What it is:**
Flutter plugin providing access to SQLite databases on mobile devices.

**What it does:**
- Creates and manages SQLite databases
- Executes SQL queries (SELECT, INSERT, UPDATE, DELETE)
- Handles transactions and batch operations
- Provides thread-safe database access
- Manages database schema and migrations

**Why it's used:**
- **Persistent storage:** Store scan history permanently
- **Structured data:** SQLite is better than key-value for complex data
- **Offline-first:** All data stored locally; works without internet
- **Performance:** Fast queries on large datasets
- **Cross-platform:** Same database code runs on Android and iOS
- **Industry standard:** SQLite is widely used in mobile apps

**Database contains:**
- Scan history records (ID, timestamp, coin info, confidence scores)
- User profile information
- Settings (theme, language preferences)
- Encyclopedia/reference data
- Detection results cache

**Where it's used:**
- History screen - Retrieving and displaying past scans
- Statistics screen - Querying scan data for charts
- Detection screen - Saving new scan results
- Settings - Loading/saving user preferences
- [core/database/](lib/core/database/) - Database configuration

---

### 5.2 `sqflite_common_ffi_web` (^0.4.5+4)
**Version:** 0.4.5+4 or higher  
**Category:** Database (Web Support)

**What it is:**
Bridge library enabling SQLite on web platform via Foreign Function Interface (FFI).

**What it does:**
- Compiles SQLite to WebAssembly for browser execution
- Enables same SQLite API on web as on mobile
- Stores data in IndexedDB (browser's persistent storage)
- Provides transparent database access across platforms

**Why it's used:**
- **Feature parity:** Web version has same database as mobile version
- **Data persistence:** Browser can store and retrieve scan history locally
- **Consistent experience:** Users see same data on web and phone
- **Offline capability:** Web app works without internet connection
- **User data safety:** Data stays on device; not sent to server

**Where it's used:**
- [main.dart](main.dart) - Database initialization for web platform
- Web version of app - All database operations
- Enables "flutter run -d chrome" to have full database support

---

### 5.3 `shared_preferences` (^2.3.2)
**Version:** 2.3.2 or higher  
**Category:** Storage (Key-Value)

**What it is:**
Flutter plugin for lightweight key-value data persistence.

**What it does:**
- Stores simple data (strings, numbers, booleans, lists)
- Uses native APIs (SharedPreferences on Android, UserDefaults on iOS)
- Provides synchronous read/write access
- Fast access for small data items
- Platform-native persistence

**Why it's used:**
- **Simple settings:** Perfect for user preferences that don't need SQLite complexity
- **Performance:** Faster than querying SQLite for simple values
- **Native storage:** Uses OS-level storage mechanisms
- **Offline:** Works completely offline without internet
- **Quick reads:** No database query overhead

**Data stored:**
- Theme mode preference (Light/Dark/System)
- Selected language (English/Hindi/Gujarati)
- Notification settings
- User ID or session token
- Recent search queries

**Where it's used:**
- Settings screen - Loading and saving user preferences
- App initialization - Loading theme and language on startup
- Profile screen - User preferences and choices

---

### 5.4 `path_provider` (^2.1.4)
**Version:** 2.1.4 or higher  
**Category:** File System

**What it is:**
Flutter plugin for accessing platform-specific file system directories.

**What it does:**
- Returns paths to app documents directory
- Returns paths to cache directory
- Returns paths to temporary directory
- Provides platform-agnostic path access (works on Android/iOS/Web)
- Handles directory creation if needed

**Why it's used:**
- **File management:** Know where to store app files safely
- **Cross-platform:** Same code works on different operating systems
- **Proper storage:** Use correct directories (documents vs cache vs temp)
- **Permissions:** Stored in proper locations with right access permissions
- **Database location:** SQLite databases stored in documents directory

**Where it's used:**
- Database setup - Locating database file path
- Image caching - Storing temporary images in cache directory
- File export - Saving scan results to documents
- [core/database/](lib/core/database/) - Database path configuration

---

### 5.5 `path` (^1.9.0)
**Version:** 1.9.0 or higher  
**Category:** Utilities

**What it is:**
Pure Dart library for path manipulation.

**What it does:**
- Joins path segments (`/documents` + `app` = `/documents/app`)
- Extracts file extensions and names
- Normalizes paths for different operating systems
- Handles path separators (/ on Unix, \ on Windows)
- Works on all platforms including web

**Why it's used:**
- **Cross-platform paths:** Handles different path formats (Windows vs Mac/Linux)
- **Safe concatenation:** Properly joins path components
- **File operations:** Used with path_provider for file system operations
- **String manipulation:** Safer than manual string concatenation

**Where it's used:**
- Database initialization - Building database file paths
- Image file management - Constructing image file paths
- File operations - Creating paths for saved results

---

## 6. USER INTERFACE & DESIGN

### 6.1 `google_fonts` (^6.2.1)
**Version:** 6.2.1 or higher  
**Category:** Typography/Design

**What it is:**
Flutter package providing access to Google Fonts library with 1000+ free fonts.

**What it does:**
- Loads fonts from Google Fonts service over internet
- Or bundles fonts locally (configurable)
- Applies fonts to Text widgets
- Supports all text styling (bold, italic, weights)
- Handles font fallbacks gracefully

**Why it's used:**
- **Professional appearance:** High-quality, curated fonts
- **Consistency:** Same fonts across all platforms
- **Flexibility:** Thousands of free fonts to choose from
- **Easy integration:** Simple API for applying fonts
- **Design system:** Used to implement design language

**Where it's used:**
- App-wide typography (titles, body text, labels)
- [core/constants/app_typography.dart](lib/core/constants/app_typography.dart) - Font definitions
- All Text widgets in the app

---

### 6.2 `fl_chart` (^0.69.0)
**Version:** 0.69.0 or higher  
**Category:** UI Component (Charts)

**What it is:**
Flutter package for creating beautiful, animated charts and graphs.

**What it does:**
- Renders line charts, bar charts, pie charts, scatter plots
- Provides customizable colors, labels, tooltips
- Animated transitions and interactions
- Handles large datasets efficiently
- Supports touch interactions and legends

**Why it's used:**
- **Statistics visualization:** Display scan analytics and trends
- **Professional charts:** Better than building charts from scratch
- **Interactivity:** Users can tap to see data details
- **Performance:** Optimized for rendering large datasets
- **Customization:** Highly configurable appearance

**Data visualized:**
- Coin scan frequency over time (line chart)
- Detection confidence scores (bar chart)
- Detection results breakdown (pie chart)
- Historical trend analysis

**Where it's used:**
- Statistics screen - Displaying scan analytics
- Dashboard - Summary charts of user activity
- Results analysis - Visual representation of detection data

---

### 6.3 `lottie` (^3.1.2)
**Version:** 3.1.2 or higher  
**Category:** Animation

**What it is:**
Flutter package for rendering After Effects animations as mobile app animations.

**What it does:**
- Plays JSON animation files created in Adobe After Effects
- Renders smooth, high-quality animations
- Provides playback controls (play, pause, speed)
- Loops animations automatically
- Very efficient rendering (vector-based, not frame-based)

**Why it's used:**
- **Better UX:** Loading states and transitions feel polished
- **Performance:** More efficient than frame-by-frame image sequences
- **Design collaboration:** Designers can create animations in After Effects
- **Smaller file size:** Animation JSON files are tiny
- **Smooth motion:** Professional-quality animations

**Animations used:**
- Splash screen - Loading animation
- Detection screen - Processing animation
- Loading states - Shimmer + Lottie combination

**Where it's used:**
- Splash screen - App launch animation
- Detection screen - Processing/loading animation
- Settings screen - Loading preferences animation

---

### 6.4 `flutter_animate` (^4.5.0)
**Version:** 4.5.0 or higher  
**Category:** Animation

**What it is:**
Dart package providing a simple, chainable animation API for Flutter.

**What it does:**
- Chains multiple animations together (fade, scale, slide, etc.)
- Provides curve and timing control
- Enables sequential and parallel animations
- Supports custom animation effects
- Works with any widget property

**Why it's used:**
- **Chainable API:** Easy to create complex animations with simple code
- **Readable code:** Animations are self-documenting
- **Reusability:** Animation patterns can be reused
- **Performance:** Hardware-accelerated animations
- **Flexibility:** Works with any widget

**Animations implemented:**
- Button hover effects
- Card entrance animations
- Screen transitions
- List item animations

**Where it's used:**
- Home screen - Card animations
- History screen - List item animations
- Navigation - Transition effects between screens
- Buttons and interactive elements

---

### 6.5 `shimmer` (^3.0.0)
**Version:** 3.0.0 or higher  
**Category:** UI Component (Loading State)

**What it is:**
Flutter package creating shimmer/skeleton loading effect animations.

**What it does:**
- Overlays a shimmering animation on widgets
- Creates placeholder UI that looks like content loading
- Provides perceived performance improvement
- Smooth linear animation effect

**Why it's used:**
- **Better UX:** Loading placeholders feel more responsive
- **Professional appearance:** Standard mobile app pattern
- **Perceived performance:** App feels faster to users
- **Simple implementation:** Easy to wrap any widget
- **No interaction:** Users know content is still loading

**Where it's used:**
- History screen - Skeleton loaders while fetching history
- Result screen - Skeleton loaders while processing detection
- Any async data loading state

---

## 7. PLATFORM FEATURES & INTEGRATION

### 7.1 `permission_handler` (^11.3.1)
**Version:** 11.3.1 or higher  
**Category:** Platform Integration

**What it is:**
Flutter plugin for requesting and checking runtime permissions on mobile devices.

**What it does:**
- Requests camera permission (to use camera)
- Requests gallery/photo library access (to pick images)
- Requests storage permissions (to save files)
- Requests microphone permission (if needed)
- Shows permission dialogs to user
- Checks current permission status
- Handles permission responses

**Why it's used:**
- **Compliance:** Android 6+ and iOS require explicit runtime permissions
- **User privacy:** Users decide which features can access sensitive data
- **Feature gating:** Disable features if permissions not granted
- **Legal:** Required by app store policies (Google Play, App Store)
- **User trust:** Clear permission requests build confidence

**Permissions used:**
- `CAMERA` - Camera screen feature
- `PHOTOS/MEDIA_LIBRARY` - Gallery picker feature
- `STORAGE` - Saving scan results locally

**Where it's used:**
- Camera screen - Requests camera permission on first use
- Image picker - Requests gallery access permission
- Before any feature that needs permissions
- Settings screen - View and manage permissions

---

### 7.2 `share_plus` (^10.0.2)
**Version:** 10.0.2 or higher  
**Category:** Platform Integration

**What it is:**
Official Flutter plugin for native share functionality.

**What it does:**
- Opens native share sheet (Android/iOS)
- Shares text, images, files to other apps
- Allows sharing to email, messaging, social media
- Shows platform-native UI
- Handles sharing on web

**Why it's used:**
- **User empowerment:** Users can share scan results with others
- **Native UX:** Uses platform's built-in share sheet
- **Marketing:** Sharing helps promote the app
- **Engagement:** Users can share interesting coins with friends
- **Easy implementation:** One-line function call

**Share capabilities:**
- Share scan results with confidence scores
- Share detection images
- Share to WhatsApp, Email, Messaging, etc.

**Where it's used:**
- Result screen - "Share Result" button
- History screen - Share past scan results
- Encyclopedia - Share coin information

---

### 7.3 `universal_io` (^2.2.2)
**Version:** 2.2.2 or higher  
**Category:** Platform Utilities

**What it is:**
Dart package providing platform-agnostic I/O operations.

**What it does:**
- Handles file operations consistently across platforms
- Provides HTTP client that works on all platforms including web
- Normalizes platform differences (Windows, Mac, Linux, Web, Android, iOS)
- Enables using same I/O code on all platforms

**Why it's used:**
- **Cross-platform consistency:** Same code works everywhere
- **Web compatibility:** File operations work on web (where native isn't available)
- **Future-proofing:** Abstracts platform differences
- **Network requests:** Handles HTTP consistently

**Where it's used:**
- File operations - Reading/writing app files
- Network calls - If making API requests to backend
- Initialization - Setting up database and storage

---

## 8. INTERNATIONALIZATION & UTILITIES

### 8.1 `intl` (^0.20.2)
**Version:** 0.20.2 or higher  
**Category:** Internationalization

**What it is:**
Dart package for internationalization and localization.

**What it does:**
- Formats dates according to locale (DD/MM/YYYY, MM/DD/YYYY, etc.)
- Formats numbers with proper separators and decimals
- Formats currencies for different countries
- Handles plural forms in different languages
- Manages message translations and interpolation

**Why it's used:**
- **Language support:** Proper formatting for English, Hindi, Gujarati
- **Regional correctness:** Date/number formats match user's locale
- **Professional appearance:** Localized formatting shows attention to detail
- **Compliance:** Important for international apps
- **User comfort:** Users see familiar date/number formats

**Formatting examples:**
- Dates: "10/06/2026" (format depends on locale)
- Numbers: "1,000" vs "1.000" (European format)
- Time: 12-hour vs 24-hour display
- Confidence scores: Proper decimal formatting

**Where it's used:**
- History screen - Formatting scan timestamps
- Result screen - Formatting confidence percentages
- Statistics - Formatting numeric data
- Throughout the app for locale-aware formatting

---

### 8.2 `uuid` (^4.5.1)
**Version:** 4.5.1 or higher  
**Category:** Utilities

**What it is:**
Dart package for generating Universally Unique Identifiers (UUIDs).

**What it does:**
- Generates unique identifiers (UUID v1, v4, v5)
- Creates random 36-character strings guaranteed to be unique
- Follows UUID standards/specifications
- Works on all platforms

**Why it's used:**
- **Unique records:** Each scan result gets a unique ID for tracking
- **Database keys:** Primary keys for scan history records
- **No collisions:** UUID v4 has negligible collision probability
- **Offline-friendly:** Can generate IDs without server (unlike auto-increment)
- **Data sync:** UUIDs work better when syncing to backend later

**Usage:**
- Scan result IDs - Each detection gets unique UUID
- User session IDs - Track user sessions
- Cache keys - Unique identifiers for stored data

**Where it's used:**
- Detection screen - Assigning ID to new scans
- History records - Database primary keys
- User session tracking

---

## 9. DEVELOPMENT & CODE QUALITY

### 9.1 `flutter_lints` (^4.0.0)
**Version:** 4.0.0 or higher  
**Category:** Code Quality

**What it is:**
Official Flutter package containing recommended linting rules from Google.

**What it does:**
- Analyzes Dart code for common mistakes
- Enforces code style consistency
- Detects performance anti-patterns
- Suggests best practices
- Integrates with IDE and build process

**Rules enforced:**
- `prefer_const_constructors` - Use const constructors for efficiency
- `avoid_print` - Disabled (logging allowed for debugging)

**Why it's used:**
- **Code quality:** Catches bugs early
- **Consistency:** All developers write code same way
- **Performance:** Rules prevent memory leaks and inefficiencies
- **Best practices:** Enforces Flutter recommendations
- **Maintainability:** Consistent code is easier to update

**Where it's used:**
- All Dart files in project
- IDE shows warnings/errors for violations
- Build process can fail if violations are critical

---

### 9.2 `flutter_test` (SDK)
**Version:** SDK (Latest)  
**Category:** Testing

**What it is:**
Official Flutter testing framework for widget and unit tests.

**What it does:**
- Unit testing - Test individual functions and classes
- Widget testing - Test UI components in isolation
- Integration testing - Test complete user workflows
- Provides test utilities and assertions
- Mocking capabilities for dependencies

**Why it's used:**
- **Quality assurance:** Verify code works as expected
- **Regression prevention:** Catch bugs when code changes
- **Confidence:** Tests give confidence before deployment
- **Documentation:** Tests show how code should be used
- **Maintainability:** Easier to refactor with test coverage

**Test coverage:**
- Provider tests - State management logic
- Widget tests - Individual screens and components
- Service tests - Detection and database services

**Where it's used:**
- [test/](test/) directory - All test files
- Pre-deployment - Run tests before building release

---

## 10. DEPENDENCY TREE & RELATIONSHIPS

```
NumiIT App
│
├─── Flutter (Core Framework)
│    └─── Material Design 3 UI
│
├─── State Management
│    └─── flutter_riverpod (manages all reactive state)
│
├─── Navigation
│    └─── go_router (declarative routing)
│
├─── Camera & Image Processing
│    ├─── camera (hardware camera)
│    ├─── image_picker (gallery access)
│    ├─── image (image processing)
│    └─── photo_view (image viewing)
│
├─── Data Storage
│    ├─── sqflite (mobile database)
│    ├─── sqflite_common_ffi_web (web database)
│    ├─── shared_preferences (key-value)
│    └─── path_provider + path (file system)
│
├─── UI & Design
│    ├─── google_fonts (typography)
│    ├─── fl_chart (statistics charts)
│    ├─── lottie (animations)
│    ├─── flutter_animate (additional animations)
│    └─── shimmer (loading states)
│
├─── Platform Features
│    ├─── permission_handler (permissions)
│    ├─── share_plus (sharing)
│    └─── universal_io (file I/O)
│
├─── Internationalization
│    ├─── flutter_localizations (i18n infrastructure)
│    ├─── intl (formatting)
│    └─── uuid (unique IDs)
│
└─── Quality & Testing
     ├─── flutter_lints (code quality)
     └─── flutter_test (testing)
```

---

## 11. FEATURE-TO-LIBRARY MAPPING

### Camera Screen
- `camera` - Live camera preview
- `permission_handler` - Camera permission
- `image` - Image processing
- `image_picker` - Gallery import

### Detection Screen
- `image` - Image preprocessing
- `sqflite` - Saving results
- `uuid` - Unique result ID
- `flutter_animate` - Loading animation
- `shimmer` - Loading state

### Result Screen
- `photo_view` - Zoom/pan images
- `fl_chart` - Confidence visualization
- `share_plus` - Share results
- `intl` - Format confidence scores

### History Screen
- `sqflite` - Query scan history
- `shimmer` - Loading placeholders
- `flutter_animate` - List animations
- `intl` - Format dates/times

### Statistics Screen
- `sqflite` - Query analytics data
- `fl_chart` - Render charts (line, bar, pie)
- `intl` - Format numbers

### Settings Screen
- `shared_preferences` - Save preferences
- `flutter_riverpod` - Manage settings state
- `permission_handler` - Show app permissions

### Splash Screen
- `lottie` - Launch animation

---

## 12. PLATFORM SUPPORT BY LIBRARY

| Library | Android | iOS | Web | Windows | macOS | Linux |
|---------|---------|-----|-----|---------|-------|-------|
| flutter | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| flutter_localizations | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| cupertino_icons | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| flutter_riverpod | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| go_router | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| camera | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| image_picker | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ |
| image | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| photo_view | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| sqflite | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| sqflite_common_ffi_web | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| shared_preferences | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ |
| path_provider | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| path | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| google_fonts | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| fl_chart | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| lottie | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ |
| flutter_animate | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| shimmer | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| permission_handler | ✅ | ✅ | ❌ | ❌ | ⚠️ | ❌ |
| share_plus | ✅ | ✅ | ✅ | ⚠️ | ✅ | ⚠️ |
| universal_io | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| intl | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| uuid | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| flutter_lints | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| flutter_test | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

**Legend:** ✅ = Full support | ⚠️ = Partial/Limited | ❌ = Not supported

---

## 13. LIBRARY CATEGORIES BY PURPOSE

### 🎬 Media & Hardware Access (4 packages)
- `camera` - Device camera
- `image_picker` - Photo gallery
- `permission_handler` - Permission requests
- `share_plus` - Native sharing

### 🎨 UI & Design (5 packages)
- `google_fonts` - Typography
- `fl_chart` - Charts/graphs
- `lottie` - Animations
- `flutter_animate` - Additional animations
- `shimmer` - Loading effects

### 💾 Data Storage (4 packages)
- `sqflite` - Mobile database
- `sqflite_common_ffi_web` - Web database
- `shared_preferences` - Key-value storage
- `path_provider` - File system paths

### 🧭 Navigation & State (2 packages)
- `go_router` - App navigation
- `flutter_riverpod` - State management

### 🖼️ Image Processing (2 packages)
- `image` - Image manipulation
- `photo_view` - Image viewing

### 🌍 Localization & Utilities (3 packages)
- `intl` - Date/number formatting
- `uuid` - Unique identifiers
- `universal_io` - Cross-platform I/O

### 📱 Platform Integration (1 package)
- `flutter_localizations` - Multi-language support

### 🛠️ Development (2 packages)
- `flutter_lints` - Code quality
- `flutter_test` - Testing framework

---

## 14. SUMMARY TABLE

| # | Library | Category | Version | Purpose | Status |
|---|---------|----------|---------|---------|--------|
| 1 | flutter | Framework | SDK | Core Flutter framework | Required |
| 2 | flutter_localizations | i18n | SDK | Localization support | Required |
| 3 | camera | Media | ^0.11.0+2 | Device camera access | Critical |
| 4 | image_picker | Media | ^1.1.2 | Photo gallery picker | Important |
| 5 | sqflite | Database | ^2.3.3+1 | Mobile database | Critical |
| 6 | sqflite_common_ffi_web | Database | ^0.4.5+4 | Web database | Important |
| 7 | path_provider | Storage | ^2.1.4 | File system paths | Required |
| 8 | path | Utilities | ^1.9.0 | Path manipulation | Required |
| 9 | flutter_riverpod | State | ^2.5.1 | State management | Critical |
| 10 | go_router | Navigation | ^14.2.7 | App routing | Critical |
| 11 | google_fonts | Design | ^6.2.1 | Typography | Important |
| 12 | share_plus | Platform | ^10.0.2 | Share functionality | Important |
| 13 | shared_preferences | Storage | ^2.3.2 | Preferences storage | Important |
| 14 | intl | i18n | ^0.20.2 | Formatting | Important |
| 15 | lottie | Animation | ^3.1.2 | Animations | Nice-to-have |
| 16 | fl_chart | UI | ^0.69.0 | Charts/graphs | Important |
| 17 | photo_view | UI | ^0.15.0 | Image viewing | Important |
| 18 | image | Processing | ^4.2.0 | Image processing | Important |
| 19 | permission_handler | Platform | ^11.3.1 | Permissions | Critical |
| 20 | flutter_animate | Animation | ^4.5.0 | Animations | Nice-to-have |
| 21 | shimmer | UI | ^3.0.0 | Loading effects | Nice-to-have |
| 22 | uuid | Utilities | ^4.5.1 | Unique IDs | Important |
| 23 | universal_io | Platform | ^2.2.2 | Cross-platform I/O | Important |
| 24 | cupertino_icons | Assets | ^1.0.8 | iOS icons | Important |
| 25 | flutter_lints | Quality | ^4.0.0 | Code linting | Development |
| 26 | flutter_test | Testing | SDK | Testing framework | Development |

---

## 15. RECOMMENDATIONS

### Strengths ✅
- **Modern architecture:** Using latest Flutter packages (Riverpod 2.5, GoRouter 14)
- **Well-structured:** Clean separation of concerns with feature modules
- **Cross-platform:** Supports mobile and web
- **Performance:** Efficient libraries for database, state management, and rendering

### Future Enhancements 🚀
1. **Backend Integration:**
   - Add `dio` or `http` package for API calls
   - Consider `retrofit` for code-generated REST client

2. **Error Handling:**
   - Add `sentry` for crash reporting
   - Global error handling via Riverpod providers

3. **Offline Sync:**
   - Enhanced conflict resolution for offline data
   - Background sync capabilities

4. **Analytics:**
   - `firebase_analytics` for user insights
   - Custom analytics provider

5. **Advanced Features:**
   - `firebase_auth` if adding cloud authentication
   - `cloud_firestore` if moving to cloud database
   - `google_mlkit_text_recognition` for OCR enhancement

---

## 16. GLOSSARY OF TERMS

- **Dart:** Programming language used by Flutter
- **Widget:** Basic UI component in Flutter
- **State Management:** System for managing app data that changes
- **Provider:** Riverpod concept for providing/accessing state
- **Route:** Screen/page in the app navigation
- **SQLite:** Lightweight database engine
- **FFI:** Foreign Function Interface (calling native code from Dart)
- **UUID:** Universally Unique Identifier
- **Repository Pattern:** Architectural pattern for data access
- **Immutable:** Data that doesn't change after creation

---

## 17. FINAL NOTES

- **Total Direct Dependencies:** 26 packages
- **Critical Libraries:** 5 (Flutter, Riverpod, GoRouter, Camera, SQLite)
- **Development Only:** 2 (flutter_lints, flutter_test)
- **Dart SDK:** >=3.2.0 <4.0.0 (supports latest Dart 3.x features)

This project demonstrates modern Flutter best practices with a well-curated set of dependencies that balance functionality, performance, and maintainability.

---

**Report End**

*For code-level details, consult the actual implementation files in the project. This report focuses on library-level architecture and dependencies.*
