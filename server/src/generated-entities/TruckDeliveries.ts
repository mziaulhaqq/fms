import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { Users } from "./Users";
import { MiningSites } from "./MiningSites";

@Index("idx_delivery_date", ["deliveryDate"], {})
@Index("truck_deliveries_pkey", ["id"], { unique: true })
@Index("idx_delivery_site", ["siteId"], {})
@Entity("truck_deliveries", { schema: "coal_mining" })
export class TruckDeliveries {
  @PrimaryGeneratedColumn({ type: "integer", name: "id" })
  id: number;

  @Column("integer", { name: "site_id" })
  siteId: number;

  @Column("timestamp without time zone", { name: "delivery_date" })
  deliveryDate: Date;

  @Column("character varying", { name: "buyer_name", length: 255 })
  buyerName: string;

  @Column("character varying", { name: "vehicle_number", length: 50 })
  vehicleNumber: string;

  @Column("numeric", { name: "quantity_tons", precision: 10, scale: 2 })
  quantityTons: string;

  @Column("numeric", { name: "total_price", precision: 12, scale: 2 })
  totalPrice: string;

  @Column("character varying", {
    name: "status",
    nullable: true,
    length: 20,
    default: () => "'draft'",
  })
  status: string | null;

  @Column("text", { name: "evidence_photos", nullable: true, array: true })
  evidencePhotos: string[] | null;

  @Column("text", { name: "notes", nullable: true })
  notes: string | null;

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

  @ManyToOne(() => Users, (users) => users.truckDeliveries)
  @JoinColumn([{ name: "created_by", referencedColumnName: "id" }])
  createdBy: Users;

  @ManyToOne(() => MiningSites, (miningSites) => miningSites.truckDeliveries, {
    onDelete: "CASCADE",
  })
  @JoinColumn([{ name: "site_id", referencedColumnName: "id" }])
  site: MiningSites;
}
