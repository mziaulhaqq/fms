import { BeforeInsert, BeforeUpdate, Column } from 'typeorm';

export abstract class BaseEntityWithAudit {
  @Column('integer', { name: 'created_by', nullable: true })
  createdBy: number | null;

  @Column('integer', { name: 'modified_by', nullable: true })
  modifiedBy: number | null;

  @Column('timestamp without time zone', {
    name: 'created_at',
    default: () => 'now()',
  })
  createdAt: Date;

  @Column('timestamp without time zone', {
    name: 'updated_at',
    default: () => 'now()',
  })
  updatedAt: Date;

  // This will be set by the service before save
  _userId?: number;

  @BeforeInsert()
  setCreatedBy() {
    if (this._userId) {
      this.createdBy = this._userId;
      this.modifiedBy = this._userId;
    }
  }

  @BeforeUpdate()
  setModifiedBy() {
    if (this._userId) {
      this.modifiedBy = this._userId;
    }
    this.updatedAt = new Date();
  }
}
