import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Production } from '../../entities/production.entity';
import { ProductionsService } from './production.service';
import { ProductionsController } from './production.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Production])],
  controllers: [ProductionsController],
  providers: [ProductionsService],
  exports: [ProductionsService],
})
export class ProductionsModule {}
