import { MigrationInterface, QueryRunner } from "typeorm";

export class AddPayableReceivableToPayments1702400000000 implements MigrationInterface {
    name = 'AddPayableReceivableToPayments1702400000000'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`
            ALTER TABLE "coal_mining"."payments" 
            ADD COLUMN "payable_id" integer NULL,
            ADD COLUMN "receivable_id" integer NULL
        `);

        await queryRunner.query(`
            ALTER TABLE "coal_mining"."payments" 
            ADD CONSTRAINT "fk_payment_payable" 
            FOREIGN KEY ("payable_id") 
            REFERENCES "coal_mining"."payables"("id") 
            ON DELETE SET NULL
        `);

        await queryRunner.query(`
            ALTER TABLE "coal_mining"."payments" 
            ADD CONSTRAINT "fk_payment_receivable" 
            FOREIGN KEY ("receivable_id") 
            REFERENCES "coal_mining"."receivables"("id") 
            ON DELETE SET NULL
        `);

        await queryRunner.query(`
            CREATE INDEX "idx_payment_payable" 
            ON "coal_mining"."payments" ("payable_id")
        `);

        await queryRunner.query(`
            CREATE INDEX "idx_payment_receivable" 
            ON "coal_mining"."payments" ("receivable_id")
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP INDEX "coal_mining"."idx_payment_receivable"`);
        await queryRunner.query(`DROP INDEX "coal_mining"."idx_payment_payable"`);
        await queryRunner.query(`ALTER TABLE "coal_mining"."payments" DROP CONSTRAINT "fk_payment_receivable"`);
        await queryRunner.query(`ALTER TABLE "coal_mining"."payments" DROP CONSTRAINT "fk_payment_payable"`);
        await queryRunner.query(`ALTER TABLE "coal_mining"."payments" DROP COLUMN "receivable_id"`);
        await queryRunner.query(`ALTER TABLE "coal_mining"."payments" DROP COLUMN "payable_id"`);
    }
}
