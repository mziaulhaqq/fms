import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AccountTypesService } from './account-types.service';
import { AccountTypesController } from './account-types.controller';
import { AccountType } from '../../entities/AccountType.entity';

@Module({
  imports: [TypeOrmModule.forFeature([AccountType])],
  controllers: [AccountTypesController],
  providers: [AccountTypesService],
  exports: [AccountTypesService],
})
export class AccountTypesModule {}
