import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { LaborCosts } from "./LaborCosts";
import { Workers } from "./Workers";

@Index("labor_cost_workers_pkey", ["id"], { unique: true })
@Index("UQ_5aba3b98daab87c536e9c7d58dc", ["laborCostId", "laborId"], {
  unique: true,
})
@Entity("labor_cost_workers", { schema: "coal_mining" })
export class LaborCostWorkers {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("integer", { name: "labor_cost_id", unique: true })
  laborCostId: number;

  @Column("integer", { name: "labor_id", unique: true })
  laborId: number;

  @ManyToOne(() => LaborCosts, (laborCosts) => laborCosts.laborCostWorkers)
  @JoinColumn([{ name: "labor_cost_id", referencedColumnName: "id" }])
  laborCost: LaborCosts;

  @ManyToOne(() => Workers, (workers) => workers.laborCostWorkers)
  @JoinColumn([{ name: "labor_id", referencedColumnName: "id" }])
  labor: Workers;
}
