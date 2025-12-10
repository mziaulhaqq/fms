import {
  Column,
  Entity,
  Index,
  OneToMany,
  PrimaryGeneratedColumn,
} from "typeorm";
import { Expenses } from "./Expenses.entity";
import { Income } from "./Income.entity";
import { Worker } from "./Worker.entity";
import { LaborCosts } from "./LaborCosts.entity";
import { Partners } from "./Partners.entity";
import { SiteSupervisors } from "./SiteSupervisors.entity";
import { TruckDeliveries } from "./TruckDeliveries.entity";

@Index("mining_sites_pkey", ["id"], { unique: true })
@Entity("mining_sites", { schema: "coal_mining" })
export class MiningSites {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("character varying", { name: "name", length: 255 })
  name: string;

  @Column("text", { name: "location", nullable: true })
  location: string | null;

  @Column("text", { name: "description", nullable: true })
  description: string | null;

  @Column("boolean", { name: "is_active", default: () => "true" })
  isActive: boolean;

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

  @OneToMany(() => Expenses, (expenses) => expenses.site)
  expenses: Expenses[];

  @OneToMany(() => Income, (income) => income.site)
  incomes: Income[];

  @OneToMany(() => Worker, (worker) => worker.site)
  workers: Worker[];

  @OneToMany(() => LaborCosts, (laborCosts) => laborCosts.site)
  laborCosts: LaborCosts[];

  @OneToMany(() => Partners, (partners) => partners.mineNumber)
  partners: Partners[];

  @OneToMany(() => SiteSupervisors, (siteSupervisors) => siteSupervisors.site)
  siteSupervisors: SiteSupervisors[];

  @OneToMany(() => TruckDeliveries, (truckDeliveries) => truckDeliveries.site)
  truckDeliveries: TruckDeliveries[];
}
