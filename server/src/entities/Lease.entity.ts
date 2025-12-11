import {
  Column,
  Entity,
  Index,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { AuditEntity } from './AuditEntity';
import { MiningSites } from './MiningSites.entity';
import { Partners } from './Partners.entity';

@Index('leases_pkey', ['id'], { unique: true })
@Entity('leases', { schema: 'coal_mining' })
export class Lease extends AuditEntity {
  @PrimaryGeneratedColumn({ type: 'integer', name: 'id' })
  id: number;

  @Column('character varying', { name: 'lease_name', length: 255 })
  leaseName: string;

  @Column('text', { name: 'location', nullable: true })
  location: string | null;

  @Column('boolean', { name: 'is_active', default: () => 'true' })
  isActive: boolean;

  @OneToMany(() => MiningSites, (miningSite) => miningSite.lease)
  miningSites: MiningSites[];

  @OneToMany(() => Partners, (partner) => partner.lease)
  partners: Partners[];
}
