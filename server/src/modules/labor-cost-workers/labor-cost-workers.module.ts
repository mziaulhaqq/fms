import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LaborCostWorker } from '../../entities/labor-cost-worker.entity';
import { LaborCostWorkersService } from './labor-cost-workers.service';
import { LaborCostWorkersController } from './labor-cost-workers.controller';

@Module({
  imports: [TypeOrmModule.forFeature([LaborCostWorker])],
  controllers: [LaborCostWorkersController],
  providers: [LaborCostWorkersService],
  exports: [LaborCostWorkersService],
})
export class LaborCostWorkersModule {}
