import { MigrationInterface, QueryRunner, TableColumn, TableForeignKey } from "typeorm";

export class AddReceivableIdToIncome1734107400000 implements MigrationInterface {
    public async up(queryRunner: QueryRunner): Promise<void> {
        // Add receivable_id column to income table
        await queryRunner.addColumn('coal_mining.income', new TableColumn({
            name: 'receivable_id',
            type: 'integer',
            isNullable: true,
        }));

        // Add foreign key constraint
        await queryRunner.createForeignKey('coal_mining.income', new TableForeignKey({
            columnNames: ['receivable_id'],
            referencedTableName: 'coal_mining.receivables',
            referencedColumnNames: ['id'],
            onDelete: 'SET NULL',
        }));
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Drop foreign key constraint
        const table = await queryRunner.getTable('coal_mining.income');
        const foreignKey = table?.foreignKeys.find(fk => fk.columnNames.indexOf('receivable_id') !== -1);
        if (foreignKey) {
            await queryRunner.dropForeignKey('coal_mining.income', foreignKey);
        }

        // Drop receivable_id column
        await queryRunner.dropColumn('coal_mining.income', 'receivable_id');
    }
}
