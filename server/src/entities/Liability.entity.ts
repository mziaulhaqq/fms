import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { AuditEntity } from './AuditEntity';
import { Clients } from './Clients.entity';
import { MiningSites } from './MiningSites.entity';

@Index('liabilities_pkey', ['id'], { unique: true })
@Index('idx_liability_client', ['clientId'], {})
@Index('idx_liability_mining_site', ['miningSiteId'], {})
@Index('idx_liability_date', ['date'], {})
@Entity('liabilities', { schema: 'coal_mining' })
export class Liability extends AuditEntity {
  @PrimaryGeneratedColumn({ type: 'integer', name: 'id' })
  id: number;

  @Column('enum', {
    name: 'type',
    enum: ['Loan', 'Advanced Payment'],
  })
  type: 'Loan' | 'Advanced Payment';

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

  @Column('enum', {
    name: 'status',
    enum: ['Active', 'Partially Settled', 'Fully Settled'],
    default: () => "'Active'",
  })
  status: 'Active' | 'Partially Settled' | 'Fully Settled';

  @ManyToOne(() => Clients, (client) => client.liabilities)
  @JoinColumn([{ name: 'client_id', referencedColumnName: 'id' }])
  client: Clients;

  @ManyToOne(() => MiningSites, (miningSite) => miningSite.liabilities)
  @JoinColumn([{ name: 'mining_site_id', referencedColumnName: 'id' }])
  miningSite: MiningSites;
}
