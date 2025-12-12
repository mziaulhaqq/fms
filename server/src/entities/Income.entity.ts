import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { AuditEntity } from "./AuditEntity";
import { Clients } from "./Clients.entity";
import { Users } from "./Users.entity";
import { MiningSites } from "./MiningSites.entity";

@Index("idx_income_date", ["loadingDate"], {})
@Index("idx_income_site", ["siteId"], {})
@Index("idx_income_client", ["clientId"], {})
@Entity("income", { schema: "coal_mining" })
export class Income extends AuditEntity {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("integer", { name: "site_id" })
  siteId: number;

  @Column("integer", { name: "client_id", nullable: true })
  clientId: number | null;

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

  @Column("numeric", {
    name: "amount_from_liability",
    nullable: true,
    precision: 12,
    scale: 2,
    default: 0,
  })
  amountFromLiability: string | null;

  @Column("numeric", {
    name: "amount_cash",
    nullable: true,
    precision: 12,
    scale: 2,
    default: 0,
  })
  amountCash: string | null;

  @Column("integer", { name: "liability_id", nullable: true })
  liabilityId: number | null;

  @ManyToOne(() => Clients, (clients) => clients.incomes)
  @JoinColumn([{ name: "client_id", referencedColumnName: "id" }])
  client: Clients;

  @ManyToOne(() => MiningSites, (miningSites) => miningSites.incomes)
  @JoinColumn([{ name: "site_id", referencedColumnName: "id" }])
  site: MiningSites;
}
