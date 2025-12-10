import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { ExpenseCategories } from "./ExpenseCategories.entity";
import { Users } from "./Users.entity";
import { Worker } from "./Worker.entity";
import { Partners } from "./Partners.entity";
import { MiningSites } from "./MiningSites.entity";

@Index("idx_expense_category", ["categoryId"], {})
@Index("idx_expense_date", ["expenseDate"], {})
@Index("expenses_pkey", ["id"], { unique: true })
@Index("idx_expense_site", ["siteId"], {})
@Entity("expenses", { schema: "coal_mining" })
export class Expenses {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("integer", { name: "site_id" })
  siteId: number;

  @Column("integer", { name: "category_id", nullable: true })
  categoryId: number | null;

  @Column("date", { name: "expense_date" })
  expenseDate: string;

  @Column("numeric", { name: "amount", precision: 12, scale: 2 })
  amount: string;

  @Column("text", { name: "notes", nullable: true })
  notes: string | null;

  @Column("text", {
    name: "evidence_photos",
    array: true,
    default: () => "'{}'[]",
  })
  evidencePhotos: string[];

  @Column("integer", { name: "labor_cost_id", nullable: true })
  laborCostId: number | null;

  @Column("timestamp without time zone", {
    name: "created_at",
    default: () => "now()",
  })
  createdAt: Date;

  @Column("timestamp without time zone", {
    name: "updated_at",
    default: () => "now()",
  })
  updatedAt: Date;

  @Column("enum", {
    name: "account_type",
    nullable: true,
    enum: ["employee", "vendor", "partner", "other"],
  })
  accountType: "employee" | "vendor" | "partner" | "other" | null;

  @Column("enum", {
    name: "payee_type",
    nullable: true,
    enum: ["labor", "partner"],
  })
  payeeType: "labor" | "partner" | null;

  @Column("date", { name: "payment_date", nullable: true })
  paymentDate: string | null;

  @Column("text", { name: "description", nullable: true })
  description: string | null;

  @Column("text", {
    name: "payment_proof",
    array: true,
    default: () => "'{}'[]",
  })
  paymentProof: string[];

  @ManyToOne(
    () => ExpenseCategories,
    (expenseCategories) => expenseCategories.expenses
  )
  @JoinColumn([{ name: "category_id", referencedColumnName: "id" }])
  category: ExpenseCategories;

  @ManyToOne(() => Users, (users) => users.expenses)
  @JoinColumn([{ name: "created_by", referencedColumnName: "id" }])
  createdBy: Users;

  @ManyToOne(() => Worker, (worker) => worker.expenses)
  @JoinColumn([{ name: "labor_id", referencedColumnName: "id" }])
  labor: Worker;

  @ManyToOne(() => Partners, (partners) => partners.expenses)
  @JoinColumn([{ name: "partner_id", referencedColumnName: "id" }])
  partner: Partners;

  @ManyToOne(() => MiningSites, (miningSites) => miningSites.expenses)
  @JoinColumn([{ name: "site_id", referencedColumnName: "id" }])
  site: MiningSites;
}
