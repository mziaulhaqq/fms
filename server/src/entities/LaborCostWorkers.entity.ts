import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { LaborCosts } from "./LaborCosts.entity";
import { Worker } from "./Worker.entity";
import { MiningSites } from "./MiningSites.entity";

@Index("labor_cost_workers_pkey", ["id"], { unique: true })
@Index("UQ_5aba3b98daab87c536e9c7d58dc", ["laborCostId", "laborId"], {
  unique: true,
})
@Index("idx_labor_cost_workers_site_id", ["siteId"], {})
@Entity("labor_cost_workers", { schema: "coal_mining" })
export class LaborCostWorkers {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("integer", { name: "site_id", nullable: true })
  siteId: number | null;

  @Column("integer", { name: "labor_cost_id", unique: true })
  laborCostId: number;

  @Column("integer", { name: "labor_id", unique: true })
  laborId: number;

  @ManyToOne(() => LaborCosts, (laborCosts) => laborCosts.laborCostWorkers)
  @JoinColumn([{ name: "labor_cost_id", referencedColumnName: "id" }])
  laborCost: LaborCosts;

  @ManyToOne(() => Worker, (worker) => worker.laborCostWorkers)
  @JoinColumn([{ name: "labor_id", referencedColumnName: "id" }])
  worker: Worker;

  @ManyToOne(() => MiningSites)
  @JoinColumn([{ name: "site_id", referencedColumnName: "id" }])
  miningSite: MiningSites;
}
