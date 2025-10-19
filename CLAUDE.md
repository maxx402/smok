# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

戒烟小助理 (Quit Smoking Assistant) - A Flutter-based offline-first mobile application helping users quit smoking through progress tracking, health milestone monitoring, and positive reinforcement.

**Package Name**: `com.github.gusmoke`
**Supported Platforms**: iOS, Android, Web, Windows, macOS
**Languages**: Chinese (Simplified - primary), English

## Development Commands

### Running the App
```bash
# Run on connected device/simulator (debug mode)
flutter run

# Run on specific device
flutter run -d <device-id>

# List available devices
flutter devices

# Note: iOS simulators only support debug mode
# For release builds on iOS, use a physical device
```

### Building
```bash
# Clean build artifacts
flutter clean

# Get dependencies
flutter pub get

# Build for production (Android)
flutter build apk --release
flutter build appbundle --release

# Build for production (iOS) - requires macOS
flutter build ios --release
flutter build ipa --release
```

### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
flutter format .

# Run linter
flutter analyze --fatal-infos
```

### Assets & Icons
```bash
# Generate app icons (configured in pubspec.yaml)
flutter pub run flutter_launcher_icons
```

### Database Management
```bash
# Database file location (debug):
# iOS Simulator: ~/Library/Developer/CoreSimulator/Devices/<UUID>/data/Containers/Data/Application/<UUID>/Documents/quit_smoking.db
# Android Emulator: /data/data/com.github.gusmoke/databases/quit_smoking.db

# To reset database during development:
# 1. Uninstall the app
# 2. Or increment database version in storage_service.dart and handle migration
```

## Architecture & Code Structure

### State Management Pattern
- **Local State Only**: Uses `StatefulWidget` with `setState()` - no Provider/Riverpod/Bloc
- **Data Layer**: Single `StorageService` singleton handles all persistence
- **UI Updates**: Combination of callback functions and widget key regeneration
- **Real-time Updates**: `Timer.periodic()` for quit duration display (1-second intervals)

### Data Persistence Strategy

**Two-tier storage:**
1. **SharedPreferences** (JSON-serialized):
   - User settings (smoking habits, quit date)
   - Feature flags (enable65)
   - Encouragement entries list
   - User feedback entries

2. **SQLite Database** (`quit_smoking.db`, version 2):
   - Daily check-ins (mood, temptation, notes)
   - Resistance logs (timestamps when user resisted smoking)
   - Achievements system (partially implemented)

**Important**: All models use `toJson()`/`fromJson()` pattern. Timestamps stored as `millisecondsSinceEpoch`.

### Navigation Structure
```
App Root
├── Enable65Screen (conditional - special feature mode)
└── MainScreen (normal mode)
    ├── Bottom Navigation (PageView-based)
    │   ├── HomeScreen (Tab 0) - Dashboard with stats
    │   ├── CheckinScreen (Tab 1) - Daily mood/temptation logging
    │   ├── RemindersScreen (Tab 2) - Analytics
    │   └── SettingsScreen (Tab 3) - User preferences
    │
    └── Secondary Screens (Navigator.push)
        ├── EncouragementWallScreen - View saved messages
        └── PrivacyPolicyScreen - WebView for policy
```

### Key Services & Utilities

**StorageService** (`lib/services/storage_service.dart`):
- Singleton pattern - use `StorageService()` anywhere
- Initializes both SharedPreferences and SQLite
- All async methods - always `await` calls
- No error throwing - returns null/empty on failure

**QuitStats** (`lib/utils/quit_stats.dart`):
- Factory constructor: `QuitStats.fromUserSettings(settings)`
- Pure calculation class - no state
- Provides: `quitDuration`, `moneySaved`, `cigarettesNotSmoked`, `healthMilestones`

**HealthMilestone System**:
9 predefined milestones from 20 minutes to 1 year post-quit, each with medical benefits description.

### Special Features

#### Enable65 Mechanism
- Obfuscated trigger detection via XOR cipher in `enable65_helper.dart`
- Activated when specific keyword detected in clipboard or user feedback
- When triggered: app navigates to `Enable65Screen` and exits
- Check status: `StorageService().isEnable65()`

#### Clipboard Monitoring
- Active only when app resumes from background
- Requires user consent (one-time prompt)
- Auto-saves clipboard content as encouragement entry
- Prevents duplicates via `encouragement_last_clipboard` tracking

#### Notifications (In Development)
- `flutter_local_notifications` dependency added
- UI marked as "正在开发中" (under development)
- Settings toggle exists but `onChanged: null` (disabled)

## Important Implementation Notes

### Adding New Screens
1. Create screen file in `lib/screens/`
2. Extend `StatefulWidget` (for stateful) or `StatelessWidget`
3. For data access: instantiate `StorageService()` directly
4. Always check `mounted` before `setState()` in async callbacks
5. Use `AppLocalizations.of(context)` for i18n strings

### Modifying Data Models
1. Update model class in `lib/models/`
2. Update `toJson()` and `fromJson()` methods
3. If stored in SQLite: update schema in `StorageService._createDb()`
4. Increment `_databaseVersion` and add migration logic in `_onUpgrade()`
5. For SharedPreferences: update serialization in `StorageService` methods

### Adding Localized Strings
1. Add key-value to `lib/l10n/app_localizations_zh.dart` (primary)
2. Add same key to `lib/l10n/app_localizations_en.dart`
3. Access via `AppLocalizations.of(context).yourKey`
4. Chinese is the primary language - ensure all strings exist there first

### Theme Customization
- Primary color: Emerald green (`0xFF059669` light, `0xFF10B981` dark)
- All theme config in `lib/main.dart` `QuitSmokingApp.build()`
- Material 3 design system (`useMaterial3: true`)
- Both light and dark themes defined
- Custom card, button, and app bar styling

### Working with Statistics
- **Never** calculate stats directly - use `QuitStats.fromUserSettings()`
- Money saved = `days × dailyExpense`
- Cigarettes avoided = `days × dailyCigarettes`
- Health milestones auto-calculated based on quit duration
- All stats are derived - no separate storage needed

### Database Migrations
Current version: 2
```dart
// Example migration from v1 to v2:
if (oldVersion < 2) {
  await db.execute('''CREATE TABLE resistance_logs (...)''');
}
```
Always increment version and handle all intermediate versions.

## Common Gotchas

1. **iOS Simulators**: Only support debug mode - use `flutter run` (not `--release` or `--profile`)

2. **Package Name Changes**: After changing bundle ID/package name, always run `flutter clean` before next build

3. **Database Access**: `StorageService().init()` must complete before any data access - called in `main()` before `runApp()`

4. **Timer Disposal**: `HomeScreen` creates a 1-second timer - ensure disposal in `dispose()` to prevent memory leaks

5. **Mounted Checks**: Always wrap `setState()` in async callbacks with `if (mounted)` check

6. **JSON Serialization**: All timestamps must be stored as `millisecondsSinceEpoch` (int), not `DateTime` objects

7. **Clipboard Consent**: First clipboard access triggers consent dialog - handle in `MainScreen._checkClipboard()`

8. **App Lifecycle**: `MainScreen` implements `WidgetsBindingObserver` - don't remove lifecycle handling without understanding clipboard monitoring

9. **Null Safety**: Models use nullable fields extensively - always null-check before use (e.g., `settings.nickname ?? 'Default'`)

10. **WebView**: Privacy policy uses `webview_flutter` - requires internet permission in manifests (already configured)

## Testing Considerations

- No test suite currently exists
- When adding tests: focus on `QuitStats` calculations and `StorageService` CRUD operations
- UI testing complicated by real-time timer updates in `HomeScreen`
- Database tests should use in-memory SQLite (`inMemoryDatabasePath`)

## Privacy & Security

- **Fully offline**: No network requests except WebView for privacy policy
- **Local storage only**: All data stays on device
- **No analytics**: No tracking or telemetry
- **Privacy policy URL**: https://65sj.cc/privacy_policy.html
- **No authentication**: Single-user app, no accounts

## Configuration Files

- **pubspec.yaml**: Dependencies, app metadata, icon config
- **android/app/build.gradle.kts**: Android package name, SDK versions
- **ios/Runner.xcodeproj/project.pbxproj**: iOS bundle ID (search `PRODUCT_BUNDLE_IDENTIFIER`)
- **android/app/src/main/AndroidManifest.xml**: Android permissions, app label
- **ios/Runner/Info.plist**: iOS permissions, display name

## Debugging Tips

**Enable debug banner removal**: Already configured with `debugShowCheckedModeBanner: false` in `main.dart`

**Check SQLite data**:
```bash
# Connect to Android emulator database
adb shell
cd /data/data/com.github.gusmoke/databases/
sqlite3 quit_smoking.db
.tables
SELECT * FROM checkins;
```

**SharedPreferences data**: Use Flutter DevTools > App Inspection > Shared Preferences

**Hot reload limitations**: Database schema changes require full restart (`R` not `r`)

**Locale testing**: Change device language to test i18n - app supports `zh_CN` and `en`
