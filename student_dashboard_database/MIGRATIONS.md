# Database migrations & seed (student_dashboard_database)

This Postgres container uses a simple, deterministic migration runner that executes SQL files in order and records applied versions in a `schema_migrations` table.

## How it runs

`startup.sh`:
1. Starts Postgres on the configured port
2. Creates the database (`myapp`) and user (`appuser`) if needed
3. Calls `./migrate_and_seed.sh` which:
   - Ensures `public.schema_migrations` exists
   - Applies migration SQL files (once each), recording versions

## Where migrations live

- `migrations/001_init_schema.sql` – creates all tables/enums/indexes
- `migrations/002_seed_demo_data.sql` – inserts baseline demo data

## Adding a new migration

1. Create a new file in `migrations/` using the next version number, e.g.:
   - `migrations/003_add_something.sql`
2. Update `migrate_and_seed.sh` to call `apply_migration "003_add_something" "migrations/003_add_something.sql"`

Notes:
- Keep migrations **idempotent** when possible (`IF NOT EXISTS`, `ON CONFLICT DO NOTHING`).
- If you need to change existing columns/constraints, make the migration safe to apply once and safe to re-run where possible.

## Demo data

Seed creates demo accounts:

- `student1@example.com` (role: student)
- `student2@example.com` (role: student)
- `teacher1@example.com` (role: teacher)
- `admin1@example.com` (role: admin)

`password_hash` values are placeholders; the backend authentication layer should manage real password hashing and storage.

## Connecting

See `db_connection.txt` for the canonical `psql postgresql://...` connection string.
