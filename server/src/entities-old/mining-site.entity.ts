import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn, OneToMany } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { Partner } from './partner.entity';
import { Expense } from './expense.entity';
import { Income } from './income.entity';
import { Labor } from './labor.entity';
import { TruckDelivery } from './truck-delivery.entity';
import { SiteSupervisor } from './site-supervisor.entity';

@Entity({ schema: 'coal_mining', name: 'mining_sites' })
export class MiningSite {
  @ApiProperty({ description: 'Unique identifier' })
  @PrimaryGeneratedColumn()
  id: number;

  @ApiProperty({ description: 'Site name' })
  @Column({ length: 255 })
  name: string;

  @ApiProperty({ description: 'Site location', required: false })
  @Column({ type: 'text', nullable: true })
  location: string;

  @ApiProperty({ description: 'Site status', required: false })
  @Column({ length: 50, nullable: true, default: 'active' })
  status: string;

  @ApiProperty({ description: 'Partner ID', required: false })
  @Column({ name: 'partner_id', nullable: true })
  partnerId: number;

  @ApiProperty({ description: 'Record creation timestamp' })
  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ApiProperty({ description: 'Record update timestamp' })
  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => Partner, partner => partner.sites)
  @JoinColumn({ name: 'partner_id' })
  partner: Partner;

  @OneToMany(() => Expense, expense => expense.site)
  expenses: Expense[];

  @OneToMany(() => Income, income => income.site)
  incomes: Income[];

  @OneToMany(() => Labor, worker => worker.site)
  workers: Labor[];

  @OneToMany(() => TruckDelivery, delivery => delivery.site)
  truckDeliveries: TruckDelivery[];

  @OneToMany(() => SiteSupervisor, supervisor => supervisor.site)
  supervisors: SiteSupervisor[];
}
