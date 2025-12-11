import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { ProfitDistributions } from "./ProfitDistributions.entity";
import { Partners } from "./Partners.entity";
import { MiningSites } from "./MiningSites.entity";

@Index("idx_payout_distribution", ["distributionId"], {})
@Index("partner_payouts_pkey", ["id"], { unique: true })
@Index("idx_payout_partner", ["partnerId"], {})
@Index("idx_partner_payouts_site_id", ["siteId"], {})
@Entity("partner_payouts", { schema: "coal_mining" })
export class PartnerPayouts {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("integer", { name: "site_id", nullable: true })
  siteId: number | null;

  @Column("integer", { name: "distribution_id" })
  distributionId: number;

  @Column("integer", { name: "partner_id" })
  partnerId: number;

  @Column("numeric", { name: "share_percentage", precision: 5, scale: 2 })
  sharePercentage: string;

  @Column("numeric", { name: "payout_amount", precision: 15, scale: 2 })
  payoutAmount: string;

  @Column("timestamp without time zone", {
    name: "created_at",
    default: () => "now()",
  })
  createdAt: Date;

  @ManyToOne(
    () => ProfitDistributions,
    (profitDistributions) => profitDistributions.partnerPayouts
  )
  @JoinColumn([{ name: "distribution_id", referencedColumnName: "id" }])
  distribution: ProfitDistributions;

  @ManyToOne(() => Partners, (partners) => partners.partnerPayouts)
  @JoinColumn([{ name: "partner_id", referencedColumnName: "id" }])
  partner: Partners;

  @ManyToOne(() => MiningSites)
  @JoinColumn([{ name: "site_id", referencedColumnName: "id" }])
  miningSite: MiningSites;
}
