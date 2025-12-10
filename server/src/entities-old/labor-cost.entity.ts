import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { LaborCostWorker } from './labor-cost-worker.entity';

@Entity({ schema: 'coal_mining', name: 'labor_costs' })
export class LaborCost {
  @ApiProperty({ description: 'Unique identifier' })
  @PrimaryGeneratedColumn()
  id: number;

  @ApiProperty({ description: 'Cost date' })
  @Column({ type: 'date' })
  date: Date;

  @ApiProperty({ description: 'Total cost amount' })
  @Column({ type: 'decimal', precision: 15, scale: 2, name: 'total_cost' })
  totalCost: number;

  @ApiProperty({ description: 'Cost description', required: false })
  @Column({ type: 'text', nullable: true })
  description: string;

  @ApiProperty({ description: 'Record creation timestamp' })
  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ApiProperty({ description: 'Record update timestamp' })
  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @OneToMany(() => LaborCostWorker, laborCostWorker => laborCostWorker.laborCost)
  workers: LaborCostWorker[];
}
