import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { Users } from "./Users.entity";
import { UserRoles } from "./UserRoles.entity";

@Index("user_assigned_roles_pkey", ["id"], { unique: true })
@Index("idx_user_assigned_roles_role_id", ["roleId"], {})
@Index("user_assigned_roles_user_id_role_id_key", ["roleId", "userId"], {
  unique: true,
})
@Index("idx_user_assigned_roles_status", ["status"], {})
@Index("idx_user_assigned_roles_user_id", ["userId"], {})
@Entity("user_assigned_roles", { schema: "coal_mining" })
export class UserAssignedRoles {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("integer", { name: "user_id", unique: true })
  userId: number;

  @Column("integer", { name: "role_id", unique: true })
  roleId: number;

  @Column("timestamp without time zone", {
    name: "assigned_at",
    nullable: true,
    default: () => "CURRENT_TIMESTAMP",
  })
  assignedAt: Date | null;

  @Column("character varying", {
    name: "status",
    nullable: true,
    length: 50,
    default: () => "'active'",
  })
  status: string | null;

  @Column("timestamp without time zone", {
    name: "updated_at",
    nullable: true,
    default: () => "CURRENT_TIMESTAMP",
  })
  updatedAt: Date | null;

  @Column("text", { name: "updated_comment", nullable: true })
  updatedComment: string | null;

  @ManyToOne(() => Users, (users) => users.userAssignedRoles, {
    onDelete: "SET NULL",
  })
  @JoinColumn([{ name: "assigned_by", referencedColumnName: "id" }])
  assignedBy: Users;

  @ManyToOne(() => UserRoles, (userRoles) => userRoles.userAssignedRoles, {
    onDelete: "CASCADE",
  })
  @JoinColumn([{ name: "role_id", referencedColumnName: "id" }])
  role: UserRoles;

  @ManyToOne(() => Users, (users) => users.userAssignedRoles2, {
    onDelete: "CASCADE",
  })
  @JoinColumn([{ name: "user_id", referencedColumnName: "id" }])
  user: Users;
}
