import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
} from "typeorm";
import { Users } from "./Users";
import { Income } from "./Income";

@Index("idx_client_business_name", ["businessName"], {})
@Entity("clients", { schema: "coal_mining" })
export class Clients {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("character varying", { name: "business_name", length: 255 })
  businessName: string;

  @Column("character varying", { name: "owner_name", length: 255 })
  ownerName: string;

  @Column("text", { name: "address", nullable: true })
  address: string | null;

  @Column("character varying", {
    name: "owner_contact",
    nullable: true,
    length: 20,
  })
  ownerContact: string | null;

  @Column("character varying", {
    name: "munshi_name",
    nullable: true,
    length: 255,
  })
  munshiName: string | null;

  @Column("character varying", {
    name: "munshi_contact",
    nullable: true,
    length: 20,
  })
  munshiContact: string | null;

  @Column("text", { name: "description", nullable: true })
  description: string | null;

  @Column("date", { name: "onboarding_date", nullable: true })
  onboardingDate: string | null;

  @Column("boolean", { name: "is_active", default: () => "true" })
  isActive: boolean;

  @Column("text", {
    name: "document_files",
    array: true,
    default: () => "'{}'[]",
  })
  documentFiles: string[];

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

  @ManyToOne(() => Users, (users) => users.clients)
  @JoinColumn([{ name: "coal_agent_id", referencedColumnName: "id" }])
  coalAgent: Users;

  @ManyToOne(() => Users, (users) => users.clients2)
  @JoinColumn([{ name: "created_by", referencedColumnName: "id" }])
  createdBy: Users;

  @OneToMany(() => Income, (income) => income.client)
  incomes: Income[];
}
