import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { MiningSites } from "./MiningSites";

@Entity("production", { schema: "coal_mining" })
export class Production {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("date", { name: "date" })
  date: string;

  @Column("numeric", { name: "quantity", precision: 15, scale: 2 })
  quantity: string;

  @Column("character varying", { name: "quality", nullable: true, length: 50 })
  quality: string | null;

  @Column("character varying", { name: "shift", nullable: true, length: 50 })
  shift: string | null;

  @Column("text", { name: "notes", nullable: true })
  notes: string | null;

  @Column("timestamp without time zone", {
    name: "created_at",
    default: () => "CURRENT_TIMESTAMP",
  })
  createdAt: Date;

  @Column("timestamp without time zone", {
    name: "updated_at",
    default: () => "CURRENT_TIMESTAMP",
  })
  updatedAt: Date;

  @ManyToOne(() => MiningSites, (miningSites) => miningSites.productions, {
    onDelete: "CASCADE",
  })
  @JoinColumn([{ name: "site_id", referencedColumnName: "id" }])
  site: MiningSites;
}
