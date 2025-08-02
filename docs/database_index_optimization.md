# Owner Change Table Index Optimization

## Overview

This document describes the database index optimization implemented for the `owner_change` table to improve query performance.

## Problematic Query

The following query was experiencing performance issues due to lack of proper indexing:

```sql
SELECT status AS accountstatus
FROM public.owner_change oc
WHERE ($1 <> 0 AND organization_id = $1) OR ($2 <> '' AND superlabel_code = $2)
AND oc.status IN ('Draft', 'PendingDeletion')
```

## Query Analysis

### Performance Issues
- **Full table scans**: Without proper indexes, the database was scanning the entire table
- **Complex WHERE conditions**: OR conditions with multiple parameters made optimization challenging
- **Status filtering**: Always filters for specific status values, making partial indexing beneficial

### Query Characteristics
- Uses `organization_id`, `superlabel_code`, and `status` columns
- OR condition between `organization_id` and `superlabel_code`
- Always filters for status values: 'Draft' and 'PendingDeletion'

## Index Strategy

### Primary Solution: Composite Partial Index

```sql
CREATE INDEX idx_owner_change_optimization 
ON public.owner_change (status, organization_id, superlabel_code)
WHERE status IN ('Draft', 'PendingDeletion');
```

**Benefits:**
- **Partial index**: Only indexes rows with relevant status values, reducing index size
- **Column order**: `status` first for optimal selectivity
- **Complete coverage**: Covers all WHERE clause columns
- **Space efficient**: Smaller index size due to partial condition

### Alternative Solution: Separate Targeted Indexes

```sql
-- For organization_id queries
CREATE INDEX idx_owner_change_org_status 
ON public.owner_change (organization_id, status)
WHERE status IN ('Draft', 'PendingDeletion');

-- For superlabel_code queries  
CREATE INDEX idx_owner_change_superlabel_status
ON public.owner_change (superlabel_code, status)
WHERE status IN ('Draft', 'PendingDeletion');
```

**Benefits:**
- **Query-specific**: Each index optimized for specific query pattern
- **Highly selective**: Very targeted for individual OR conditions
- **Redundancy**: Backup approach if composite index doesn't perform as expected

## Performance Testing

### Before Testing
To validate the performance improvement, run these tests before applying the migration:

```sql
-- Test query performance before optimization
EXPLAIN (ANALYZE, BUFFERS) 
SELECT status AS accountstatus
FROM public.owner_change oc
WHERE (123 <> 0 AND organization_id = 123) OR ('' <> '' AND superlabel_code = 'TEST')
AND oc.status IN ('Draft', 'PendingDeletion');
```

### After Testing
After applying the migration, run the same query to measure improvement:

```sql
-- Test query performance after optimization
EXPLAIN (ANALYZE, BUFFERS) 
SELECT status AS accountstatus
FROM public.owner_change oc
WHERE (123 <> 0 AND organization_id = 123) OR ('' <> '' AND superlabel_code = 'TEST')
AND oc.status IN ('Draft', 'PendingDeletion');
```

### Performance Metrics to Monitor
- **Execution time**: Should see significant reduction
- **Index scans vs. Seq scans**: Should prefer index scans
- **Buffers hit**: Should see improved buffer utilization
- **Cost estimates**: Query planner cost should be lower

## Index Maintenance

### Monitoring
- Monitor index usage with `pg_stat_user_indexes`
- Check index size growth with `pg_indexes`
- Validate query plans regularly

### Maintenance Commands
```sql
-- Check index usage statistics
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch 
FROM pg_stat_user_indexes 
WHERE indexname LIKE 'idx_owner_change%';

-- Check index sizes
SELECT indexname, pg_size_pretty(pg_relation_size(indexname::regclass)) as size
FROM pg_indexes 
WHERE indexname LIKE 'idx_owner_change%';

-- Rebuild indexes if needed (rarely required)
REINDEX INDEX CONCURRENTLY idx_owner_change_optimization;
```

## Migration Files

- **Up migration**: `migrations/20241201120000_create_owner_change_indexes.up.sql`
- **Down migration**: `migrations/20241201120000_create_owner_change_indexes.down.sql`

## Rollback Plan

If performance degrades or issues arise, the indexes can be safely removed using the down migration:

```bash
# Using migration tool
migrate -path ./migrations -database "postgres://temporal:temporal@localhost/temporal?sslmode=disable" down 1

# Or directly via SQL
psql -h localhost -U temporal -d temporal -f migrations/20241201120000_create_owner_change_indexes.down.sql
```

## Best Practices Applied

1. **CONCURRENTLY**: All index operations use `CONCURRENTLY` to avoid table locks
2. **IF NOT EXISTS**: Prevents errors on re-execution
3. **Partial indexes**: Reduces index size and maintenance overhead
4. **Proper naming**: Clear, descriptive index names following convention
5. **Documentation**: Comprehensive documentation for maintenance and troubleshooting