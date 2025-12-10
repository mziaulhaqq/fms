import { MigrationInterface, QueryRunner, Table } from 'typeorm';

export class CreateEquipmentTable1733846400000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(
      new Table({
        name: 'equipment',
        schema: 'coal_mining',
        columns: [
          {
            name: 'id',
            type: 'serial',
            isPrimary: true,
          },
          {
            name: 'name',
            type: 'varchar',
            length: '255',
            isNullable: false,
          },
          {
            name: 'type',
            type: 'varchar',
            length: '100',
            isNullable: true,
          },
          {
            name: 'model',
            type: 'varchar',
            length: '255',
            isNullable: true,
          },
          {
            name: 'serial_number',
            type: 'varchar',
            length: '255',
            isNullable: true,
          },
          {
            name: 'purchase_date',
            type: 'date',
            isNullable: true,
          },
          {
            name: 'purchase_price',
            type: 'decimal',
            precision: 15,
            scale: 2,
            isNullable: true,
          },
          {
            name: 'status',
            type: 'varchar',
            length: '50',
            isNullable: true,
            default: "'active'",
          },
          {
            name: 'site_id',
            type: 'integer',
            isNullable: true,
          },
          {
            name: 'notes',
            type: 'text',
            isNullable: true,
          },
          {
            name: 'created_at',
            type: 'timestamp',
            default: 'CURRENT_TIMESTAMP',
          },
          {
            name: 'updated_at',
            type: 'timestamp',
            default: 'CURRENT_TIMESTAMP',
          },
        ],
        foreignKeys: [
          {
            columnNames: ['site_id'],
            referencedTableName: 'mining_sites',
            referencedSchema: 'coal_mining',
            referencedColumnNames: ['id'],
            onDelete: 'SET NULL',
          },
        ],
      }),
      true,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('coal_mining.equipment', true);
  }
}
