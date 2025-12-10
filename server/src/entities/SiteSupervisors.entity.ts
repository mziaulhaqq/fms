import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { MiningSites } from "./MiningSites.entity";
import { Users } from "./Users.entity";

@Index("site_supervisors_pkey", ["id"], { unique: true })
@Index("UQ_fa5b6365e8d996ec487500cf818", ["siteId", "supervisorId"], {
  unique: true,
})
@Entity("site_supervisors", { schema: "coal_mining" })
export class SiteSupervisors {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("integer", { name: "site_id", unique: true })
  siteId: number;

  @Column("integer", { name: "supervisor_id", unique: true })
  supervisorId: number;

  @Column("timestamp without time zone", {
    name: "assigned_at",
    default: () => "now()",
  })
  assignedAt: Date;

  @ManyToOne(() => MiningSites, (miningSites) => miningSites.siteSupervisors)
  @JoinColumn([{ name: "site_id", referencedColumnName: "id" }])
  site: MiningSites;

  @ManyToOne(() => Users, (users) => users.siteSupervisors)
  @JoinColumn([{ name: "supervisor_id", referencedColumnName: "id" }])
  supervisor: Users;
}
