import {
  EventSubscriber,
  EntitySubscriberInterface,
  InsertEvent,
  UpdateEvent,
} from 'typeorm';
import { AuditEntity } from '../../entities/AuditEntity';

@EventSubscriber()
export class AuditSubscriber implements EntitySubscriberInterface<AuditEntity> {
  /**
   * Indicates that this subscriber only listen to AuditEntity events.
   */
  listenTo() {
    return AuditEntity;
  }

  /**
   * Called before entity insertion.
   */
  beforeInsert(event: InsertEvent<AuditEntity>) {
    if (event.entity._userId) {
      event.entity.createdById = event.entity._userId;
      event.entity.modifiedById = event.entity._userId;
    }
  }

  /**
   * Called before entity update.
   */
  beforeUpdate(event: UpdateEvent<AuditEntity>) {
    if (event.entity && event.entity._userId) {
      event.entity.modifiedById = event.entity._userId;
    }
  }
}
