# CLAUDE.md — Suq ERP (Flutter)

This file provides guidance to Claude Code when working inside the `suq/` Flutter project.

---

## Project

**Suq** is a mobile ERP for small shop owners built with Flutter and Supabase.
Full spec: see `../CLAUDE.md` (project root) which contains the complete domain model, schema, and architecture rules.

Package: `com.temesgen.suq` | Repo: `NorthernLights1/Suq`

---

## Key Rules (non-negotiable)

1. No hardcoded values — all config via `shop_settings` or `core/constants/`
2. All modules behind interfaces — never call Supabase/PDF/Excel libs directly from features
3. All monetary values use `decimal` package — never `double`
4. RBAC always through `PermissionService` — never check `role == 'owner'` in UI
5. No hardcoded strings in widgets — all user-facing text in `lib/l10n/app_en.arb`
6. Writes go local (Drift) first, sync to Supabase in background
7. Run `flutter analyze` before every commit — must be clean

---

## Git Workflow

- Branch: `git checkout -b feat/...` or `fix/...`
- Push to Suq repo: `git push suq <branch>` (not `origin`)
- PR at: https://github.com/NorthernLights1/Suq

---

## Dev Commands

```bash
cd suq && flutter run -d chrome     # run on Chrome (only working target)
cd suq && flutter analyze           # must pass clean before commit
cd suq && flutter pub get           # install/update deps
cd suq && flutter gen-l10n          # regenerate after editing app_en.arb
```

---

## AI Context Usage

This project uses `docs/ai-context/` as external memory.

At the start of a new session, read only:
- `docs/ai-context/INDEX.md`
- `docs/ai-context/CURRENT_STATE.md`
- `docs/ai-context/OPEN_TASKS.md`

Do not read the entire `docs/ai-context/` folder unless explicitly asked.

Before compacting context, update the relevant files in `docs/ai-context/`:
- `CURRENT_STATE.md`
- `OPEN_TASKS.md`
- `DECISIONS.md`
- `BUGS_AND_FIXES.md`
- `COMMANDS_RUN.md`
- `FILE_MAP.md`

Do not paste full conversation history into these files.
Do not paste large source files into these files.
Keep entries concise, factual, and easy for a future session to scan.

When uncertain, read `INDEX.md` first, then only the specific context file needed.
