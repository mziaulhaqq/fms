import { MigrationInterface, QueryRunner, TableColumn } from "typeorm";

export class AddAmountCashToIncome1765560398785 implements MigrationInterface {

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.addColumn(
            "coal_mining.income",
            new TableColumn({
                name: "amount_cash",
                type: "numeric",
                precision: 12,
                scale: 2,
                isNullable: true,
                default: 0,
                comment: "Amount paid in cash (not from liability)",
            })
        );
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.dropColumn("coal_mining.income", "amount_cash");
    }

}
