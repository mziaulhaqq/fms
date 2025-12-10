import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { MiningSite } from './mining-site.entity';
import { Client } from './client.entity';

@Entity({ schema: 'coal_mining', name: 'income' })
export class Income {
  @ApiProperty({ description: 'Unique identifier' })
  @PrimaryGeneratedColumn()
  id: number;

  @ApiProperty({ description: 'Income date' })
  @Column({ type: 'date' })
  date: Date;

  @ApiProperty({ description: 'Income amount' })
  @Column({ type: 'decimal', precision: 15, scale: 2 })
  amount: number;

  @ApiProperty({ description: 'Income source', required: false })
  @Column({ length: 255, nullable: true })
  source: string;

  @ApiProperty({ description: 'Income description', required: false })
  @Column({ type: 'text', nullable: true })
  description: string;

  @ApiProperty({ description: 'Mining site ID', required: false })
  @Column({ name: 'site_id', nullable: true })
  siteId: number;

  @ApiProperty({ description: 'Client ID', required: false })
  @Column({ name: 'client_id', nullable: true })
  clientId: number;

  @ApiProperty({ description: 'Record creation timestamp' })
  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ApiProperty({ description: 'Record update timestamp' })
  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => MiningSite, site => site.incomes)
  @JoinColumn({ name: 'site_id' })
  site: MiningSite;

  @ManyToOne(() => Client, client => client.incomes)
  @JoinColumn({ name: 'client_id' })
  client: Client;
}
