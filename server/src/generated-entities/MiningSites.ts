import {
  Column,
  Entity,
  Index,
  OneToMany,
  PrimaryGeneratedColumn,
} from "typeorm";
import { Equipment } from "./Equipment";
import { Expenses } from "./Expenses";
import { Income } from "./Income";
import { LaborCosts } from "./LaborCosts";
import { Partners } from "./Partners";
import { Production } from "./Production";
import { SiteSupervisors } from "./SiteSupervisors";
import { TruckDeliveries } from "./TruckDeliveries";
import { Workers } from "./Workers";

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

  @OneToMany(() => Equipment, (equipment) => equipment.site)
  equipment: Equipment[];

  @OneToMany(() => Expenses, (expenses) => expenses.site)
  expenses: Expenses[];

  @OneToMany(() => Income, (income) => income.site)
  incomes: Income[];

  @OneToMany(() => LaborCosts, (laborCosts) => laborCosts.site)
  laborCosts: LaborCosts[];

  @OneToMany(() => Partners, (partners) => partners.mineNumber)
  partners: Partners[];

  @OneToMany(() => Production, (production) => production.site)
  productions: Production[];

  @OneToMany(() => SiteSupervisors, (siteSupervisors) => siteSupervisors.site)
  siteSupervisors: SiteSupervisors[];

  @OneToMany(() => TruckDeliveries, (truckDeliveries) => truckDeliveries.site)
  truckDeliveries: TruckDeliveries[];

  @OneToMany(() => Workers, (workers) => workers.site)
  workers: Workers[];
}
