import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { Partner } from './partner.entity';

@Entity({ schema: 'coal_mining', name: 'profit_distributions' })
export class ProfitDistribution {
  @ApiProperty({ description: 'Unique identifier' })
  @PrimaryGeneratedColumn()
  id: number;

  @ApiProperty({ description: 'Partner ID' })
  @Column({ name: 'partner_id' })
  partnerId: number;

  @ApiProperty({ description: 'Distribution date' })
  @Column({ type: 'date' })
  date: Date;

  @ApiProperty({ description: 'Distribution amount' })
  @Column({ type: 'decimal', precision: 15, scale: 2 })
  amount: number;

  @ApiProperty({ description: 'Distribution notes', required: false })
  @Column({ type: 'text', nullable: true })
  notes: string;

  @ApiProperty({ description: 'Record creation timestamp' })
  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ApiProperty({ description: 'Record update timestamp' })
  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => Partner, partner => partner.profitDistributions)
  @JoinColumn({ name: 'partner_id' })
  partner: Partner;
}
