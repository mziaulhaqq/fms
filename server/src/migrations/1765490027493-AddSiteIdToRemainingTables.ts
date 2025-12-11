import { MigrationInterface, QueryRunner } from "typeorm";

export class AddSiteIdToRemainingTables1765490027493 implements MigrationInterface {

    public async up(queryRunner: QueryRunner): Promise<void> {
        // Add site_id to clients table
        await queryRunner.query(`
            ALTER TABLE coal_mining.clients 
            ADD COLUMN site_id INTEGER;
        `);

        await queryRunner.query(`
            ALTER TABLE coal_mining.clients
            ADD CONSTRAINT fk_clients_site
            FOREIGN KEY (site_id) 
            REFERENCES coal_mining.mining_sites(id)
            ON DELETE CASCADE;
        `);

        await queryRunner.query(`
            CREATE INDEX idx_clients_site_id ON coal_mining.clients(site_id);
        `);

        // Add site_id to partner_payouts table
        await queryRunner.query(`
            ALTER TABLE coal_mining.partner_payouts 
            ADD COLUMN site_id INTEGER;
        `);

        await queryRunner.query(`
            ALTER TABLE coal_mining.partner_payouts
            ADD CONSTRAINT fk_partner_payouts_site
            FOREIGN KEY (site_id) 
            REFERENCES coal_mining.mining_sites(id)
            ON DELETE CASCADE;
        `);

        await queryRunner.query(`
            CREATE INDEX idx_partner_payouts_site_id ON coal_mining.partner_payouts(site_id);
        `);

        // Add site_id to profit_distributions table
        await queryRunner.query(`
            ALTER TABLE coal_mining.profit_distributions 
            ADD COLUMN site_id INTEGER;
        `);

        await queryRunner.query(`
            ALTER TABLE coal_mining.profit_distributions
            ADD CONSTRAINT fk_profit_distributions_site
            FOREIGN KEY (site_id) 
            REFERENCES coal_mining.mining_sites(id)
            ON DELETE CASCADE;
        `);

        await queryRunner.query(`
            CREATE INDEX idx_profit_distributions_site_id ON coal_mining.profit_distributions(site_id);
        `);

        // Add site_id to labor_cost_workers junction table
        await queryRunner.query(`
            ALTER TABLE coal_mining.labor_cost_workers 
            ADD COLUMN site_id INTEGER;
        `);

        await queryRunner.query(`
            ALTER TABLE coal_mining.labor_cost_workers
            ADD CONSTRAINT fk_labor_cost_workers_site
            FOREIGN KEY (site_id) 
            REFERENCES coal_mining.mining_sites(id)
            ON DELETE CASCADE;
        `);

        await queryRunner.query(`
            CREATE INDEX idx_labor_cost_workers_site_id ON coal_mining.labor_cost_workers(site_id);
        `);

        // Update existing records to set site_id from related tables where possible
        // For clients - set to NULL initially, user must update
        
        // For partner_payouts - derive from partner's site
        await queryRunner.query(`
            UPDATE coal_mining.partner_payouts pp
            SET site_id = p.mining_site_id
            FROM coal_mining.partners p
            WHERE pp.partner_id = p.id;
        `);

        // For profit_distributions - leave NULL, user must specify during creation
        // (profit distribution is a summary across potentially multiple sites)

        // For labor_cost_workers - derive from labor_costs table's site
        await queryRunner.query(`
            UPDATE coal_mining.labor_cost_workers lcw
            SET site_id = lc.site_id
            FROM coal_mining.labor_costs lc
            WHERE lcw.labor_cost_id = lc.id;
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Remove site_id from labor_cost_workers
        await queryRunner.query(`
            DROP INDEX IF EXISTS coal_mining.idx_labor_cost_workers_site_id;
        `);
        await queryRunner.query(`
            ALTER TABLE coal_mining.labor_cost_workers 
            DROP CONSTRAINT IF EXISTS fk_labor_cost_workers_site;
        `);
        await queryRunner.query(`
            ALTER TABLE coal_mining.labor_cost_workers 
            DROP COLUMN IF EXISTS site_id;
        `);

        // Remove site_id from profit_distributions
        await queryRunner.query(`
            DROP INDEX IF EXISTS coal_mining.idx_profit_distributions_site_id;
        `);
        await queryRunner.query(`
            ALTER TABLE coal_mining.profit_distributions 
            DROP CONSTRAINT IF EXISTS fk_profit_distributions_site;
        `);
        await queryRunner.query(`
            ALTER TABLE coal_mining.profit_distributions 
            DROP COLUMN IF EXISTS site_id;
        `);

        // Remove site_id from partner_payouts
        await queryRunner.query(`
            DROP INDEX IF EXISTS coal_mining.idx_partner_payouts_site_id;
        `);
        await queryRunner.query(`
            ALTER TABLE coal_mining.partner_payouts 
            DROP CONSTRAINT IF EXISTS fk_partner_payouts_site;
        `);
        await queryRunner.query(`
            ALTER TABLE coal_mining.partner_payouts 
            DROP COLUMN IF EXISTS site_id;
        `);

        // Remove site_id from clients
        await queryRunner.query(`
            DROP INDEX IF EXISTS coal_mining.idx_clients_site_id;
        `);
        await queryRunner.query(`
            ALTER TABLE coal_mining.clients 
            DROP CONSTRAINT IF EXISTS fk_clients_site;
        `);
        await queryRunner.query(`
            ALTER TABLE coal_mining.clients 
            DROP COLUMN IF EXISTS site_id;
        `);
    }

}
