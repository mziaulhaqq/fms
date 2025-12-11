import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
} from "typeorm";
import { Expenses } from "./Expenses.entity";
import { MiningSites } from "./MiningSites.entity";
import { LaborCostWorkers } from "./LaborCostWorkers.entity";

@Index("idx_labor_cnic", ["cnic"], {})
@Index("labor_pkey", ["id"], { unique: true })
@Index("idx_labor_site", ["siteId"], {})
@Entity("workers", { schema: "coal_mining" })
export class Worker {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("integer", { name: "site_id" })
  siteId: number;

  @Column("character varying", { name: "name", length: 255 })
  name: string;

  @Column("character varying", { name: "phone", nullable: true, length: 20 })
  phone: string | null;

  @Column("character varying", { name: "cnic", length: 20 })
  cnic: string;

  @Column("date", { name: "start_date" })
  startDate: string;

  @Column("date", { name: "end_date", nullable: true })
  endDate: string | null;

  @Column("text", { name: "notes", nullable: true })
  notes: string | null;

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

  @Column("character varying", {
    name: "father_name",
    nullable: true,
    length: 255,
  })
  fatherName: string | null;

  @Column("text", { name: "address", nullable: true })
  address: string | null;

  @Column("character varying", {
    name: "mobile_number",
    nullable: true,
    length: 20,
  })
  mobileNumber: string | null;

  @Column("character varying", {
    name: "emergency_number",
    nullable: true,
    length: 20,
  })
  emergencyNumber: string | null;

  @Column("integer", {
    name: "supervisor_id",
    nullable: true,
  })
  supervisorId: number | null;

  @Column("numeric", {
    name: "daily_wage",
    nullable: true,
    precision: 10,
    scale: 2,
  })
  dailyWage: string | null;

  @Column("date", { name: "onboarding_date", nullable: true })
  onboardingDate: string | null;

  @Column("date", { name: "offboarding_date", nullable: true })
  offboardingDate: string | null;

  @Column("text", { name: "other_detail", nullable: true })
  otherDetail: string | null;

  @Column("enum", {
    name: "status",
    enum: ["active", "inactive"],
    default: () => "'active'.labor_status_enum",
  })
  status: "active" | "inactive";

  @OneToMany(() => Expenses, (expenses) => expenses.worker)
  expenses: Expenses[];

  @ManyToOne(() => MiningSites, (miningSites) => miningSites.workers)
  @JoinColumn([{ name: "site_id", referencedColumnName: "id" }])
  site: MiningSites;

  @OneToMany(
    () => LaborCostWorkers,
    (laborCostWorkers) => laborCostWorkers.worker
  )
  laborCostWorkers: LaborCostWorkers[];

  // Self-referencing relationship: supervisor
  @ManyToOne(() => Worker, (worker) => worker.subordinates, { nullable: true })
  @JoinColumn([{ name: "supervisor_id", referencedColumnName: "id" }])
  supervisor: Worker | null;

  // Self-referencing relationship: subordinates (workers supervised by this worker)
  @OneToMany(() => Worker, (worker) => worker.supervisor)
  subordinates: Worker[];
}
