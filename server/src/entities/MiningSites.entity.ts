import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
} from "typeorm";
import { AuditEntity } from "./AuditEntity";
import { Lease } from "./Lease.entity";
import { Expenses } from "./Expenses.entity";
import { Income } from "./Income.entity";
import { Worker } from "./Worker.entity";
import { LaborCosts } from "./LaborCosts.entity";
import { Partners } from "./Partners.entity";
import { SiteSupervisors } from "./SiteSupervisors.entity";
import { GeneralLedger } from "./GeneralLedger.entity";
import { Payable } from "./Payable.entity";
import { Receivable } from "./Receivable.entity";
import { Payment } from "./Payment.entity";

@Index("mining_sites_pkey", ["id"], { unique: true })
@Index("idx_mining_site_lease", ["leaseId"], {})
@Entity("mining_sites", { schema: "coal_mining" })
export class MiningSites extends AuditEntity {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("integer", { name: "lease_id", nullable: true })
  leaseId: number | null;

  @Column("character varying", { name: "name", length: 255 })
  name: string;

  @Column("text", { name: "location", nullable: true })
  location: string | null;

  @Column("text", { name: "description", nullable: true })
  description: string | null;

  @Column("boolean", { name: "is_active", default: () => "true" })
  isActive: boolean;

  @ManyToOne(() => Lease, (lease) => lease.miningSites)
  @JoinColumn([{ name: "lease_id", referencedColumnName: "id" }])
  lease: Lease;

  @OneToMany(() => Expenses, (expenses) => expenses.site)
  expenses: Expenses[];

  @OneToMany(() => Income, (income) => income.site)
  incomes: Income[];

  @OneToMany(() => Worker, (worker) => worker.site)
  workers: Worker[];

  @OneToMany(() => LaborCosts, (laborCosts) => laborCosts.site)
  laborCosts: LaborCosts[];

  @OneToMany(() => Partners, (partners) => partners.miningSite)
  partners: Partners[];

  @OneToMany(() => SiteSupervisors, (siteSupervisors) => siteSupervisors.site)
  siteSupervisors: SiteSupervisors[];

  @OneToMany(() => GeneralLedger, (generalLedger) => generalLedger.miningSite)
  generalLedgers: GeneralLedger[];

  @OneToMany(() => Payable, (payable) => payable.miningSite)
  payables: Payable[];

  @OneToMany(() => Receivable, (receivable) => receivable.miningSite)
  receivables: Receivable[];

  @OneToMany(() => Payment, (payment) => payment.miningSite)
  payments: Payment[];
}
