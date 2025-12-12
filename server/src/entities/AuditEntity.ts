import {
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  BeforeInsert,
  BeforeUpdate,
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

  // Temporary property to hold the current user ID
  // This should be set by the service before calling save()
  _userId?: number;

  @BeforeInsert()
  setCreatedBy() {
    if (this._userId) {
      this.createdById = this._userId;
      this.modifiedById = this._userId;
    }
  }

  @BeforeUpdate()
  setModifiedBy() {
    if (this._userId) {
      this.modifiedById = this._userId;
    }
  }
}
