import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn, OneToMany } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { MiningSite } from './mining-site.entity';
import { LaborCostWorker } from './labor-cost-worker.entity';

@Entity({ schema: 'coal_mining', name: 'workers' })
export class Labor {
  @ApiProperty({ description: 'Unique identifier' })
  @PrimaryGeneratedColumn()
  id: number;

  @ApiProperty({ description: 'Worker name' })
  @Column({ length: 255 })
  name: string;

  @ApiProperty({ description: 'Worker role/position', required: false })
  @Column({ length: 100, nullable: true })
  role: string;

  @ApiProperty({ description: 'Contact number', required: false })
  @Column({ length: 50, nullable: true })
  contact: string;

  @ApiProperty({ description: 'Mining site ID', required: false })
  @Column({ name: 'site_id', nullable: true })
  siteId: number;

  @ApiProperty({ description: 'Hourly rate', required: false })
  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true, name: 'hourly_rate' })
  hourlyRate: number;

  @ApiProperty({ description: 'Record creation timestamp' })
  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ApiProperty({ description: 'Record update timestamp' })
  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => MiningSite, site => site.workers)
  @JoinColumn({ name: 'site_id' })
  site: MiningSite;

  @OneToMany(() => LaborCostWorker, laborCostWorker => laborCostWorker.worker)
  laborCostWorkers: LaborCostWorker[];
}
