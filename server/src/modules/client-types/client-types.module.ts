import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ClientTypesService } from './client-types.service';
import { ClientTypesController } from './client-types.controller';
import { ClientType } from '../../entities/ClientType.entity';

@Module({
  imports: [TypeOrmModule.forFeature([ClientType])],
  controllers: [ClientTypesController],
  providers: [ClientTypesService],
  exports: [ClientTypesService],
})
export class ClientTypesModule {}
