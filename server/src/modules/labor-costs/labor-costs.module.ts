import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LaborCosts } from '../../entities/LaborCosts.entity';
import { LaborCostsService } from './labor-costs.service';
import { LaborCostsController } from './labor-costs.controller';

@Module({
  imports: [TypeOrmModule.forFeature([LaborCosts])],
  controllers: [LaborCostsController],
  providers: [LaborCostsService],
  exports: [LaborCostsService],
})
export class LaborCostsModule {}
