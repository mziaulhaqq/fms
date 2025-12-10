import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { ExpenseCategory } from './expense-category.entity';
import { MiningSite } from './mining-site.entity';
import { Client } from './client.entity';

@Entity({ schema: 'coal_mining', name: 'expenses' })
export class Expense {
  @ApiProperty({ description: 'Unique identifier' })
  @PrimaryGeneratedColumn()
  id: number;

  @ApiProperty({ description: 'Expense date' })
  @Column({ type: 'date' })
  date: Date;

  @ApiProperty({ description: 'Expense amount' })
  @Column({ type: 'decimal', precision: 15, scale: 2 })
  amount: number;

  @ApiProperty({ description: 'Expense description', required: false })
  @Column({ type: 'text', nullable: true })
  description: string;

  @ApiProperty({ description: 'Category ID', required: false })
  @Column({ name: 'category_id', nullable: true })
  categoryId: number;

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

  @ManyToOne(() => ExpenseCategory, category => category.expenses)
  @JoinColumn({ name: 'category_id' })
  category: ExpenseCategory;

  @ManyToOne(() => MiningSite, site => site.expenses)
  @JoinColumn({ name: 'site_id' })
  site: MiningSite;

  @ManyToOne(() => Client, client => client.expenses)
  @JoinColumn({ name: 'client_id' })
  client: Client;
}
