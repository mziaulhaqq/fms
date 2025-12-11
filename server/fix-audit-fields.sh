#!/bin/bash

# Script to fix NULL audit fields in existing data
# This will set createdById and modifiedById to 1 (admin user) for any NULL values

echo "🔧 Fixing audit fields for existing records..."

# Get the database connection details from .env
source .env

# SQL to update NULL audit fields
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USERNAME -d $DB_NAME << EOF

-- Update leases
UPDATE coal_mining.leases 
SET created_by = 1, modified_by = 1 
WHERE created_by IS NULL OR modified_by IS NULL;

-- Update general_ledger
UPDATE coal_mining.general_ledger 
SET created_by = 1, modified_by = 1 
WHERE created_by IS NULL OR modified_by IS NULL;

-- Update liabilities
UPDATE coal_mining.liabilities 
SET created_by = 1, modified_by = 1 
WHERE created_by IS NULL OR modified_by IS NULL;

-- Update expenses (existing records)
UPDATE coal_mining.expenses 
SET created_by = 1, modified_by = 1 
WHERE created_by IS NULL OR modified_by IS NULL;

-- Update income (existing records)
UPDATE coal_mining.income 
SET created_by = 1, modified_by = 1 
WHERE created_by IS NULL OR modified_by IS NULL;

-- Update mining_sites (existing records)
UPDATE coal_mining.mining_sites 
SET created_by = 1, modified_by = 1 
WHERE created_by IS NULL OR modified_by IS NULL;

-- Update clients (existing records)
UPDATE coal_mining.clients 
SET created_by = 1, modified_by = 1 
WHERE created_by IS NULL OR modified_by IS NULL;

-- Update partners (existing records)
UPDATE coal_mining.partners 
SET created_by = 1, modified_by = 1 
WHERE created_by IS NULL OR modified_by IS NULL;

-- Show results
SELECT 'Leases fixed:' as table_name, COUNT(*) as count FROM coal_mining.leases WHERE created_by = 1
UNION ALL
SELECT 'General Ledger fixed:', COUNT(*) FROM coal_mining.general_ledger WHERE created_by = 1
UNION ALL
SELECT 'Liabilities fixed:', COUNT(*) FROM coal_mining.liabilities WHERE created_by = 1
UNION ALL
SELECT 'Expenses fixed:', COUNT(*) FROM coal_mining.expenses WHERE created_by = 1
UNION ALL
SELECT 'Income fixed:', COUNT(*) FROM coal_mining.income WHERE created_by = 1;

EOF

echo "✅ Audit fields fixed! All NULL values set to user ID 1 (admin)"
