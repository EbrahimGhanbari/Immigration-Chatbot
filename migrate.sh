#!/bin/bash

# Database Migration Script for Immigration Chatbot
# Usage: ./migrate.sh [up|down] [migration_name]

set -e

# Database connection parameters (from local-temporal-server.yaml)
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-temporal}"
DB_USER="${DB_USER:-temporal}"
DB_PASSWORD="${DB_PASSWORD:-temporal}"

# Migration directory
MIGRATION_DIR="$(dirname "$0")/migrations"

# Function to display usage
usage() {
    echo "Usage: $0 [up|down] [migration_name]"
    echo ""
    echo "Commands:"
    echo "  up     - Apply migration(s)"
    echo "  down   - Rollback migration(s)"
    echo ""
    echo "Examples:"
    echo "  $0 up                                    # Apply all pending migrations"
    echo "  $0 up 20241201120000_create_owner_change_indexes    # Apply specific migration"
    echo "  $0 down 20241201120000_create_owner_change_indexes  # Rollback specific migration"
    echo ""
    echo "Environment Variables:"
    echo "  DB_HOST      - Database host (default: localhost)"
    echo "  DB_PORT      - Database port (default: 5432)"
    echo "  DB_NAME      - Database name (default: temporal)"
    echo "  DB_USER      - Database user (default: temporal)"
    echo "  DB_PASSWORD  - Database password (default: temporal)"
}

# Function to check if PostgreSQL is accessible
check_db_connection() {
    echo "Checking database connection..."
    if ! PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c '\q' 2>/dev/null; then
        echo "Error: Cannot connect to database."
        echo "Make sure PostgreSQL is running and connection parameters are correct."
        echo "You can start the database with: make temporal_up"
        exit 1
    fi
    echo "Database connection successful."
}

# Function to apply migration
apply_migration() {
    local migration_file="$1"
    local migration_name=$(basename "$migration_file" .up.sql)
    
    echo "Applying migration: $migration_name"
    
    if [ ! -f "$migration_file" ]; then
        echo "Error: Migration file not found: $migration_file"
        exit 1
    fi
    
    PGPASSWORD="$DB_PASSWORD" psql \
        -h "$DB_HOST" \
        -p "$DB_PORT" \
        -U "$DB_USER" \
        -d "$DB_NAME" \
        -f "$migration_file"
    
    echo "Migration applied successfully: $migration_name"
}

# Function to rollback migration
rollback_migration() {
    local migration_file="$1"
    local migration_name=$(basename "$migration_file" .down.sql)
    
    echo "Rolling back migration: $migration_name"
    
    if [ ! -f "$migration_file" ]; then
        echo "Error: Migration file not found: $migration_file"
        exit 1
    fi
    
    PGPASSWORD="$DB_PASSWORD" psql \
        -h "$DB_HOST" \
        -p "$DB_PORT" \
        -U "$DB_USER" \
        -d "$DB_NAME" \
        -f "$migration_file"
    
    echo "Migration rolled back successfully: $migration_name"
}

# Function to list available migrations
list_migrations() {
    echo "Available migrations:"
    find "$MIGRATION_DIR" -name "*.up.sql" | sort | while read -r file; do
        migration_name=$(basename "$file" .up.sql)
        echo "  $migration_name"
    done
}

# Main script logic
main() {
    local command="$1"
    local migration_name="$2"
    
    # Check if migration directory exists
    if [ ! -d "$MIGRATION_DIR" ]; then
        echo "Error: Migration directory not found: $MIGRATION_DIR"
        exit 1
    fi
    
    case "$command" in
        "up")
            check_db_connection
            if [ -n "$migration_name" ]; then
                # Apply specific migration
                migration_file="$MIGRATION_DIR/${migration_name}.up.sql"
                apply_migration "$migration_file"
            else
                # Apply all migrations
                find "$MIGRATION_DIR" -name "*.up.sql" | sort | while read -r file; do
                    apply_migration "$file"
                done
            fi
            ;;
        "down")
            check_db_connection
            if [ -n "$migration_name" ]; then
                # Rollback specific migration
                migration_file="$MIGRATION_DIR/${migration_name}.down.sql"
                rollback_migration "$migration_file"
            else
                echo "Error: Migration name is required for rollback"
                echo "Use: $0 down [migration_name]"
                list_migrations
                exit 1
            fi
            ;;
        "list")
            list_migrations
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"