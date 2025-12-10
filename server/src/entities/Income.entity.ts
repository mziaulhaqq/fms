import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { Clients } from "./Clients.entity";
import { Users } from "./Users.entity";
import { MiningSites } from "./MiningSites.entity";

@Index("idx_income_date", ["loadingDate"], {})
@Index("idx_income_site", ["siteId"], {})
@Entity("income", { schema: "coal_mining" })
export class Income {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("integer", { name: "site_id" })
  siteId: number;

  @Column("character varying", { name: "truck_number", length: 50 })
  truckNumber: string;

  @Column("timestamp without time zone", { name: "loading_date" })
  loadingDate: Date;

  @Column("character varying", { name: "driver_name", length: 255 })
  driverName: string;

  @Column("character varying", {
    name: "driver_phone",
    nullable: true,
    length: 20,
  })
  driverPhone: string | null;

  @Column("numeric", { name: "coal_price", precision: 12, scale: 2 })
  coalPrice: string;

  @Column("numeric", {
    name: "company_commission",
    nullable: true,
    precision: 12,
    scale: 2,
  })
  companyCommission: string | null;

  @Column("character varying", {
    name: "buyer_name",
    nullable: true,
    length: 255,
  })
  buyerName: string | null;

  @Column("character varying", {
    name: "vehicle_number",
    nullable: true,
    length: 50,
  })
  vehicleNumber: string | null;

  @Column("numeric", {
    name: "quantity_tons",
    nullable: true,
    precision: 10,
    scale: 2,
  })
  quantityTons: string | null;

  @Column("numeric", {
    name: "total_price",
    nullable: true,
    precision: 12,
    scale: 2,
  })
  totalPrice: string | null;

  @Column("enum", {
    name: "status",
    enum: ["draft", "completed"],
    default: () => "'draft'.income_status_enum",
  })
  status: "draft" | "completed";

  @Column("text", {
    name: "evidence_photos",
    array: true,
    default: () => "'{}'[]",
  })
  evidencePhotos: string[];

  @Column("text", { name: "description", nullable: true })
  description: string | null;

  @Column("text", { name: "notes", nullable: true })
  notes: string | null;

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

  @ManyToOne(() => Clients, (clients) => clients.incomes)
  @JoinColumn([{ name: "client_id", referencedColumnName: "id" }])
  client: Clients;

  @ManyToOne(() => Users, (users) => users.incomes)
  @JoinColumn([{ name: "created_by", referencedColumnName: "id" }])
  createdBy: Users;

  @ManyToOne(() => MiningSites, (miningSites) => miningSites.incomes)
  @JoinColumn([{ name: "site_id", referencedColumnName: "id" }])
  site: MiningSites;
}
