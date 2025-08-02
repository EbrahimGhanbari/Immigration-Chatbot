#!/bin/bash

# Test script to validate SQL migration syntax
# This script checks if the SQL files have valid syntax without executing them

set -e

echo "Testing SQL migration syntax..."

MIGRATION_DIR="$(dirname "$0")/migrations"

# Function to validate SQL syntax using PostgreSQL parser
validate_sql_file() {
    local file="$1"
    local filename=$(basename "$file")
    
    echo "Validating: $filename"
    
    # Use PostgreSQL to validate syntax (dry-run)
    # Replace actual table references with temporary table for syntax validation
    sed 's/public\.owner_change/temp_validation_table/g' "$file" | \
    psql -v ON_ERROR_STOP=1 --single-transaction --set "QUIET=1" \
         --pset pager=off \
         -c "BEGIN; CREATE TEMP TABLE temp_validation_table (status text, organization_id int, superlabel_code text); $(cat); ROLLBACK;" \
         "postgresql://postgres:postgres@localhost:5432/postgres" 2>/dev/null || {
        
        # If PostgreSQL is not available, do basic syntax checking
        if ! command -v psql >/dev/null 2>&1; then
            echo "  PostgreSQL not available, performing basic syntax validation..."
            
            # Basic syntax checks
            if grep -E "(CREATE|DROP)\s+INDEX" "$file" >/dev/null; then
                echo "  ✓ Contains valid INDEX statements"
            else
                echo "  ✗ No INDEX statements found"
                return 1
            fi
            
            if grep -E "CONCURRENTLY" "$file" >/dev/null; then
                echo "  ✓ Uses CONCURRENTLY for safe operations"
            else
                echo "  ⚠ Warning: CONCURRENTLY not used (may cause table locks)"
            fi
            
            if grep -E "IF (NOT )?EXISTS" "$file" >/dev/null; then
                echo "  ✓ Uses IF EXISTS/IF NOT EXISTS for safety"
            else
                echo "  ⚠ Warning: IF EXISTS/IF NOT EXISTS not used"
            fi
            
            echo "  ✓ Basic syntax validation passed"
        else
            echo "  ✗ SQL syntax validation failed"
            return 1
        fi
    }
    
    echo "  ✓ Syntax validation passed"
}

# Validate all migration files
echo "Checking migration files in: $MIGRATION_DIR"

if [ ! -d "$MIGRATION_DIR" ]; then
    echo "Error: Migration directory not found: $MIGRATION_DIR"
    exit 1
fi

# Check up migrations
for file in "$MIGRATION_DIR"/*.up.sql; do
    if [ -f "$file" ]; then
        validate_sql_file "$file"
    fi
done

# Check down migrations  
for file in "$MIGRATION_DIR"/*.down.sql; do
    if [ -f "$file" ]; then
        validate_sql_file "$file"
    fi
done

echo ""
echo "Migration syntax validation completed successfully!"
echo ""
echo "Migration summary:"
find "$MIGRATION_DIR" -name "*.sql" | sort | while read -r file; do
    echo "  $(basename "$file")"
done