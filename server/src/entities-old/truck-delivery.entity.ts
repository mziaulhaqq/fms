import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { MiningSite } from './mining-site.entity';
import { Client } from './client.entity';

@Entity({ schema: 'coal_mining', name: 'truck_deliveries' })
export class TruckDelivery {
  @ApiProperty({ description: 'Unique identifier' })
  @PrimaryGeneratedColumn()
  id: number;

  @ApiProperty({ description: 'Delivery date' })
  @Column({ type: 'date' })
  date: Date;

  @ApiProperty({ description: 'Truck number', required: false })
  @Column({ length: 100, nullable: true, name: 'truck_number' })
  truckNumber: string;

  @ApiProperty({ description: 'Quantity delivered', required: false })
  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  quantity: number;

  @ApiProperty({ description: 'Mining site ID', required: false })
  @Column({ name: 'site_id', nullable: true })
  siteId: number;

  @ApiProperty({ description: 'Client ID', required: false })
  @Column({ name: 'client_id', nullable: true })
  clientId: number;

  @ApiProperty({ description: 'Delivery notes', required: false })
  @Column({ type: 'text', nullable: true })
  notes: string;

  @ApiProperty({ description: 'Record creation timestamp' })
  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ApiProperty({ description: 'Record update timestamp' })
  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => MiningSite, site => site.truckDeliveries)
  @JoinColumn({ name: 'site_id' })
  site: MiningSite;

  @ManyToOne(() => Client, client => client.truckDeliveries)
  @JoinColumn({ name: 'client_id' })
  client: Client;
}
