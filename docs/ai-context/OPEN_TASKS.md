# Open Tasks — Suq ERP

Last updated: 2026-05-29

---

## Immediate — Phase 3: Sales Module

Priority order:

1. **Sale domain model** — `suq/lib/domain/models/sale.dart`
   `Sale`, `SaleItem`, `Discount` with `decimal` types, `product_name_snapshot`

2. **Sales remote data source** — `suq/lib/features/sales/data/sales_remote.dart`
   Supabase queries: create sale + items + inventory adjustment in a single transaction

3. **Sales repository** — `suq/lib/features/sales/domain/sales_repository.dart`
   Interface + implementation combining local (stub) + remote

4. **Sales Riverpod providers** — `suq/lib/features/sales/presentation/providers/`
   Active sale state, product search, cart management

5. **New Sale screen** — `suq/lib/features/sales/presentation/screens/new_sale_screen.dart`
   Product search, add to cart, set quantity/price, apply discount, choose payment method, submit

6. **Sales list screen** — `suq/lib/features/sales/presentation/screens/sales_screen.dart`
   List today's sales, filter by date, tap to view detail

7. **Sale detail + void flow** — void requires reason, calls `PermissionService` for `sales.void`

8. **Inventory adjustment on sale** — auto-create `inventory_adjustments` record on each sale

9. **Wire sales route in router** — replace `_ShellPage` for `/sales` and `/sales/new`

---

## Follow-up — Phase 4 Modules

In order of business importance:

- **Inventory module** — product CRUD, stock levels, manual adjustments, low-stock alerts
- **Customers module** — customer list, credit balance, transaction history
- **Expenses module** — record expense, category picker, daily summary
- **Reports module** — daily/weekly/monthly summaries, export via `ExportService`
- **Staff module** — invite by email, assign role, suspend
- **Settings module** — shop name, branch management, inventory mode toggle, currency

---

## Optional Improvements

- Add `.gitattributes` to normalize CRLF warnings on Windows
- Wire Drift local DB for true offline-first (Phase 5)
- Add `SyncService` background polling when online
- Low-stock notification trigger via `NotificationService`
- Cash reconciliation screen
- Android SDK setup (currently Chrome-only)
- Install Android Studio to unblock Android builds

---

## Blocked / Unclear

- **Chapa payment integration** — out of scope v1, `payment_methods` table is ready
- **Amharic (am) localization** — l10n layer ready, translations not started
- **Drift schema** — needs design before Phase 5; must mirror all 6 Supabase domains
- **Supabase Edge Functions** for notifications — not yet written; `NotificationService` logs `pending` rows only
