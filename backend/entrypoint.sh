#!/bin/sh
set -e

echo "Running database migrations..."

# Apply all SQL files in /app/migrations
for f in /app/migrations/*.sql; do
    echo "Applying $f..."
    psql "postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME" -f "$f"
done

echo "Starting backend server..."
exec node src/server.js
