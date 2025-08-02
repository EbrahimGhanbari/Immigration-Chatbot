-- Migration: 20241201120000_create_owner_change_indexes
-- Description: Create optimized indexes for owner_change table query performance
-- 
-- This migration creates indexes to optimize the following query:
-- SELECT status AS accountstatus 
-- FROM public.owner_change oc 
-- WHERE ($1 <> 0 AND organization_id = $1) OR ($2 <> '' AND superlabel_code = $2) 
-- AND oc.status IN ('Draft', 'PendingDeletion')

-- ================================
-- UP MIGRATION - Apply Changes
-- ================================

-- Primary recommendation: Composite partial index for optimal performance
-- This index covers all columns in the WHERE clause with a partial condition
-- to only index rows with the relevant status values
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_owner_change_optimization 
ON public.owner_change (status, organization_id, superlabel_code)
WHERE status IN ('Draft', 'PendingDeletion');

-- Alternative approach: Separate indexes for each query pattern
-- These provide more targeted optimization for specific query variations

-- Index for organization_id-based queries
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_owner_change_org_status 
ON public.owner_change (organization_id, status)
WHERE status IN ('Draft', 'PendingDeletion');

-- Index for superlabel_code-based queries  
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_owner_change_superlabel_status
ON public.owner_change (superlabel_code, status)
WHERE status IN ('Draft', 'PendingDeletion');

-- ================================
-- DOWN MIGRATION - Rollback Changes
-- ================================

-- Note: To execute rollback, run the following commands:
-- DROP INDEX CONCURRENTLY IF EXISTS idx_owner_change_optimization;
-- DROP INDEX CONCURRENTLY IF EXISTS idx_owner_change_org_status;
-- DROP INDEX CONCURRENTLY IF EXISTS idx_owner_change_superlabel_status;