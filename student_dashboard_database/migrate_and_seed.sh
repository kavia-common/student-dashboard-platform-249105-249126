#!/bin/bash
set -euo pipefail

# Runs schema migrations + seed in an idempotent way.
# Intended to be called by startup.sh after the database server is available.

DB_NAME="${DB_NAME:-myapp}"
DB_USER="${DB_USER:-appuser}"
DB_PASSWORD="${DB_PASSWORD:-dbuser123}"
DB_PORT="${DB_PORT:-5000}"

# Find PostgreSQL version and set paths
PG_VERSION=$(ls /usr/lib/postgresql/ | head -1)
PG_BIN="/usr/lib/postgresql/${PG_VERSION}/bin"

export PGPASSWORD="${DB_PASSWORD}"

echo "Running migrations/seeds against postgres://${DB_USER}@localhost:${DB_PORT}/${DB_NAME}"

# Use ON_ERROR_STOP so startup fails fast if the schema can't be applied
PSQL_BASE=( "${PG_BIN}/psql" -v ON_ERROR_STOP=1 -h localhost -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" )

# Ensure schema_migrations table exists (for tracking which migrations ran)
"${PSQL_BASE[@]}" -c "
CREATE TABLE IF NOT EXISTS public.schema_migrations (
  version TEXT PRIMARY KEY,
  applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
"

apply_migration () {
  local version="$1"
  local file="$2"

  # Check if already applied
  if "${PSQL_BASE[@]}" -tAc "SELECT 1 FROM public.schema_migrations WHERE version='${version}'" | grep -q 1; then
    echo "✓ Migration ${version} already applied"
    return 0
  fi

  echo "Applying migration ${version} from ${file}"
  "${PSQL_BASE[@]}" -f "${file}"
  "${PSQL_BASE[@]}" -c "INSERT INTO public.schema_migrations(version) VALUES('${version}')"
  echo "✓ Migration ${version} applied"
}

# Apply migrations in version order
MIGRATIONS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/migrations"

apply_migration "001_init_schema" "${MIGRATIONS_DIR}/001_init_schema.sql"
apply_migration "002_seed_demo_data" "${MIGRATIONS_DIR}/002_seed_demo_data.sql"

echo "Migrations and seeds complete."
