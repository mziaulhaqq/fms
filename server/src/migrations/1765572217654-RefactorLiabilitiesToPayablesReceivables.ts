import { MigrationInterface, QueryRunner } from "typeorm";

export class RefactorLiabilitiesToPayablesReceivables1765572217654 implements MigrationInterface {

    public async up(queryRunner: QueryRunner): Promise<void> {
        // Drop the liability_transactions table first (due to foreign key)
        await queryRunner.query(`DROP TABLE IF EXISTS coal_mining.liability_transactions`);
        
        // First, change the column type from enum to varchar temporarily
        await queryRunner.query(`
            ALTER TABLE coal_mining.liabilities 
            ALTER COLUMN type TYPE varchar(50)
        `);
        
        // Update 'Advanced Payment' to 'Advance Payment' if any exist
        await queryRunner.query(`
            UPDATE coal_mining.liabilities 
            SET type = 'Advance Payment' 
            WHERE type = 'Advanced Payment'
        `);
        
        // Delete any 'Loan' type records or convert them
        await queryRunner.query(`
            DELETE FROM coal_mining.liabilities 
            WHERE type = 'Loan'
        `);
        
        // Rename liabilities table to payables
        await queryRunner.query(`ALTER TABLE coal_mining.liabilities RENAME TO payables`);
        
        // Drop the old enum type
        await queryRunner.query(`DROP TYPE IF EXISTS coal_mining.liability_type CASCADE`);
        
        // Rename indexes
        await queryRunner.query(`ALTER INDEX IF EXISTS coal_mining.liabilities_pkey RENAME TO payables_pkey`);
        await queryRunner.query(`ALTER INDEX IF EXISTS coal_mining.idx_liability_client RENAME TO idx_payable_client`);
        await queryRunner.query(`ALTER INDEX IF EXISTS coal_mining.idx_liability_mining_site RENAME TO idx_payable_mining_site`);
        await queryRunner.query(`ALTER INDEX IF EXISTS coal_mining.idx_liability_date RENAME TO idx_payable_date`);
        
        // Update status column - change from enum to varchar first
        await queryRunner.query(`
            ALTER TABLE coal_mining.payables 
            ALTER COLUMN status TYPE varchar(50)
        `);
        
        // Drop old status enum
        await queryRunner.query(`DROP TYPE IF EXISTS coal_mining.liability_status_enum CASCADE`);
        
        // Update existing status values
        await queryRunner.query(`
            UPDATE coal_mining.payables 
            SET status = CASE 
                WHEN status = 'Partially Settled' THEN 'Partially Used'
                WHEN status = 'Fully Settled' THEN 'Fully Used'
                ELSE status
            END
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Revert status values
        await queryRunner.query(`
            UPDATE coal_mining.payables 
            SET status = CASE 
                WHEN status = 'Partially Used' THEN 'Partially Settled'
                WHEN status = 'Fully Used' THEN 'Fully Settled'
                ELSE status
            END
        `);
        
        // Rename indexes back
        await queryRunner.query(`ALTER INDEX IF EXISTS coal_mining.idx_payable_date RENAME TO idx_liability_date`);
        await queryRunner.query(`ALTER INDEX IF EXISTS coal_mining.idx_payable_mining_site RENAME TO idx_liability_mining_site`);
        await queryRunner.query(`ALTER INDEX IF EXISTS coal_mining.idx_payable_client RENAME TO idx_liability_client`);
        await queryRunner.query(`ALTER INDEX IF EXISTS coal_mining.payables_pkey RENAME TO liabilities_pkey`);
        
        // Rename table back
        await queryRunner.query(`ALTER TABLE coal_mining.payables RENAME TO liabilities`);
    }

}
