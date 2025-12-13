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

@Index('receivables_pkey', ['id'], { unique: true })
@Index('idx_receivable_client', ['clientId'], {})
@Index('idx_receivable_mining_site', ['miningSiteId'], {})
@Index('idx_receivable_date', ['date'], {})
@Entity('receivables', { schema: 'coal_mining' })
export class Receivable extends AuditEntity {
  @PrimaryGeneratedColumn({ type: 'integer', name: 'id' })
  id: number;

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

  @Column('varchar', {
    name: 'status',
    length: 50,
    default: () => "'Pending'",
  })
  status: 'Pending' | 'Partially Paid' | 'Fully Paid';

  @ManyToOne(() => Clients, (client) => client.receivables)
  @JoinColumn([{ name: 'client_id', referencedColumnName: 'id' }])
  client: Clients;

  @ManyToOne(() => MiningSites, (miningSite) => miningSite.receivables)
  @JoinColumn([{ name: 'mining_site_id', referencedColumnName: 'id' }])
  miningSite: MiningSites;

  @OneToMany(() => Payment, (payment) => payment.receivable)
  payments: Payment[];
}
