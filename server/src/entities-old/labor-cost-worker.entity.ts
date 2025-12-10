import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { LaborCost } from './labor-cost.entity';
import { Labor } from './labor.entity';

@Entity({ schema: 'coal_mining', name: 'labor_cost_workers' })
export class LaborCostWorker {
  @ApiProperty({ description: 'Unique identifier' })
  @PrimaryGeneratedColumn()
  id: number;

  @ApiProperty({ description: 'Labor cost ID' })
  @Column({ name: 'labor_cost_id' })
  laborCostId: number;

  @ApiProperty({ description: 'Worker ID' })
  @Column({ name: 'worker_id' })
  workerId: number;

  @ApiProperty({ description: 'Hours worked' })
  @Column({ type: 'decimal', precision: 10, scale: 2 })
  hours: number;

  @ApiProperty({ description: 'Cost for this worker' })
  @Column({ type: 'decimal', precision: 15, scale: 2 })
  cost: number;

  @ApiProperty({ description: 'Record creation timestamp' })
  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ApiProperty({ description: 'Record update timestamp' })
  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => LaborCost, laborCost => laborCost.workers)
  @JoinColumn({ name: 'labor_cost_id' })
  laborCost: LaborCost;

  @ManyToOne(() => Labor, worker => worker.laborCostWorkers)
  @JoinColumn({ name: 'worker_id' })
  worker: Labor;
}
