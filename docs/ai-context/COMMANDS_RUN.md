# Commands Reference — Suq ERP

All Flutter commands must be run from `c:/Projects/MobERP/suq/` unless noted.

---

## Run app in Chrome (dev target)

```bash
cd suq && flutter run -d chrome
```

Purpose: Launch the app in Chrome for development and testing.
Result: Works. Chrome is the only confirmed working target (Android SDK not installed).
Notes: Hot reload available. Full restart needed after router or DI changes.

---

## Check for issues

```bash
cd suq && flutter analyze
```

Purpose: Static analysis — catches type errors, unused imports, lint warnings.
Result: Must be clean (0 issues) before committing.
Notes: Run after every significant code change.

---

## Install dependencies

```bash
cd suq && flutter pub get
```

Purpose: Resolve and download all packages in `pubspec.yaml`.
Result: Downloads ~143 packages. Also triggers l10n generation.
Notes: Requires Windows Developer Mode enabled (for symlink support).

---

## Generate l10n files

```bash
cd suq && flutter gen-l10n
```

Purpose: Generate `app_localizations.dart` from `.arb` files in `suq/lib/l10n/`.
Result: Creates/updates `suq/lib/l10n/app_localizations.dart` and `app_localizations_en.dart`.
Notes: Run whenever `app_en.arb` is modified.

---

## Run build_runner (for Drift + Riverpod code gen)

```bash
cd suq && dart run build_runner build --delete-conflicting-outputs
```

Purpose: Generate Drift table classes and Riverpod `@riverpod` annotations.
Result: Not yet needed (Drift not wired, no `@riverpod` annotations used yet).
Notes: Will be required in Phase 5 when Drift schema is added.

---

## Create a new git branch

```bash
cd .. && git checkout -b feat/<name>
```

Purpose: Start a new feature branch per CLAUDE.md git workflow.
Notes: Always branch from latest `main`. Never push directly to main.

---

## Push to Suq repo

```bash
git push suq <branch-name>
```

Purpose: Push to `NorthernLights1/Suq` on GitHub.
Notes: `origin` points to `nextlevelbuilder/ui-ux-pro-max-skill` (no push access). Use `suq` remote.

---

## Run Supabase SQL migration

No CLI set up. Apply migrations manually:
1. Open https://supabase.com/dashboard → your project → SQL Editor
2. Paste contents of `supabase/migrations/00X_name.sql`
3. Run in order: 001 → 002 → 003 → 004 → 005 → 006

---

## Check Flutter + Dart version

```bash
flutter --version
```

Result: Flutter 3.44.0 • Dart 3.12.0 • DevTools 2.57.0 (as of 2026-05-29)

---

## Enable Windows Developer Mode (required once)

```powershell
start ms-settings:developers
```

Purpose: Flutter needs symlink support for plugin builds on Windows.
Result: Toggle "Developer Mode" on in the settings window that opens.
Notes: One-time setup. Without it, `flutter pub get` fails with a symlink error.
