import {
  Column,
  Entity,
  Index,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { AuditEntity } from './AuditEntity';
import { Expenses } from './Expenses.entity';

@Index('expense_types_pkey', ['id'], { unique: true })
@Index('expense_types_name_key', ['name'], { unique: true })
@Entity('expense_types', { schema: 'coal_mining' })
export class ExpenseType extends AuditEntity {
  @PrimaryGeneratedColumn({ type: 'integer', name: 'id' })
  id: number;

  @Column('character varying', { name: 'name', unique: true, length: 100 })
  name: string;

  @Column('text', { name: 'description', nullable: true })
  description: string | null;

  @Column('boolean', { name: 'is_active', default: () => 'true' })
  isActive: boolean;

  @OneToMany(() => Expenses, (expense) => expense.expenseType)
  expenses: Expenses[];
}
