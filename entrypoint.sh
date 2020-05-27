#!/bin/bash
# Docker entrypoint script.

# Wait until Postgres is ready
while ! pg_isready -q -h $PGHOST -p $PGPORT -U $PGUSER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

# Create, database if it doesn't exist.
if [[ -z `psql -Atqc "\\list $PGDATABASE"` ]]; then
  echo "Database $PGDATABASE does not exist. Creating..."
  createdb -E UTF8 $PGDATABASE -l en_US.UTF-8 -T template0
  echo "Database $PGDATABASE created."
fi

# Setup
function setup_db() {
  mv config/${MIX_ENV}.exs config/config_backup.tmp
  # using current environment, so that mix does not compile everything once more
  envsubst < config/migrations.exs > config/${MIX_ENV}.exs 
  mix ecto.migrate --migrations-path priv/postgres/migrations
  mv config/config_backup.tmp config/${MIX_ENV}.exs 
}

setup_db

exec mix phx.server

