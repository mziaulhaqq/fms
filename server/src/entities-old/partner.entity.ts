import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { MiningSite } from './mining-site.entity';
import { PartnerPayout } from './partner-payout.entity';
import { ProfitDistribution } from './profit-distribution.entity';

@Entity({ schema: 'coal_mining', name: 'partners' })
export class Partner {
  @ApiProperty({ description: 'Unique identifier' })
  @PrimaryGeneratedColumn()
  id: number;

  @ApiProperty({ description: 'Partner name' })
  @Column({ length: 255 })
  name: string;

  @ApiProperty({ description: 'Contact information', required: false })
  @Column({ type: 'text', nullable: true })
  contact: string;

  @ApiProperty({ description: 'Profit share percentage', required: false })
  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true, name: 'profit_share' })
  profitShare: number;

  @ApiProperty({ description: 'Record creation timestamp' })
  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ApiProperty({ description: 'Record update timestamp' })
  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @OneToMany(() => MiningSite, site => site.partner)
  sites: MiningSite[];

  @OneToMany(() => PartnerPayout, payout => payout.partner)
  payouts: PartnerPayout[];

  @OneToMany(() => ProfitDistribution, distribution => distribution.partner)
  profitDistributions: ProfitDistribution[];
}
