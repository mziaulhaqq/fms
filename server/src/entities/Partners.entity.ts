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
import { PartnerPayouts } from "./PartnerPayouts.entity";
import { MiningSites } from "./MiningSites.entity";

@Index("idx_partner_cnic", ["cnic"], {})
@Index("UQ_7316fee3f67b04fe07e14908ee3", ["cnic"], { unique: true })
@Index("partners_pkey", ["id"], { unique: true })
@Index("idx_partner_lease", ["leaseId"], {})
@Index("idx_partner_mining_site", ["miningSiteId"], {})
@Entity("partners", { schema: "coal_mining" })
export class Partners extends AuditEntity {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("integer", { name: "lease_id", nullable: true })
  leaseId: number | null;

  @Column("integer", { name: "mining_site_id", nullable: true })
  miningSiteId: number | null;

  @Column("character varying", { name: "name", length: 255 })
  name: string;

  @Column("character varying", { name: "cnic", unique: true, length: 20 })
  cnic: string;

  @Column("character varying", { name: "email", nullable: true, length: 255 })
  email: string | null;

  @Column("character varying", { name: "phone", nullable: true, length: 20 })
  phone: string | null;

  @Column("numeric", {
    name: "share_percentage",
    nullable: true,
    precision: 5,
    scale: 2,
  })
  sharePercentage: string | null;

  @Column("text", { name: "address", nullable: true })
  address: string | null;

  @Column("boolean", { name: "is_active", default: () => "true" })
  isActive: boolean;

  @ManyToOne(() => Lease, (lease) => lease.partners)
  @JoinColumn([{ name: "lease_id", referencedColumnName: "id" }])
  lease: Lease;

  @ManyToOne(() => MiningSites, (miningSites) => miningSites.partners)
  @JoinColumn([{ name: "mining_site_id", referencedColumnName: "id" }])
  miningSite: MiningSites;

  @OneToMany(() => Expenses, (expenses) => expenses.partner)
  expenses: Expenses[];

  @OneToMany(() => PartnerPayouts, (partnerPayouts) => partnerPayouts.partner)
  partnerPayouts: PartnerPayouts[];
}
