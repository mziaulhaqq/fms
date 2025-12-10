import {
  Column,
  Entity,
  Index,
  OneToMany,
  PrimaryGeneratedColumn,
} from "typeorm";
import { Clients } from "./Clients";
import { Expenses } from "./Expenses";
import { Income } from "./Income";
import { LaborCosts } from "./LaborCosts";
import { ProfitDistributions } from "./ProfitDistributions";
import { SiteSupervisors } from "./SiteSupervisors";
import { TruckDeliveries } from "./TruckDeliveries";
import { UserAssignedRoles } from "./UserAssignedRoles";

@Index("users_email_key", ["email"], { unique: true })
@Index("users_pkey", ["id"], { unique: true })
@Index("users_username_key", ["username"], { unique: true })
@Entity("users", { schema: "coal_mining" })
export class Users {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("character varying", { name: "username", unique: true, length: 100 })
  username: string;

  @Column("character varying", { name: "email", unique: true, length: 255 })
  email: string;

  @Column("character varying", { name: "password_hash", length: 255 })
  passwordHash: string;

  @Column("character varying", { name: "full_name", length: 255 })
  fullName: string;

  @Column("character varying", { name: "phone", nullable: true, length: 20 })
  phone: string | null;

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

  @OneToMany(() => Clients, (clients) => clients.coalAgent)
  clients: Clients[];

  @OneToMany(() => Clients, (clients) => clients.createdBy)
  clients2: Clients[];

  @OneToMany(() => Expenses, (expenses) => expenses.createdBy)
  expenses: Expenses[];

  @OneToMany(() => Income, (income) => income.createdBy)
  incomes: Income[];

  @OneToMany(() => LaborCosts, (laborCosts) => laborCosts.createdBy)
  laborCosts: LaborCosts[];

  @OneToMany(
    () => ProfitDistributions,
    (profitDistributions) => profitDistributions.approvedBy
  )
  profitDistributions: ProfitDistributions[];

  @OneToMany(
    () => SiteSupervisors,
    (siteSupervisors) => siteSupervisors.supervisor
  )
  siteSupervisors: SiteSupervisors[];

  @OneToMany(
    () => TruckDeliveries,
    (truckDeliveries) => truckDeliveries.createdBy
  )
  truckDeliveries: TruckDeliveries[];

  @OneToMany(
    () => UserAssignedRoles,
    (userAssignedRoles) => userAssignedRoles.assignedBy
  )
  userAssignedRoles: UserAssignedRoles[];

  @OneToMany(
    () => UserAssignedRoles,
    (userAssignedRoles) => userAssignedRoles.user
  )
  userAssignedRoles2: UserAssignedRoles[];
}
