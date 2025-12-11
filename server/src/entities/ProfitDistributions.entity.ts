import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
} from "typeorm";
import { PartnerPayouts } from "./PartnerPayouts.entity";
import { Users } from "./Users.entity";
import { MiningSites } from "./MiningSites.entity";

@Index("profit_distributions_pkey", ["id"], { unique: true })
@Index("idx_profit_distributions_site_id", ["siteId"], {})
@Entity("profit_distributions", { schema: "coal_mining" })
export class ProfitDistributions {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("integer", { name: "site_id", nullable: true })
  siteId: number | null;

  @Column("date", { name: "period_start" })
  periodStart: string;

  @Column("date", { name: "period_end" })
  periodEnd: string;

  @Column("numeric", { name: "total_revenue", precision: 15, scale: 2 })
  totalRevenue: string;

  @Column("numeric", { name: "total_expenses", precision: 15, scale: 2 })
  totalExpenses: string;

  @Column("numeric", { name: "total_profit", precision: 15, scale: 2 })
  totalProfit: string;

  @Column("timestamp without time zone", {
    name: "approved_at",
    nullable: true,
  })
  approvedAt: Date | null;

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

  @Column("enum", {
    name: "status",
    enum: ["pending", "approved", "rejected"],
    default: () => "'pending'.profit_distributions_status_enum",
  })
  status: "pending" | "approved" | "rejected";

  @OneToMany(
    () => PartnerPayouts,
    (partnerPayouts) => partnerPayouts.distribution
  )
  partnerPayouts: PartnerPayouts[];

  @ManyToOne(() => Users, (users) => users.profitDistributions)
  @JoinColumn([{ name: "approved_by", referencedColumnName: "id" }])
  approvedBy: Users;

  @ManyToOne(() => MiningSites)
  @JoinColumn([{ name: "site_id", referencedColumnName: "id" }])
  miningSite: MiningSites;
}
