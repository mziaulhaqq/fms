import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { AuditEntity } from './AuditEntity';
import { AccountType } from './AccountType.entity';
import { MiningSites } from './MiningSites.entity';

@Index('general_ledger_pkey', ['id'], { unique: true })
@Index('idx_ledger_account_code', ['accountCode'], {})
@Index('idx_ledger_mining_site', ['miningSiteId'], {})
@Entity('general_ledger', { schema: 'coal_mining' })
export class GeneralLedger extends AuditEntity {
  @PrimaryGeneratedColumn({ type: 'integer', name: 'id' })
  id: number;

  @Column('character varying', { name: 'account_code', length: 50 })
  accountCode: string;

  @Column('character varying', { name: 'account_name', length: 255 })
  accountName: string;

  @Column('integer', { name: 'account_type_id' })
  accountTypeId: number;

  @Column('integer', { name: 'mining_site_id' })
  miningSiteId: number;

  @Column('text', { name: 'description', nullable: true })
  description: string | null;

  @Column('boolean', { name: 'is_active', default: () => 'true' })
  isActive: boolean;

  @ManyToOne(() => AccountType, (accountType) => accountType.generalLedgers)
  @JoinColumn([{ name: 'account_type_id', referencedColumnName: 'id' }])
  accountType: AccountType;

  @ManyToOne(() => MiningSites, (miningSite) => miningSite.generalLedgers)
  @JoinColumn([{ name: 'mining_site_id', referencedColumnName: 'id' }])
  miningSite: MiningSites;
}
