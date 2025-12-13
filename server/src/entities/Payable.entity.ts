import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { AuditEntity } from './AuditEntity';
import { Clients } from './Clients.entity';
import { MiningSites } from './MiningSites.entity';
import { Payment } from './Payment.entity';

@Index('payables_pkey', ['id'], { unique: true })
@Index('idx_payable_client', ['clientId'], {})
@Index('idx_payable_mining_site', ['miningSiteId'], {})
@Index('idx_payable_date', ['date'], {})
@Entity('payables', { schema: 'coal_mining' })
export class Payable extends AuditEntity {
  @PrimaryGeneratedColumn({ type: 'integer', name: 'id' })
  id: number;

  @Column('varchar', { name: 'type', length: 50, default: 'Advance Payment' })
  type: string;

  @Column('integer', { name: 'client_id' })
  clientId: number;

  @Column('integer', { name: 'mining_site_id' })
  miningSiteId: number;

  @Column('date', { name: 'date' })
  date: string;

  @Column('text', { name: 'description', nullable: true })
  description: string | null;

  @Column('numeric', { name: 'total_amount', precision: 12, scale: 2 })
  totalAmount: string;

  @Column('numeric', {
    name: 'remaining_balance',
    precision: 12,
    scale: 2,
    default: 0,
  })
  remainingBalance: string;

  @Column('text', {
    name: 'proof',
    array: true,
    nullable: true,
    default: () => "'{}'",
  })
  proof: string[] | null;

  @Column('varchar', {
    name: 'status',
    length: 50,
    default: () => "'Active'",
  })
  status: 'Active' | 'Partially Used' | 'Fully Used';

  @ManyToOne(() => Clients, (client) => client.payables)
  @JoinColumn([{ name: 'client_id', referencedColumnName: 'id' }])
  client: Clients;

  @ManyToOne(() => MiningSites, (miningSite) => miningSite.payables)
  @JoinColumn([{ name: 'mining_site_id', referencedColumnName: 'id' }])
  miningSite: MiningSites;

  @OneToMany(() => Payment, (payment) => payment.payable)
  payments: Payment[];
}
