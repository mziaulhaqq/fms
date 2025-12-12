import { MigrationInterface, QueryRunner, Table, TableForeignKey } from "typeorm";

export class CreateReceivablesAndPaymentsTables1765572250950 implements MigrationInterface {

    public async up(queryRunner: QueryRunner): Promise<void> {
        // Create Receivables table
        await queryRunner.createTable(
            new Table({
                name: "coal_mining.receivables",
                columns: [
                    {
                        name: "id",
                        type: "serial",
                        isPrimary: true,
                    },
                    {
                        name: "client_id",
                        type: "integer",
                        isNullable: false,
                    },
                    {
                        name: "mining_site_id",
                        type: "integer",
                        isNullable: false,
                    },
                    {
                        name: "date",
                        type: "date",
                        isNullable: false,
                    },
                    {
                        name: "description",
                        type: "text",
                        isNullable: true,
                    },
                    {
                        name: "total_amount",
                        type: "numeric",
                        precision: 12,
                        scale: 2,
                        isNullable: false,
                    },
                    {
                        name: "remaining_balance",
                        type: "numeric",
                        precision: 12,
                        scale: 2,
                        default: 0,
                        isNullable: false,
                    },
                    {
                        name: "status",
                        type: "varchar",
                        length: "50",
                        default: "'Active'",
                        isNullable: false,
                    },
                    {
                        name: "created_at",
                        type: "timestamp",
                        default: "CURRENT_TIMESTAMP",
                    },
                    {
                        name: "updated_at",
                        type: "timestamp",
                        default: "CURRENT_TIMESTAMP",
                    },
                    {
                        name: "created_by",
                        type: "integer",
                        isNullable: true,
                    },
                    {
                        name: "modified_by",
                        type: "integer",
                        isNullable: true,
                    },
                ],
            }),
            true
        );

        // Create Payments table
        await queryRunner.createTable(
            new Table({
                name: "coal_mining.payments",
                columns: [
                    {
                        name: "id",
                        type: "serial",
                        isPrimary: true,
                    },
                    {
                        name: "client_id",
                        type: "integer",
                        isNullable: false,
                    },
                    {
                        name: "mining_site_id",
                        type: "integer",
                        isNullable: false,
                    },
                    {
                        name: "payment_type",
                        type: "varchar",
                        length: "50",
                        isNullable: false,
                    },
                    {
                        name: "amount",
                        type: "numeric",
                        precision: 12,
                        scale: 2,
                        isNullable: false,
                    },
                    {
                        name: "payment_date",
                        type: "date",
                        isNullable: false,
                    },
                    {
                        name: "payment_method",
                        type: "varchar",
                        length: "50",
                        default: "'cash'",
                        isNullable: false,
                    },
                    {
                        name: "proof",
                        type: "text",
                        isArray: true,
                        default: "'{}'",
                        isNullable: true,
                    },
                    {
                        name: "received_by",
                        type: "integer",
                        isNullable: true,
                    },
                    {
                        name: "notes",
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

        // Foreign keys and indexes would go here but keeping it simple for now
        await queryRunner.query(`
            CREATE INDEX idx_receivable_client ON coal_mining.receivables(client_id);
            CREATE INDEX idx_receivable_mining_site ON coal_mining.receivables(mining_site_id);
            CREATE INDEX idx_payment_client ON coal_mining.payments(client_id);
            CREATE INDEX idx_payment_mining_site ON coal_mining.payments(mining_site_id);
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.dropTable("coal_mining.payments");
        await queryRunner.dropTable("coal_mining.receivables");
    }

}
