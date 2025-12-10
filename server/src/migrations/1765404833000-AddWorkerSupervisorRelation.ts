import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddWorkerSupervisorRelation1765404833000 implements MigrationInterface {
  name = 'AddWorkerSupervisorRelation1765404833000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Step 1: Add new supervisor_id column (nullable initially to allow data migration)
    await queryRunner.query(`
      ALTER TABLE "coal_mining"."workers" 
      ADD COLUMN "supervisor_id" integer NULL
    `);

    // Step 2: Migrate existing supervised_by text data if needed
    // This query attempts to find workers by name in supervised_by field
    // You may need to adjust or skip this if the data doesn't match
    await queryRunner.query(`
      UPDATE "coal_mining"."workers" w1
      SET supervisor_id = w2.id
      FROM "coal_mining"."workers" w2
      WHERE w1.supervised_by IS NOT NULL 
        AND w1.supervised_by != ''
        AND w2.name = w1.supervised_by
    `);

    // Step 3: Drop the old supervised_by text column
    await queryRunner.query(`
      ALTER TABLE "coal_mining"."workers" 
      DROP COLUMN "supervised_by"
    `);

    // Step 4: Add foreign key constraint
    await queryRunner.query(`
      ALTER TABLE "coal_mining"."workers" 
      ADD CONSTRAINT "FK_workers_supervisor" 
      FOREIGN KEY ("supervisor_id") 
      REFERENCES "coal_mining"."workers"("id") 
      ON DELETE SET NULL 
      ON UPDATE CASCADE
    `);

    // Step 5: Add index for performance
    await queryRunner.query(`
      CREATE INDEX "IDX_workers_supervisor_id" 
      ON "coal_mining"."workers" ("supervisor_id")
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Reverse the migration
    
    // Step 1: Drop index
    await queryRunner.query(`
      DROP INDEX "coal_mining"."IDX_workers_supervisor_id"
    `);

    // Step 2: Drop foreign key constraint
    await queryRunner.query(`
      ALTER TABLE "coal_mining"."workers" 
      DROP CONSTRAINT "FK_workers_supervisor"
    `);

    // Step 3: Add back the supervised_by text column
    await queryRunner.query(`
      ALTER TABLE "coal_mining"."workers" 
      ADD COLUMN "supervised_by" character varying(255) NULL
    `);

    // Step 4: Migrate supervisor_id back to names (if possible)
    await queryRunner.query(`
      UPDATE "coal_mining"."workers" w1
      SET supervised_by = w2.name
      FROM "coal_mining"."workers" w2
      WHERE w1.supervisor_id = w2.id
    `);

    // Step 5: Drop supervisor_id column
    await queryRunner.query(`
      ALTER TABLE "coal_mining"."workers" 
      DROP COLUMN "supervisor_id"
    `);
  }
}
