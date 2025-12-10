import {
  Column,
  Entity,
  Index,
  OneToMany,
  PrimaryGeneratedColumn,
} from "typeorm";
import { Expenses } from "./Expenses";

@Index("expense_categories_pkey", ["id"], { unique: true })
@Index("expense_categories_name_key", ["name"], { unique: true })
@Entity("expense_categories", { schema: "coal_mining" })
export class ExpenseCategories {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("character varying", { name: "name", unique: true, length: 100 })
  name: string;

  @Column("text", { name: "description", nullable: true })
  description: string | null;

  @Column("boolean", { name: "is_active", default: () => "true" })
  isActive: boolean;

  @Column("timestamp without time zone", {
    name: "created_at",
    default: () => "now()",
  })
  createdAt: Date;

  @OneToMany(() => Expenses, (expenses) => expenses.category)
  expenses: Expenses[];
}
