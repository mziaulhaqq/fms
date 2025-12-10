import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { MiningSite } from './mining-site.entity';

@Entity({ schema: 'coal_mining', name: 'production' })
export class Production {
  @ApiProperty({ description: 'Unique identifier' })
  @PrimaryGeneratedColumn()
  id: number;

  @ApiProperty({ description: 'Production date' })
  @Column({ type: 'date' })
  date: Date;

  @ApiProperty({ description: 'Mining site ID' })
  @Column({ name: 'site_id' })
  siteId: number;

  @ApiProperty({ description: 'Quantity produced (in tons)' })
  @Column({ type: 'decimal', precision: 15, scale: 2 })
  quantity: number;

  @ApiProperty({ description: 'Quality grade', required: false })
  @Column({ length: 50, nullable: true })
  quality: string;

  @ApiProperty({ description: 'Shift (morning, afternoon, night)', required: false })
  @Column({ length: 50, nullable: true })
  shift: string;

  @ApiProperty({ description: 'Production notes', required: false })
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
