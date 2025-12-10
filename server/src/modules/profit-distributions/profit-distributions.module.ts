import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProfitDistribution } from '../../entities/profit-distribution.entity';
import { ProfitDistributionsService } from './profit-distributions.service';
import { ProfitDistributionsController } from './profit-distributions.controller';

@Module({
  imports: [TypeOrmModule.forFeature([ProfitDistribution])],
  controllers: [ProfitDistributionsController],
  providers: [ProfitDistributionsService],
  exports: [ProfitDistributionsService],
})
export class ProfitDistributionsModule {}
