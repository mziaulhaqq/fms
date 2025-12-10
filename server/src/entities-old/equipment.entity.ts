import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { MiningSite } from './mining-site.entity';

@Entity({ schema: 'coal_mining', name: 'equipment' })
export class Equipment {
  @ApiProperty({ description: 'Unique identifier' })
  @PrimaryGeneratedColumn()
  id: number;

  @ApiProperty({ description: 'Equipment name' })
  @Column({ length: 255 })
  name: string;

  @ApiProperty({ description: 'Equipment type', required: false })
  @Column({ length: 100, nullable: true })
  type: string;

  @ApiProperty({ description: 'Equipment model', required: false })
  @Column({ length: 255, nullable: true })
  model: string;

  @ApiProperty({ description: 'Serial number', required: false })
  @Column({ length: 255, nullable: true, name: 'serial_number' })
  serialNumber: string;

  @ApiProperty({ description: 'Purchase date', required: false })
  @Column({ type: 'date', nullable: true, name: 'purchase_date' })
  purchaseDate: Date;

  @ApiProperty({ description: 'Purchase price', required: false })
  @Column({ type: 'decimal', precision: 15, scale: 2, nullable: true, name: 'purchase_price' })
  purchasePrice: number;

  @ApiProperty({ description: 'Equipment status', required: false })
  @Column({ length: 50, nullable: true, default: 'active' })
  status: string;

  @ApiProperty({ description: 'Mining site ID', required: false })
  @Column({ name: 'site_id', nullable: true })
  siteId: number;

  @ApiProperty({ description: 'Equipment notes', required: false })
  @Column({ type: 'text', nullable: true })
  notes: string;

  @ApiProperty({ description: 'Record creation timestamp' })
  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ApiProperty({ description: 'Record update timestamp' })
  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => MiningSite)
  @JoinColumn({ name: 'site_id' })
  site: MiningSite;
}
