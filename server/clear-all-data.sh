#!/bin/bash

# Script to clear all data from the database
# This will delete all records but keep the table structure

echo "⚠️  WARNING: This will delete ALL data from the database!"
echo "Are you sure you want to continue? (yes/no)"
read -r response

if [ "$response" != "yes" ]; then
    echo "❌ Operation cancelled"
    exit 0
fi

echo "🗑️  Clearing all data from database..."

# Get the database connection details from .env
source .env

# SQL to delete all data (in correct order to respect foreign keys)
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USERNAME -d $DB_DATABASE << EOF

-- Disable foreign key checks temporarily
SET session_replication_role = 'replica';

-- Delete data from all tables
TRUNCATE TABLE coal_mining.profit_distributions CASCADE;
TRUNCATE TABLE coal_mining.liabilities CASCADE;
TRUNCATE TABLE coal_mining.general_ledger CASCADE;
TRUNCATE TABLE coal_mining.income CASCADE;
TRUNCATE TABLE coal_mining.expenses CASCADE;
TRUNCATE TABLE coal_mining.expense_categories CASCADE;
TRUNCATE TABLE coal_mining.workers CASCADE;
TRUNCATE TABLE coal_mining.partners CASCADE;
TRUNCATE TABLE coal_mining.clients CASCADE;
TRUNCATE TABLE coal_mining.mining_sites CASCADE;
TRUNCATE TABLE coal_mining.leases CASCADE;
TRUNCATE TABLE coal_mining.account_types CASCADE;
TRUNCATE TABLE coal_mining.expense_types CASCADE;
TRUNCATE TABLE coal_mining.client_types CASCADE;

-- Keep users and roles
-- TRUNCATE TABLE coal_mining.users CASCADE;
-- TRUNCATE TABLE coal_mining.roles CASCADE;
-- TRUNCATE TABLE coal_mining.user_assigned_roles CASCADE;

-- Re-enable foreign key checks
SET session_replication_role = 'origin';

-- Reset sequences to start from 1
ALTER SEQUENCE coal_mining.client_types_id_seq RESTART WITH 1;
ALTER SEQUENCE coal_mining.expense_types_id_seq RESTART WITH 1;
ALTER SEQUENCE coal_mining.account_types_id_seq RESTART WITH 1;
ALTER SEQUENCE coal_mining.leases_id_seq RESTART WITH 1;
ALTER SEQUENCE coal_mining.mining_sites_id_seq RESTART WITH 1;
ALTER SEQUENCE coal_mining.clients_id_seq RESTART WITH 1;
ALTER SEQUENCE coal_mining.partners_id_seq RESTART WITH 1;
ALTER SEQUENCE coal_mining.workers_id_seq RESTART WITH 1;
ALTER SEQUENCE coal_mining.expense_categories_id_seq RESTART WITH 1;
ALTER SEQUENCE coal_mining.expenses_id_seq RESTART WITH 1;
ALTER SEQUENCE coal_mining.income_id_seq RESTART WITH 1;
ALTER SEQUENCE coal_mining.general_ledger_id_seq RESTART WITH 1;
ALTER SEQUENCE coal_mining.liabilities_id_seq RESTART WITH 1;
ALTER SEQUENCE coal_mining.profit_distributions_id_seq RESTART WITH 1;

SELECT 'Data cleared successfully!' as status;

EOF

echo "✅ All data cleared! Database is now empty."
echo "✅ Users and roles are preserved."
echo "✅ You can now create data from the mobile app."
