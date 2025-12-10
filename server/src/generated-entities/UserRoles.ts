import {
  Column,
  Entity,
  Index,
  OneToMany,
  PrimaryGeneratedColumn,
} from "typeorm";
import { UserAssignedRoles } from "./UserAssignedRoles";

@Index("user_roles_pkey", ["id"], { unique: true })
@Index("user_roles_name_key", ["name"], { unique: true })
@Entity("user_roles", { schema: "coal_mining" })
export class UserRoles {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("character varying", { name: "name", unique: true, length: 50 })
  name: string;

  @Column("text", { name: "description", nullable: true })
  description: string | null;

  @Column("jsonb", { name: "permissions", nullable: true, default: [] })
  permissions: object | null;

  @Column("boolean", {
    name: "is_active",
    nullable: true,
    default: () => "true",
  })
  isActive: boolean | null;

  @Column("timestamp without time zone", {
    name: "created_at",
    nullable: true,
    default: () => "CURRENT_TIMESTAMP",
  })
  createdAt: Date | null;

  @Column("timestamp without time zone", {
    name: "updated_at",
    nullable: true,
    default: () => "CURRENT_TIMESTAMP",
  })
  updatedAt: Date | null;

  @OneToMany(
    () => UserAssignedRoles,
    (userAssignedRoles) => userAssignedRoles.role
  )
  userAssignedRoles: UserAssignedRoles[];
}
