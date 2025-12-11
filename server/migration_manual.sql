-- Coal Mining FMS - Direct SQL Migration Script
-- Execute this script manually to apply all schema changes
-- Created: December 11, 2025
-- 
-- IMPORTANT: Backup your database before running!
-- pg_dump -U postgres -d miningdb > backup_$(date +%Y%m%d_%H%M%S).sql

BEGIN;

-- ============================================================================
-- 1. CREATE NEW TABLES
-- ============================================================================

-- 1.1 Leases Table
CREATE TABLE IF NOT EXISTS coal_mining.leases (
    id SERIAL PRIMARY KEY,
    lease_name VARCHAR(255) NOT NULL,
    location TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    created_by INTEGER,
    modified_by INTEGER,
    CONSTRAINT fk_lease_created_by FOREIGN KEY (created_by) REFERENCES coal_mining.users(id),
    CONSTRAINT fk_lease_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id)
);
CREATE INDEX IF NOT EXISTS idx_lease_name ON coal_mining.leases(lease_name);

-- 1.2 Client Types Table
CREATE TABLE IF NOT EXISTS coal_mining.client_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    created_by INTEGER,
    modified_by INTEGER,
    CONSTRAINT fk_client_type_created_by FOREIGN KEY (created_by) REFERENCES coal_mining.users(id),
    CONSTRAINT fk_client_type_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id)
);

-- Insert default client types
INSERT INTO coal_mining.client_types (name, description) VALUES
('Coal Agent', 'Coal purchasing agents'),
('Bhatta', 'Brick kiln operators'),
('Factory', 'Industrial factories')
ON CONFLICT (name) DO NOTHING;

-- 1.3 Expense Types Table
CREATE TABLE IF NOT EXISTS coal_mining.expense_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    created_by INTEGER,
    modified_by INTEGER,
    CONSTRAINT fk_expense_type_created_by FOREIGN KEY (created_by) REFERENCES coal_mining.users(id),
    CONSTRAINT fk_expense_type_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id)
);

-- Insert default expense types
INSERT INTO coal_mining.expense_types (name, description) VALUES
('Worker', 'Expenses related to workers'),
('Vendor', 'Expenses related to vendors/suppliers')
ON CONFLICT (name) DO NOTHING;

-- 1.4 Account Types Table
CREATE TABLE IF NOT EXISTS coal_mining.account_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    created_by INTEGER,
    modified_by INTEGER,
    CONSTRAINT fk_account_type_created_by FOREIGN KEY (created_by) REFERENCES coal_mining.users(id),
    CONSTRAINT fk_account_type_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id)
);

-- Insert default account types
INSERT INTO coal_mining.account_types (name, description) VALUES
('Asset', 'Asset accounts'),
('Liability', 'Liability accounts'),
('Equity', 'Equity accounts'),
('Revenue', 'Revenue accounts'),
('Expense', 'Expense accounts')
ON CONFLICT (name) DO NOTHING;

-- 1.5 General Ledger Table
CREATE TABLE IF NOT EXISTS coal_mining.general_ledger (
    id SERIAL PRIMARY KEY,
    account_code VARCHAR(50) NOT NULL,
    account_name VARCHAR(255) NOT NULL,
    account_type_id INTEGER NOT NULL,
    mining_site_id INTEGER NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    created_by INTEGER,
    modified_by INTEGER,
    CONSTRAINT fk_ledger_account_type FOREIGN KEY (account_type_id) REFERENCES coal_mining.account_types(id),
    CONSTRAINT fk_ledger_mining_site FOREIGN KEY (mining_site_id) REFERENCES coal_mining.mining_sites(id) ON DELETE CASCADE,
    CONSTRAINT fk_ledger_created_by FOREIGN KEY (created_by) REFERENCES coal_mining.users(id),
    CONSTRAINT fk_ledger_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id)
);
CREATE INDEX IF NOT EXISTS idx_ledger_account_code ON coal_mining.general_ledger(account_code);
CREATE INDEX IF NOT EXISTS idx_ledger_mining_site ON coal_mining.general_ledger(mining_site_id);
CREATE INDEX IF NOT EXISTS idx_ledger_account_type ON coal_mining.general_ledger(account_type_id);

-- 1.6 Liabilities Table
DO $$ BEGIN
    CREATE TYPE coal_mining.liability_type AS ENUM ('Loan', 'Advanced Payment');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE coal_mining.liability_status AS ENUM ('Active', 'Partially Settled', 'Fully Settled');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS coal_mining.liabilities (
    id SERIAL PRIMARY KEY,
    type coal_mining.liability_type NOT NULL,
    client_id INTEGER NOT NULL,
    mining_site_id INTEGER NOT NULL,
    date DATE NOT NULL,
    description TEXT,
    total_amount NUMERIC(12, 2) NOT NULL,
    remaining_balance NUMERIC(12, 2) DEFAULT 0,
    status coal_mining.liability_status DEFAULT 'Active',
    proof TEXT[],
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    created_by INTEGER,
    modified_by INTEGER,
    CONSTRAINT fk_liability_client FOREIGN KEY (client_id) REFERENCES coal_mining.clients(id) ON DELETE CASCADE,
    CONSTRAINT fk_liability_mining_site FOREIGN KEY (mining_site_id) REFERENCES coal_mining.mining_sites(id) ON DELETE CASCADE,
    CONSTRAINT fk_liability_created_by FOREIGN KEY (created_by) REFERENCES coal_mining.users(id),
    CONSTRAINT fk_liability_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id)
);
CREATE INDEX IF NOT EXISTS idx_liability_client ON coal_mining.liabilities(client_id);
CREATE INDEX IF NOT EXISTS idx_liability_mining_site ON coal_mining.liabilities(mining_site_id);
CREATE INDEX IF NOT EXISTS idx_liability_date ON coal_mining.liabilities(date);
CREATE INDEX IF NOT EXISTS idx_liability_status ON coal_mining.liabilities(status);

-- ============================================================================
-- 2. UPDATE EXISTING TABLES - ADD COLUMNS
-- ============================================================================

-- 2.1 Mining Sites - Add lease relationship and audit fields
ALTER TABLE coal_mining.mining_sites 
ADD COLUMN IF NOT EXISTS lease_id INTEGER,
ADD COLUMN IF NOT EXISTS created_by INTEGER,
ADD COLUMN IF NOT EXISTS modified_by INTEGER;

-- Add constraints if they don't exist
DO $$ BEGIN
    ALTER TABLE coal_mining.mining_sites 
    ADD CONSTRAINT fk_mining_site_lease FOREIGN KEY (lease_id) REFERENCES coal_mining.leases(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE coal_mining.mining_sites 
    ADD CONSTRAINT fk_mining_site_created_by FOREIGN KEY (created_by) REFERENCES coal_mining.users(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE coal_mining.mining_sites 
    ADD CONSTRAINT fk_mining_site_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

CREATE INDEX IF NOT EXISTS idx_mining_site_lease ON coal_mining.mining_sites(lease_id);

-- 2.2 Clients - Add client type and audit fields
ALTER TABLE coal_mining.clients 
ADD COLUMN IF NOT EXISTS client_type_id INTEGER,
ADD COLUMN IF NOT EXISTS modified_by INTEGER;

DO $$ BEGIN
    ALTER TABLE coal_mining.clients 
    ADD CONSTRAINT fk_client_type FOREIGN KEY (client_type_id) REFERENCES coal_mining.client_types(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE coal_mining.clients 
    ADD CONSTRAINT fk_client_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

CREATE INDEX IF NOT EXISTS idx_client_type ON coal_mining.clients(client_type_id);

-- 2.3 Expenses - Add new fields
ALTER TABLE coal_mining.expenses 
ADD COLUMN IF NOT EXISTS expense_type_id INTEGER,
ADD COLUMN IF NOT EXISTS worker_id INTEGER,
ADD COLUMN IF NOT EXISTS client_id INTEGER,
ADD COLUMN IF NOT EXISTS proof TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS modified_by INTEGER;

DO $$ BEGIN
    ALTER TABLE coal_mining.expenses 
    ADD CONSTRAINT fk_expense_type FOREIGN KEY (expense_type_id) REFERENCES coal_mining.expense_types(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE coal_mining.expenses 
    ADD CONSTRAINT fk_expense_worker FOREIGN KEY (worker_id) REFERENCES coal_mining.workers(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE coal_mining.expenses 
    ADD CONSTRAINT fk_expense_client FOREIGN KEY (client_id) REFERENCES coal_mining.clients(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE coal_mining.expenses 
    ADD CONSTRAINT fk_expense_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

CREATE INDEX IF NOT EXISTS idx_expense_type ON coal_mining.expenses(expense_type_id);
CREATE INDEX IF NOT EXISTS idx_expense_worker ON coal_mining.expenses(worker_id);
CREATE INDEX IF NOT EXISTS idx_expense_client ON coal_mining.expenses(client_id);

-- 2.4 Income - Add liability tracking fields
ALTER TABLE coal_mining.income 
ADD COLUMN IF NOT EXISTS client_id INTEGER,
ADD COLUMN IF NOT EXISTS amount_from_liability NUMERIC(12, 2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS liability_id INTEGER,
ADD COLUMN IF NOT EXISTS modified_by INTEGER;

DO $$ BEGIN
    ALTER TABLE coal_mining.income 
    ADD CONSTRAINT fk_income_client FOREIGN KEY (client_id) REFERENCES coal_mining.clients(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE coal_mining.income 
    ADD CONSTRAINT fk_income_liability FOREIGN KEY (liability_id) REFERENCES coal_mining.liabilities(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE coal_mining.income 
    ADD CONSTRAINT fk_income_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

CREATE INDEX IF NOT EXISTS idx_income_client ON coal_mining.income(client_id);
CREATE INDEX IF NOT EXISTS idx_income_liability ON coal_mining.income(liability_id);

-- 2.5 Partners - Add lease and mining site relationships
ALTER TABLE coal_mining.partners 
ADD COLUMN IF NOT EXISTS lease_id INTEGER,
ADD COLUMN IF NOT EXISTS mining_site_id INTEGER,
ADD COLUMN IF NOT EXISTS created_by INTEGER,
ADD COLUMN IF NOT EXISTS modified_by INTEGER;

DO $$ BEGIN
    ALTER TABLE coal_mining.partners 
    ADD CONSTRAINT fk_partner_lease FOREIGN KEY (lease_id) REFERENCES coal_mining.leases(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE coal_mining.partners 
    ADD CONSTRAINT fk_partner_mining_site FOREIGN KEY (mining_site_id) REFERENCES coal_mining.mining_sites(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE coal_mining.partners 
    ADD CONSTRAINT fk_partner_created_by FOREIGN KEY (created_by) REFERENCES coal_mining.users(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE coal_mining.partners 
    ADD CONSTRAINT fk_partner_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

CREATE INDEX IF NOT EXISTS idx_partner_lease ON coal_mining.partners(lease_id);
CREATE INDEX IF NOT EXISTS idx_partner_mining_site ON coal_mining.partners(mining_site_id);

-- 2.6 Equipment - Add audit fields
ALTER TABLE coal_mining.equipment 
ADD COLUMN IF NOT EXISTS created_by INTEGER,
ADD COLUMN IF NOT EXISTS modified_by INTEGER;

DO $$ BEGIN
    ALTER TABLE coal_mining.equipment 
    ADD CONSTRAINT fk_equipment_created_by FOREIGN KEY (created_by) REFERENCES coal_mining.users(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE coal_mining.equipment 
    ADD CONSTRAINT fk_equipment_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2.7 Production - Add audit fields
ALTER TABLE coal_mining.production 
ADD COLUMN IF NOT EXISTS created_by INTEGER,
ADD COLUMN IF NOT EXISTS modified_by INTEGER;

DO $$ BEGIN
    ALTER TABLE coal_mining.production 
    ADD CONSTRAINT fk_production_created_by FOREIGN KEY (created_by) REFERENCES coal_mining.users(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE coal_mining.production 
    ADD CONSTRAINT fk_production_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2.8 Workers - Add audit fields
ALTER TABLE coal_mining.workers 
ADD COLUMN IF NOT EXISTS created_by INTEGER,
ADD COLUMN IF NOT EXISTS modified_by INTEGER;

DO $$ BEGIN
    ALTER TABLE coal_mining.workers 
    ADD CONSTRAINT fk_worker_created_by FOREIGN KEY (created_by) REFERENCES coal_mining.users(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE coal_mining.workers 
    ADD CONSTRAINT fk_worker_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ============================================================================
-- 3. INSERT MIGRATION RECORD
-- ============================================================================

INSERT INTO coal_mining.migrations (timestamp, name)
VALUES (1765481906729, 'ComprehensiveSchemaUpdate1765481906729')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- COMMIT
-- ============================================================================

COMMIT;

-- Verification queries
SELECT 'Leases table:' as info, COUNT(*) as count FROM coal_mining.leases;
SELECT 'Client Types:' as info, COUNT(*) as count FROM coal_mining.client_types;
SELECT 'Expense Types:' as info, COUNT(*) as count FROM coal_mining.expense_types;
SELECT 'Account Types:' as info, COUNT(*) as count FROM coal_mining.account_types;
SELECT 'General Ledger:' as info, COUNT(*) as count FROM coal_mining.general_ledger;
SELECT 'Liabilities:' as info, COUNT(*) as count FROM coal_mining.liabilities;

-- Check column additions
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'coal_mining' 
AND table_name = 'mining_sites' 
AND column_name IN ('lease_id', 'created_by', 'modified_by');

SELECT 'Migration completed successfully!' as status;
