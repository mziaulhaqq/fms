import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { Expense } from './expense.entity';
import { Income } from './income.entity';
import { TruckDelivery } from './truck-delivery.entity';

@Entity({ schema: 'coal_mining', name: 'clients' })
export class Client {
  @ApiProperty({ description: 'Unique identifier' })
  @PrimaryGeneratedColumn()
  id: number;

  @ApiProperty({ description: 'Client name' })
  @Column({ length: 255 })
  name: string;

  @ApiProperty({ description: 'Client email', required: false })
  @Column({ length: 255, nullable: true })
  email: string;

  @ApiProperty({ description: 'Client phone', required: false })
  @Column({ length: 50, nullable: true })
  phone: string;

  @ApiProperty({ description: 'Client address', required: false })
  @Column({ type: 'text', nullable: true })
  address: string;

  @ApiProperty({ description: 'Client type', required: false })
  @Column({ length: 100, nullable: true })
  type: string;

  @ApiProperty({ description: 'Record creation timestamp' })
  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ApiProperty({ description: 'Record update timestamp' })
  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @OneToMany(() => Expense, expense => expense.client)
  expenses: Expense[];

  @OneToMany(() => Income, income => income.client)
  incomes: Income[];

  @OneToMany(() => TruckDelivery, delivery => delivery.client)
  truckDeliveries: TruckDelivery[];
}
