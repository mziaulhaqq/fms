import {
  Column,
  Entity,
  Index,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { AuditEntity } from './AuditEntity';
import { GeneralLedger } from './GeneralLedger.entity';

@Index('account_types_pkey', ['id'], { unique: true })
@Index('account_types_name_key', ['name'], { unique: true })
@Entity('account_types', { schema: 'coal_mining' })
export class AccountType extends AuditEntity {
  @PrimaryGeneratedColumn({ type: 'integer', name: 'id' })
  id: number;

  @Column('character varying', { name: 'name', unique: true, length: 100 })
  name: string;

  @Column('text', { name: 'description', nullable: true })
  description: string | null;

  @Column('boolean', { name: 'is_active', default: () => 'true' })
  isActive: boolean;

  @OneToMany(() => GeneralLedger, (ledger) => ledger.accountType)
  generalLedgers: GeneralLedger[];
}
