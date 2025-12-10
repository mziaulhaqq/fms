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
import { PartnerPayouts } from "./PartnerPayouts.entity";
import { MiningSites } from "./MiningSites.entity";

@Index("idx_partner_cnic", ["cnic"], {})
@Index("UQ_7316fee3f67b04fe07e14908ee3", ["cnic"], { unique: true })
@Index("partners_pkey", ["id"], { unique: true })
@Entity("partners", { schema: "coal_mining" })
export class Partners {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("character varying", { name: "name", length: 255 })
  name: string;

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

  @Column("character varying", { name: "cnic", unique: true, length: 20 })
  cnic: string;

  @Column("text", { name: "address", nullable: true })
  address: string | null;

  @Column("character varying", { name: "lease", nullable: true, length: 255 })
  lease: string | null;

  @OneToMany(() => Expenses, (expenses) => expenses.partner)
  expenses: Expenses[];

  @OneToMany(() => PartnerPayouts, (partnerPayouts) => partnerPayouts.partner)
  partnerPayouts: PartnerPayouts[];

  @ManyToOne(() => MiningSites, (miningSites) => miningSites.partners)
  @JoinColumn([{ name: "mine_number", referencedColumnName: "id" }])
  mineNumber: MiningSites;
}
