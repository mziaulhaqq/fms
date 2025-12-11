import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
} from "typeorm";
import { LaborCostWorkers } from "./LaborCostWorkers.entity";
import { Users } from "./Users.entity";
import { MiningSites } from "./MiningSites.entity";

@Index("labor_costs_pkey", ["id"], { unique: true })
@Index("idx_labor_cost_site", ["siteId"], {})
@Index("idx_labor_cost_date", ["workDate"], {})
@Entity("labor_costs", { schema: "coal_mining" })
export class LaborCosts {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("integer", { name: "site_id" })
  siteId: number;

  @Column("date", { name: "work_date" })
  workDate: string;

  @Column("numeric", { name: "quantity_tons", precision: 10, scale: 2 })
  quantityTons: string;

  @Column("numeric", { name: "rate_per_ton", precision: 10, scale: 2 })
  ratePerTon: string;

  @Column("numeric", { name: "total_cost", precision: 12, scale: 2 })
  totalCost: string;

  @Column("text", { name: "notes", nullable: true })
  notes: string | null;

  @Column("text", {
    name: "evidence_photos",
    array: true,
    default: () => "'{}'[]",
  })
  evidencePhotos: string[];

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

  @OneToMany(
    () => LaborCostWorkers,
    (laborCostWorkers) => laborCostWorkers.laborCost
  )
  laborCostWorkers: LaborCostWorkers[];

  @ManyToOne(() => Users)
  @JoinColumn([{ name: "created_by", referencedColumnName: "id" }])
  createdBy: Users;

  @ManyToOne(() => MiningSites, (miningSites) => miningSites.laborCosts)
  @JoinColumn([{ name: "site_id", referencedColumnName: "id" }])
  site: MiningSites;
}
