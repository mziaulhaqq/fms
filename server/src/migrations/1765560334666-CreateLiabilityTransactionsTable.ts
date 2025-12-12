import { MigrationInterface, QueryRunner, Table, TableForeignKey } from "typeorm";

export class CreateLiabilityTransactionsTable1765560334666 implements MigrationInterface {

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.createTable(
            new Table({
                name: "coal_mining.liability_transactions",
                columns: [
                    {
                        name: "id",
                        type: "serial",
                        isPrimary: true,
                    },
                    {
                        name: "liability_id",
                        type: "integer",
                        isNullable: false,
                    },
                    {
                        name: "income_id",
                        type: "integer",
                        isNullable: true,
                    },
                    {
                        name: "transaction_type",
                        type: "varchar",
                        length: "50",
                        isNullable: false,
                        comment: "Types: initial_payment, deduction, adjustment, reversal",
                    },
                    {
                        name: "amount",
                        type: "numeric",
                        precision: 12,
                        scale: 2,
                        isNullable: false,
                    },
                    {
                        name: "previous_balance",
                        type: "numeric",
                        precision: 12,
                        scale: 2,
                        isNullable: false,
                    },
                    {
                        name: "new_balance",
                        type: "numeric",
                        precision: 12,
                        scale: 2,
                        isNullable: false,
                    },
                    {
                        name: "description",
                        type: "text",
                        isNullable: true,
                    },
                    {
                        name: "created_at",
                        type: "timestamp",
                        default: "CURRENT_TIMESTAMP",
                    },
                    {
                        name: "created_by",
                        type: "integer",
                        isNullable: true,
                    },
                ],
            }),
            true
        );

        // Add foreign key for liability_id
        await queryRunner.createForeignKey(
            "coal_mining.liability_transactions",
            new TableForeignKey({
                columnNames: ["liability_id"],
                referencedColumnNames: ["id"],
                referencedTableName: "coal_mining.liabilities",
                onDelete: "CASCADE",
            })
        );

        // Add foreign key for income_id
        await queryRunner.createForeignKey(
            "coal_mining.liability_transactions",
            new TableForeignKey({
                columnNames: ["income_id"],
                referencedColumnNames: ["id"],
                referencedTableName: "coal_mining.income",
                onDelete: "SET NULL",
            })
        );

        // Add foreign key for created_by
        await queryRunner.createForeignKey(
            "coal_mining.liability_transactions",
            new TableForeignKey({
                columnNames: ["created_by"],
                referencedColumnNames: ["id"],
                referencedTableName: "coal_mining.users",
                onDelete: "SET NULL",
            })
        );

        // Add index for faster queries
        await queryRunner.query(`
            CREATE INDEX idx_liability_transactions_liability ON coal_mining.liability_transactions(liability_id);
            CREATE INDEX idx_liability_transactions_income ON coal_mining.liability_transactions(income_id);
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP INDEX IF EXISTS coal_mining.idx_liability_transactions_income;`);
        await queryRunner.query(`DROP INDEX IF EXISTS coal_mining.idx_liability_transactions_liability;`);
        await queryRunner.dropTable("coal_mining.liability_transactions");
    }

}
