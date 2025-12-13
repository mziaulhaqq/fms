import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Clients } from './Clients.entity';
import { MiningSites } from './MiningSites.entity';
import { Users } from './Users.entity';
import { Payable } from './Payable.entity';
import { Receivable } from './Receivable.entity';

@Index('payments_pkey', ['id'], { unique: true })
@Index('idx_payment_client', ['clientId'], {})
@Index('idx_payment_mining_site', ['miningSiteId'], {})
@Index('idx_payment_date', ['paymentDate'], {})
@Entity('payments', { schema: 'coal_mining' })
export class Payment {
  @PrimaryGeneratedColumn({ type: 'integer', name: 'id' })
  id: number;

  @Column('integer', { name: 'client_id' })
  clientId: number;

  @Column('integer', { name: 'mining_site_id' })
  miningSiteId: number;

  @Column('varchar', {
    name: 'payment_type',
    length: 50,
    comment: 'Payable Deduction or Receivable Payment',
  })
  paymentType: 'Payable Deduction' | 'Receivable Payment';

  @Column('integer', { name: 'payable_id', nullable: true })
  payableId: number | null;

  @Column('integer', { name: 'receivable_id', nullable: true })
  receivableId: number | null;

  @Column('numeric', { name: 'amount', precision: 12, scale: 2 })
  amount: string;

  @Column('date', { name: 'payment_date' })
  paymentDate: string;

  @Column('varchar', {
    name: 'payment_method',
    length: 50,
    nullable: true,
    comment: 'Cash, Bank Transfer, etc.',
  })
  paymentMethod: string | null;

  @Column('text', {
    name: 'proof',
    array: true,
    nullable: true,
    default: () => "'{}'",
    comment: 'File paths for receipts/proofs',
  })
  proof: string[] | null;

  @Column('varchar', { name: 'received_by', length: 255, nullable: true })
  receivedBy: string | null;

  @Column('text', { name: 'notes', nullable: true })
  notes: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp' })
  createdAt: Date;

  @Column('integer', { name: 'created_by', nullable: true })
  createdBy: number | null;

  @ManyToOne(() => Clients, (client) => client.payments)
  @JoinColumn([{ name: 'client_id', referencedColumnName: 'id' }])
  client: Clients;

  @ManyToOne(() => MiningSites, (miningSite) => miningSite.payments)
  @JoinColumn([{ name: 'mining_site_id', referencedColumnName: 'id' }])
  miningSite: MiningSites;

  @ManyToOne(() => Payable, (payable) => payable.payments, { nullable: true })
  @JoinColumn([{ name: 'payable_id', referencedColumnName: 'id' }])
  payable: Payable | null;

  @ManyToOne(() => Receivable, (receivable) => receivable.payments, { nullable: true })
  @JoinColumn([{ name: 'receivable_id', referencedColumnName: 'id' }])
  receivable: Receivable | null;
}
