import { MigrationInterface, QueryRunner } from 'typeorm';

export class RenameLaborToWorkers1733846600000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.renameTable('labor', 'workers');
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.renameTable('workers', 'labor');
  }
}
