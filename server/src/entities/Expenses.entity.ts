import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { AuditEntity } from "./AuditEntity";
import { ExpenseCategories } from "./ExpenseCategories.entity";
import { ExpenseType } from "./ExpenseType.entity";
import { Users } from "./Users.entity";
import { Worker } from "./Worker.entity";
import { Clients } from "./Clients.entity";
import { Partners } from "./Partners.entity";
import { MiningSites } from "./MiningSites.entity";

@Index("idx_expense_category", ["categoryId"], {})
@Index("idx_expense_date", ["expenseDate"], {})
@Index("expenses_pkey", ["id"], { unique: true })
@Index("idx_expense_site", ["siteId"], {})
@Index("idx_expense_type", ["expenseTypeId"], {})
@Entity("expenses", { schema: "coal_mining" })
export class Expenses extends AuditEntity {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("integer", { name: "site_id" })
  siteId: number;

  @Column("integer", { name: "expense_type_id", nullable: true })
  expenseTypeId: number | null;

  @Column("integer", { name: "category_id", nullable: true })
  categoryId: number | null;

  @Column("integer", { name: "worker_id", nullable: true })
  workerId: number | null;

  @Column("integer", { name: "client_id", nullable: true })
  clientId: number | null;

  @Column("date", { name: "expense_date" })
  expenseDate: string;

  @Column("numeric", { name: "amount", precision: 12, scale: 2 })
  amount: string;

  @Column("text", { name: "notes", nullable: true })
  notes: string | null;

  @Column("text", {
    name: "proof",
    array: true,
    default: () => "'{}'[]",
  })
  proof: string[];

  @Column("integer", { name: "labor_cost_id", nullable: true })
  laborCostId: number | null;

  @Column("date", { name: "payment_date", nullable: true })
  paymentDate: string | null;

  @Column("text", { name: "description", nullable: true })
  description: string | null;

  @ManyToOne(() => ExpenseType, (expenseType) => expenseType.expenses)
  @JoinColumn([{ name: "expense_type_id", referencedColumnName: "id" }])
  expenseType: ExpenseType;

  @ManyToOne(
    () => ExpenseCategories,
    (expenseCategories) => expenseCategories.expenses
  )
  @JoinColumn([{ name: "category_id", referencedColumnName: "id" }])
  category: ExpenseCategories;

  @ManyToOne(() => Worker, (worker) => worker.expenses)
  @JoinColumn([{ name: "worker_id", referencedColumnName: "id" }])
  worker: Worker;

  @ManyToOne(() => Clients, (client) => client.expenses)
  @JoinColumn([{ name: "client_id", referencedColumnName: "id" }])
  client: Clients;

  @ManyToOne(() => Partners, (partners) => partners.expenses)
  @JoinColumn([{ name: "partner_id", referencedColumnName: "id" }])
  partner: Partners;

  @ManyToOne(() => MiningSites, (miningSites) => miningSites.expenses)
  @JoinColumn([{ name: "site_id", referencedColumnName: "id" }])
  site: MiningSites;
}
