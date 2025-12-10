import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LaborCost } from '../../entities/labor-cost.entity';
import { LaborCostsService } from './labor-costs.service';
import { LaborCostsController } from './labor-costs.controller';

@Module({
  imports: [TypeOrmModule.forFeature([LaborCost])],
  controllers: [LaborCostsController],
  providers: [LaborCostsService],
  exports: [LaborCostsService],
})
export class LaborCostsModule {}
