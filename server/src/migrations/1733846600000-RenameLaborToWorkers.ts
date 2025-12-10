import { MigrationInterface, QueryRunner } from 'typeorm';

export class RenameLaborToWorkers1733846600000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.renameTable('coal_mining.labor', 'coal_mining.workers');
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.renameTable('coal_mining.workers', 'coal_mining.labor');
  }
}
