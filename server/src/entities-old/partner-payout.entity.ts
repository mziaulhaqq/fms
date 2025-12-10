import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { Partner } from './partner.entity';

@Entity({ schema: 'coal_mining', name: 'partner_payouts' })
export class PartnerPayout {
  @ApiProperty({ description: 'Unique identifier' })
  @PrimaryGeneratedColumn()
  id: number;

  @ApiProperty({ description: 'Partner ID' })
  @Column({ name: 'partner_id' })
  partnerId: number;

  @ApiProperty({ description: 'Payout date' })
  @Column({ type: 'date' })
  date: Date;

  @ApiProperty({ description: 'Payout amount' })
  @Column({ type: 'decimal', precision: 15, scale: 2 })
  amount: number;

  @ApiProperty({ description: 'Payout description', required: false })
  @Column({ type: 'text', nullable: true })
  description: string;

  @ApiProperty({ description: 'Record creation timestamp' })
  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ApiProperty({ description: 'Record update timestamp' })
  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => Partner, partner => partner.payouts)
  @JoinColumn({ name: 'partner_id' })
  partner: Partner;
}
