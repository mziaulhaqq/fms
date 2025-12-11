import {
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

/**
 * Base entity class that provides audit fields for all entities
 * Provides: createdAt, updatedAt, createdBy, modifiedBy
 * Note: Relations to Users are defined in individual entities to avoid circular dependencies
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
}
