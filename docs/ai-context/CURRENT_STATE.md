# Current State — Suq ERP

Last updated: 2026-05-29

---

## Project Purpose

**Suq** is a mobile-first ERP app for small shop owners.
Replaces paper ledgers with digital sales, inventory, credit tracking, and reporting.
Built with Flutter (Dart) + Supabase (PostgreSQL + Auth + Realtime).

Target: Android (primary), Chrome web for dev/testing.
Package: `com.temesgen.suq`
Repo: https://github.com/NorthernLights1/Suq
Flutter app lives in: `suq/` subdirectory of the repo.

---

## Current Progress

| Phase | Description | Status |
|---|---|---|
| Phase 0 | Flutter project bootstrap + Supabase SQL migrations | ✅ Done |
| Phase 1 | Core infrastructure (services, interfaces, local DB stubs) | ✅ Done |
| Phase 2 | Auth screens, Onboarding flow, Dashboard shell | ✅ Done |
| Phase 3 | Sales module | 🔲 Not started |
| Phase 4 | Inventory, Customers, Expenses, Reports, Staff, Settings | 🔲 Not started |
| Phase 5 | Polish, tests, offline Drift DB wiring | 🔲 Not started |

**Active branch:** `feat/phase-2-auth-onboarding` (pushed, PR not yet merged)

---

## What Works Right Now

- App runs on Chrome (`flutter run -d chrome` from `suq/`)
- Signup creates a Supabase user + profile (via DB trigger)
- Login redirects to onboarding (if no shop) or dashboard (if shop exists)
- Onboarding: 4-step flow — shop → branch → opening stock (skip) → invite staff (skip)
- Dashboard shell: bottom nav, summary cards, quick actions grid, branch chip
- Sign out works

---

## Key Constraints (non-negotiable)

1. All configurable values in `shop_settings` table — never hardcoded
2. All modules behind interfaces — no direct lib calls from business logic
3. Write-local-first (Drift), sync to Supabase in background
4. All monetary values use `decimal` type, never `double`
5. Never check `role == 'owner'` in UI — always go through `PermissionService`
6. No hardcoded strings in widgets — l10n layer (`.arb` files)
7. Audit trail: sales voided (not deleted), inventory via `inventory_adjustments`

---

## Important Infrastructure

- **Supabase project:** `nkhpofadoexlwnuccyxk.supabase.co`
- **Supabase creds:** in `suq/lib/core/constants/supabase_constants.dart`
- **SQL migrations:** `supabase/migrations/001–006.sql` (run manually in Supabase SQL Editor)
- **DB trigger:** `handle_new_user()` in `006_system.sql` — creates profile on signup. Requires `set search_path = public` or it fails with 500.
- **Drift DB:** stubs in place, not yet wired (Phase 5)
- **l10n:** `.arb` files in `suq/lib/l10n/`, generated files committed. `flutter gen-l10n` generates them.

---

## Known Risks

- Drift offline DB not yet wired — app is Supabase-only right now
- `PermissionService` cache is in-memory only — cleared on app restart
- No error boundary around Supabase calls — raw exceptions surface to UI
- Android SDK not installed on dev machine — Chrome is the only test target
