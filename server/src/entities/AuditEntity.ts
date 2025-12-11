import {
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Users } from './Users.entity';

/**
 * Base entity class that provides audit fields for all entities
 * Provides: createdAt, updatedAt, createdBy, modifiedBy
 */
export abstract class AuditEntity {
  @CreateDateColumn({
    name: 'created_at',
    type: 'timestamp without time zone',
    default: () => 'now()',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
    type: 'timestamp without time zone',
    default: () => 'now()',
  })
  updatedAt: Date;

  @Column('integer', { name: 'created_by', nullable: true })
  createdById: number | null;

  @Column('integer', { name: 'modified_by', nullable: true })
  modifiedById: number | null;

  @ManyToOne(() => Users, { nullable: true })
  @JoinColumn([{ name: 'created_by', referencedColumnName: 'id' }])
  createdBy: Users;

  @ManyToOne(() => Users, { nullable: true })
  @JoinColumn([{ name: 'modified_by', referencedColumnName: 'id' }])
  modifiedBy: Users;
}
