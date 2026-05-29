# Bugs and Fixes — Suq ERP

---

## Bug: Signup fails with 500 "Database error saving new user"
Status: Fixed

Symptoms:
- User fills signup form, taps "Create Account"
- Supabase returns `AuthRetryableFetchException: {"code":"unexpected_failure","message":"Database error saving new user"}, statusCode: 500`
- No user created in `auth.users` or `profiles`

Cause:
- The `handle_new_user()` trigger in `006_system.sql` runs without `set search_path = public`
- In Supabase's restricted execution context, PostgreSQL cannot resolve the `profiles` table without an explicit search path

Fix tried:
```sql
create or replace function handle_new_user()
returns trigger language plpgsql security definer
set search_path = public
as $$
begin
  insert into profiles (id, full_name, phone)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    new.raw_user_meta_data->>'phone'
  );
  return new;
end;
$$;
```

Result: Fixed. Run in Supabase SQL Editor.

Related files:
- `supabase/migrations/006_system.sql` (original trigger, missing search_path)

Notes: Always add `set search_path = public` to any `security definer` function in Supabase.

---

## Bug: Login succeeds but app stays on login screen — no navigation
Status: Fixed

Symptoms:
- User logs in with correct credentials
- No error message shown
- App stays on login screen, nothing happens

Cause:
- `createRouter(ref)` was called inside `SuqApp.build()` (a `ConsumerWidget`)
- On every rebuild, a new `GoRouter` instance was created with a new `_AuthRefreshNotifier`
- The previous router's notifier fired but the new router hadn't registered the listener yet
- Result: auth state change never triggered the redirect

Fix tried:
- Converted `SuqApp` from `ConsumerWidget` to `ConsumerStatefulWidget`
- Cached router as `late final appRouter = createRouter()` in `_SuqAppState`
- Router is now created exactly once for the lifetime of the app

Result: Fixed. Router redirect fires correctly on login.

Related files:
- `suq/lib/app.dart`
- `suq/lib/shared/router/app_router.dart`

Notes:
- GoRouter must be created once. Never call `GoRouter(...)` inside a `build()` method.
- The `_AuthRefreshNotifier` is now instantiated inside `createRouter()` (not as a global), so each router owns its listener.

---

## Bug: `app_routes.dart` could not be imported by feature screens
Status: Fixed

Symptoms:
- `flutter analyze` reported: "The imported library can't have a part-of directive"
- `AppRoutes` was undefined in all feature screens

Cause:
- `app_routes.dart` had `part of 'app_router.dart'` at the top
- Feature screens were importing `app_routes.dart` directly (not through `app_router.dart`)
- A `part` file cannot be imported as a standalone library

Fix:
- Removed `part of 'app_router.dart'` from `app_routes.dart` — made it a standalone file
- Changed `app_router.dart` from `part 'app_routes.dart'` to `import 'app_routes.dart'`

Result: Fixed.

Related files:
- `suq/lib/shared/router/app_routes.dart`
- `suq/lib/shared/router/app_router.dart`

---

## Bug: `flutter_gen/gen_l10n/app_localizations.dart` does not exist at analyze time
Status: Avoided (workaround in place)

Symptoms:
- `flutter analyze` reported: "Target of URI doesn't exist: package:flutter_gen/gen_l10n/app_localizations.dart"
- App would not compile

Cause:
- `flutter gen-l10n` had not been run; generated files didn't exist yet

Fix:
- Removed the `flutter_gen` import from `app.dart` temporarily
- Ran `flutter pub get` which triggered l10n generation via `generate: true` in `pubspec.yaml`
- Generated files (`app_localizations.dart`, `app_localizations_en.dart`) committed to repo

Result: Resolved. Files now exist in `suq/lib/l10n/`.

Notes: If l10n files go missing, run `flutter gen-l10n` from `suq/`.
