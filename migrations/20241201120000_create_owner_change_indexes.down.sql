-- Migration: 20241201120000_create_owner_change_indexes
-- Description: Rollback optimized indexes for owner_change table
-- 
-- This rollback migration removes the indexes created to optimize owner_change queries

-- ================================
-- DOWN MIGRATION - Rollback Changes
-- ================================

-- Remove the composite partial index
DROP INDEX CONCURRENTLY IF EXISTS idx_owner_change_optimization;

-- Remove the organization_id-based index
DROP INDEX CONCURRENTLY IF EXISTS idx_owner_change_org_status;

-- Remove the superlabel_code-based index
DROP INDEX CONCURRENTLY IF EXISTS idx_owner_change_superlabel_status;