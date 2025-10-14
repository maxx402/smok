# Repository Guidelines

## Project Structure & Module Organization
The Flutter entry point is `lib/main.dart`, with feature-specific UIs in `lib/screens/`. Shared models, services, utilities, and widgets live under `lib/models/`, `lib/services/`, `lib/utils/`, and `lib/widgets/`. Localization resources reside in `lib/l10n/`. Platform boilerplate is maintained in `android/`, `ios/`, `macos/`, `linux/`, `windows/`, and `web/`. Repository-level assets such as `logo.jpg` and `privacy_policy.html` stay at the root, while all unit and widget tests belong in `test/`.

## Build, Test, and Development Commands
Run `flutter pub get` after dependency edits to sync the lockfile. Use `flutter run` for local development; add `--profile` when diagnosing performance. Execute `flutter analyze` before every pull request to satisfy the lints in `analysis_options.yaml`. Trigger the automated suite with `flutter test`, and append `--coverage` when you need line coverage metrics.

## Coding Style & Naming Conventions
Format Dart sources with `dart format lib test` to enforce two-space indentation and trailing newline conventions. Follow `flutter_lints`; fix warnings instead of suppressing them. Name classes and widgets in UpperCamelCase, functions and variables in lowerCamelCase, and constants with `kUpperCamelCase`. Favor composable widgets over deeply nested conditionals to keep trees readable.

## Testing Guidelines
Keep tests in `test/` and mirror the `*_test.dart` naming pattern. Use widget tests for UI-backed logic and pure Dart tests for utilities and services; rely on fakes or in-memory stores for plugins like `sqflite` or `shared_preferences`. Ensure critical flows—check-in tracking, reminders, and the policy viewer—retain regression coverage by running `flutter test --coverage` before merges.

## Commit & Pull Request Guidelines
Author commits using concise, imperative subject lines such as `Add check-in chart widgets`. Group related changes together and run `flutter analyze && flutter test` prior to committing. Pull requests should summarize user-facing impact, call out affected screens or services, link relevant issues or task IDs, and include screenshots or recordings whenever UI shifts. Document any manual verification steps so reviewers can reproduce them quickly.

## Environment & Security Notes
Keep platform tooling up to date with the Flutter SDK version fixed in this repo; verify with `flutter --version`. Do not commit credentials or generated secrets—store sensitive data in environment variables or secure storage. When handling assets, confirm license compatibility and note any usage restrictions in pull request descriptions.
