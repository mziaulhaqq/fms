import { MigrationInterface, QueryRunner } from "typeorm";

export class ComprehensiveSchemaUpdate1765481906729 implements MigrationInterface {

    public async up(queryRunner: QueryRunner): Promise<void> {
        // 1. Create Leases table
        await queryRunner.query(`
            CREATE TABLE coal_mining.leases (
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
        `);
        await queryRunner.query(`CREATE INDEX idx_lease_name ON coal_mining.leases(lease_name);`);

        // 2. Create Client Types table
        await queryRunner.query(`
            CREATE TABLE coal_mining.client_types (
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
        `);

        // 3. Create Expense Types table
        await queryRunner.query(`
            CREATE TABLE coal_mining.expense_types (
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
        `);

        // 4. Create Account Types table
        await queryRunner.query(`
            CREATE TABLE coal_mining.account_types (
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
        `);

        // 5. Insert default account types
        await queryRunner.query(`
            INSERT INTO coal_mining.account_types (name, description) VALUES
            ('Asset', 'Asset accounts'),
            ('Liability', 'Liability accounts'),
            ('Equity', 'Equity accounts'),
            ('Revenue', 'Revenue accounts'),
            ('Expense', 'Expense accounts');
        `);

        // 6. Insert default client types
        await queryRunner.query(`
            INSERT INTO coal_mining.client_types (name, description) VALUES
            ('Coal Agent', 'Coal purchasing agents'),
            ('Bhatta', 'Brick kiln operators'),
            ('Factory', 'Industrial factories');
        `);

        // 7. Insert default expense types
        await queryRunner.query(`
            INSERT INTO coal_mining.expense_types (name, description) VALUES
            ('Worker', 'Expenses related to workers'),
            ('Vendor', 'Expenses related to vendors/suppliers');
        `);

        // 8. Create General Ledger table
        await queryRunner.query(`
            CREATE TABLE coal_mining.general_ledger (
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
        `);
        await queryRunner.query(`CREATE INDEX idx_ledger_account_code ON coal_mining.general_ledger(account_code);`);
        await queryRunner.query(`CREATE INDEX idx_ledger_mining_site ON coal_mining.general_ledger(mining_site_id);`);

        // 9. Create Liabilities table
        await queryRunner.query(`
            CREATE TYPE coal_mining.liability_type AS ENUM ('Loan', 'Advanced Payment');
            CREATE TYPE coal_mining.liability_status AS ENUM ('Active', 'Partially Settled', 'Fully Settled');
            
            CREATE TABLE coal_mining.liabilities (
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
        `);
        await queryRunner.query(`CREATE INDEX idx_liability_client ON coal_mining.liabilities(client_id);`);
        await queryRunner.query(`CREATE INDEX idx_liability_mining_site ON coal_mining.liabilities(mining_site_id);`);
        await queryRunner.query(`CREATE INDEX idx_liability_date ON coal_mining.liabilities(date);`);

        // 10. Add lease_id to mining_sites
        await queryRunner.query(`
            ALTER TABLE coal_mining.mining_sites 
            ADD COLUMN lease_id INTEGER,
            ADD COLUMN created_by INTEGER,
            ADD COLUMN modified_by INTEGER,
            ADD CONSTRAINT fk_mining_site_lease FOREIGN KEY (lease_id) REFERENCES coal_mining.leases(id),
            ADD CONSTRAINT fk_mining_site_created_by FOREIGN KEY (created_by) REFERENCES coal_mining.users(id),
            ADD CONSTRAINT fk_mining_site_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id);
        `);
        await queryRunner.query(`CREATE INDEX idx_mining_site_lease ON coal_mining.mining_sites(lease_id);`);

        // 11. Update clients table
        await queryRunner.query(`
            ALTER TABLE coal_mining.clients 
            ADD COLUMN client_type_id INTEGER,
            ADD COLUMN modified_by INTEGER,
            ADD CONSTRAINT fk_client_type FOREIGN KEY (client_type_id) REFERENCES coal_mining.client_types(id),
            ADD CONSTRAINT fk_client_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id);
        `);
        await queryRunner.query(`CREATE INDEX idx_client_type ON coal_mining.clients(client_type_id);`);

        // 12. Update expenses table
        await queryRunner.query(`
            ALTER TABLE coal_mining.expenses 
            ADD COLUMN expense_type_id INTEGER,
            ADD COLUMN worker_id INTEGER,
            ADD COLUMN client_id INTEGER,
            ADD COLUMN proof TEXT[] DEFAULT '{}',
            ADD COLUMN modified_by INTEGER,
            DROP COLUMN IF EXISTS evidence_photos,
            DROP COLUMN IF EXISTS payment_proof,
            DROP COLUMN IF EXISTS account_type,
            DROP COLUMN IF EXISTS payee_type,
            ADD CONSTRAINT fk_expense_type FOREIGN KEY (expense_type_id) REFERENCES coal_mining.expense_types(id),
            ADD CONSTRAINT fk_expense_worker FOREIGN KEY (worker_id) REFERENCES coal_mining.workers(id),
            ADD CONSTRAINT fk_expense_client FOREIGN KEY (client_id) REFERENCES coal_mining.clients(id),
            ADD CONSTRAINT fk_expense_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id);
        `);
        await queryRunner.query(`CREATE INDEX idx_expense_type ON coal_mining.expenses(expense_type_id);`);

        // 13. Update income table
        await queryRunner.query(`
            ALTER TABLE coal_mining.income 
            ADD COLUMN client_id INTEGER,
            ADD COLUMN amount_from_liability NUMERIC(12, 2) DEFAULT 0,
            ADD COLUMN liability_id INTEGER,
            ADD COLUMN modified_by INTEGER,
            ADD CONSTRAINT fk_income_client FOREIGN KEY (client_id) REFERENCES coal_mining.clients(id),
            ADD CONSTRAINT fk_income_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id);
        `);
        await queryRunner.query(`CREATE INDEX idx_income_client ON coal_mining.income(client_id);`);

        // 14. Update partners table
        await queryRunner.query(`
            ALTER TABLE coal_mining.partners 
            ADD COLUMN lease_id INTEGER,
            ADD COLUMN mining_site_id INTEGER,
            ADD COLUMN created_by INTEGER,
            ADD COLUMN modified_by INTEGER,
            DROP COLUMN IF EXISTS lease,
            DROP COLUMN IF EXISTS mine_number,
            ADD CONSTRAINT fk_partner_lease FOREIGN KEY (lease_id) REFERENCES coal_mining.leases(id),
            ADD CONSTRAINT fk_partner_mining_site FOREIGN KEY (mining_site_id) REFERENCES coal_mining.mining_sites(id),
            ADD CONSTRAINT fk_partner_created_by FOREIGN KEY (created_by) REFERENCES coal_mining.users(id),
            ADD CONSTRAINT fk_partner_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id);
        `);
        await queryRunner.query(`CREATE INDEX idx_partner_lease ON coal_mining.partners(lease_id);`);
        await queryRunner.query(`CREATE INDEX idx_partner_mining_site ON coal_mining.partners(mining_site_id);`);

        // 15. Update equipment table
        await queryRunner.query(`
            ALTER TABLE coal_mining.equipment 
            ADD COLUMN created_by INTEGER,
            ADD COLUMN modified_by INTEGER,
            ADD CONSTRAINT fk_equipment_created_by FOREIGN KEY (created_by) REFERENCES coal_mining.users(id),
            ADD CONSTRAINT fk_equipment_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id);
        `);

        // 16. Update production table  
        await queryRunner.query(`
            ALTER TABLE coal_mining.production 
            ADD COLUMN created_by INTEGER,
            ADD COLUMN modified_by INTEGER,
            ADD CONSTRAINT fk_production_created_by FOREIGN KEY (created_by) REFERENCES coal_mining.users(id),
            ADD CONSTRAINT fk_production_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id);
        `);

        // 17. Update workers table
        await queryRunner.query(`
            ALTER TABLE coal_mining.workers 
            ADD COLUMN created_by INTEGER,
            ADD COLUMN modified_by INTEGER,
            ADD CONSTRAINT fk_worker_created_by FOREIGN KEY (created_by) REFERENCES coal_mining.users(id),
            ADD CONSTRAINT fk_worker_modified_by FOREIGN KEY (modified_by) REFERENCES coal_mining.users(id);
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Reverse all changes
        await queryRunner.query(`ALTER TABLE coal_mining.workers DROP COLUMN IF EXISTS created_by, DROP COLUMN IF EXISTS modified_by;`);
        await queryRunner.query(`ALTER TABLE coal_mining.production DROP COLUMN IF EXISTS created_by, DROP COLUMN IF EXISTS modified_by;`);
        await queryRunner.query(`ALTER TABLE coal_mining.equipment DROP COLUMN IF EXISTS created_by, DROP COLUMN IF EXISTS modified_by;`);
        await queryRunner.query(`ALTER TABLE coal_mining.partners DROP COLUMN IF EXISTS lease_id, DROP COLUMN IF EXISTS mining_site_id, DROP COLUMN IF EXISTS created_by, DROP COLUMN IF EXISTS modified_by;`);
        await queryRunner.query(`ALTER TABLE coal_mining.income DROP COLUMN IF EXISTS client_id, DROP COLUMN IF EXISTS amount_from_liability, DROP COLUMN IF EXISTS liability_id, DROP COLUMN IF EXISTS modified_by;`);
        await queryRunner.query(`ALTER TABLE coal_mining.expenses DROP COLUMN IF EXISTS expense_type_id, DROP COLUMN IF EXISTS worker_id, DROP COLUMN IF EXISTS client_id, DROP COLUMN IF EXISTS proof, DROP COLUMN IF EXISTS modified_by;`);
        await queryRunner.query(`ALTER TABLE coal_mining.clients DROP COLUMN IF EXISTS client_type_id, DROP COLUMN IF EXISTS modified_by;`);
        await queryRunner.query(`ALTER TABLE coal_mining.mining_sites DROP COLUMN IF EXISTS lease_id, DROP COLUMN IF EXISTS created_by, DROP COLUMN IF EXISTS modified_by;`);
        await queryRunner.query(`DROP TABLE IF EXISTS coal_mining.liabilities;`);
        await queryRunner.query(`DROP TYPE IF EXISTS coal_mining.liability_status;`);
        await queryRunner.query(`DROP TYPE IF EXISTS coal_mining.liability_type;`);
        await queryRunner.query(`DROP TABLE IF EXISTS coal_mining.general_ledger;`);
        await queryRunner.query(`DROP TABLE IF EXISTS coal_mining.expense_types;`);
        await queryRunner.query(`DROP TABLE IF EXISTS coal_mining.account_types;`);
        await queryRunner.query(`DROP TABLE IF EXISTS coal_mining.client_types;`);
        await queryRunner.query(`DROP TABLE IF EXISTS coal_mining.leases;`);
    }

}
