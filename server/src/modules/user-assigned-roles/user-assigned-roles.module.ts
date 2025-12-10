import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserAssignedRoles } from '../../entities/UserAssignedRoles.entity';
import { UserAssignedRolesService } from './user-assigned-roles.service';
import { UserAssignedRolesController } from './user-assigned-roles.controller';

@Module({
  imports: [TypeOrmModule.forFeature([UserAssignedRole])],
  controllers: [UserAssignedRolesController],
  providers: [UserAssignedRolesService],
  exports: [UserAssignedRolesService],
})
export class UserAssignedRolesModule {}
