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
import { ClientType } from "./ClientType.entity";
import { Users } from "./Users.entity";
import { Income } from "./Income.entity";
import { Liability } from "./Liability.entity";
import { Expenses } from "./Expenses.entity";

@Index("idx_client_business_name", ["businessName"], {})
@Index("idx_client_type", ["clientTypeId"], {})
@Entity("clients", { schema: "coal_mining" })
export class Clients extends AuditEntity {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("integer", { name: "client_type_id", nullable: true })
  clientTypeId: number | null;

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

  @ManyToOne(() => ClientType, (clientType) => clientType.clients)
  @JoinColumn([{ name: "client_type_id", referencedColumnName: "id" }])
  clientType: ClientType;

  @ManyToOne(() => Users, (users) => users.clients)
  @JoinColumn([{ name: "coal_agent_id", referencedColumnName: "id" }])
  coalAgent: Users;

  @OneToMany(() => Income, (income) => income.client)
  incomes: Income[];

  @OneToMany(() => Liability, (liability) => liability.client)
  liabilities: Liability[];

  @OneToMany(() => Expenses, (expense) => expense.client)
  expenses: Expenses[];
}
