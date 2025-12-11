import {
  Column,
  Entity,
  Index,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { AuditEntity } from './AuditEntity';
import { Clients } from './Clients.entity';

@Index('client_types_pkey', ['id'], { unique: true })
@Index('client_types_name_key', ['name'], { unique: true })
@Entity('client_types', { schema: 'coal_mining' })
export class ClientType extends AuditEntity {
  @PrimaryGeneratedColumn({ type: 'integer', name: 'id' })
  id: number;

  @Column('character varying', { name: 'name', unique: true, length: 100 })
  name: string;

  @Column('text', { name: 'description', nullable: true })
  description: string | null;

  @Column('boolean', { name: 'is_active', default: () => 'true' })
  isActive: boolean;

  @OneToMany(() => Clients, (client) => client.clientType)
  clients: Clients[];
}
