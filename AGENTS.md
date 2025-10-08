# Repository Guidelines

## Project Structure & Module Organization
The Flutter entry point lives in `lib/main.dart`, with feature code grouped in:
- `lib/screens/` UI screens (e.g., `home_screen.dart`, `settings_screen.dart`).
- `lib/models/`, `lib/services/`, `lib/utils/`, and `lib/widgets/` for domain data, data access, helpers, and reusable widgets.
Localization classes reside under `lib/l10n/`.
Cross-platform scaffolding is provided in `android/`, `ios/`, `macos/`, `linux/`, `windows/`, and `web/`.
Shared assets, including `logo.jpg` and `privacy_policy.html`, sit at the repository root.
Unit and widget tests belong in `test/`, following the existing `widget_test.dart` pattern.

## Build, Test, and Development Commands
- `flutter pub get` installs and locks dependencies from `pubspec.yaml`.
- `flutter run` launches the app on the current device or simulator; use `--profile` for performance checks.
- `flutter analyze` runs static analysis with the rules in `analysis_options.yaml`.
- `flutter test` executes the Dart test suite; append `--coverage` to collect line coverage.
- `flutter build apk` or the relevant `flutter build <platform>` variants create release binaries.

## Coding Style & Naming Conventions
Follow the default Flutter formatter (two-space indentation); run `dart format lib test`.
Keep classes and widgets in `UpperCamelCase`, functions and variables in `lowerCamelCase`, and constants in `kUpperCamelCase`.
Favor composing widgets over deeply nested conditionals.
Adhere to the `flutter_lints` ruleset; address analyzer warnings instead of suppressing them.

## Testing Guidelines
Add new tests alongside features using the `*_test.dart` naming scheme.
Prefer widget tests for UI logic and pure Dart tests for services and utils.
Use fake or in-memory data sources when exercising `sqflite` or `shared_preferences`.
Ensure critical flows (check-in tracking, reminders, policy viewer) have regression coverage before merging.

## Commit & Pull Request Guidelines
Write concise, imperative commit messages (`Add check-in chart widgets`); avoid one-word placeholders.
Group related changes per commit and run `flutter analyze && flutter test` before committing.
Pull requests should summarize user-facing impact, mention affected screens/services, and link issues or task IDs.
Attach screenshots or screen recordings when modifying UI, and describe any manual verification steps performed.
