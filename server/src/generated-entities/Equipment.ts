import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { MiningSites } from "./MiningSites";

@Entity("equipment", { schema: "coal_mining" })
export class Equipment {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("character varying", { name: "name", length: 255 })
  name: string;

  @Column("character varying", { name: "type", nullable: true, length: 100 })
  type: string | null;

  @Column("character varying", { name: "model", nullable: true, length: 255 })
  model: string | null;

  @Column("character varying", {
    name: "serial_number",
    nullable: true,
    length: 255,
  })
  serialNumber: string | null;

  @Column("date", { name: "purchase_date", nullable: true })
  purchaseDate: string | null;

  @Column("numeric", {
    name: "purchase_price",
    nullable: true,
    precision: 15,
    scale: 2,
  })
  purchasePrice: string | null;

  @Column("character varying", {
    name: "status",
    nullable: true,
    length: 50,
    default: () => "'active'",
  })
  status: string | null;

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

  @ManyToOne(() => MiningSites, (miningSites) => miningSites.equipment, {
    onDelete: "SET NULL",
  })
  @JoinColumn([{ name: "site_id", referencedColumnName: "id" }])
  site: MiningSites;
}
