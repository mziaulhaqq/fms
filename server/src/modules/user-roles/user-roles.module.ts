import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserRoles } from '../../entities/UserRoles.entity';
import { UserRolesService } from './user-roles.service';
import { UserRolesController } from './user-roles.controller';

@Module({
  imports: [TypeOrmModule.forFeature([UserRoles])],
  controllers: [UserRolesController],
  providers: [UserRolesService],
  exports: [UserRolesService],
})
export class UserRolesModule {}
