import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProfitDistributions } from '../../entities/ProfitDistributions.entity';
import { ProfitDistributionsService } from './profit-distributions.service';
import { ProfitDistributionsController } from './profit-distributions.controller';

@Module({
  imports: [TypeOrmModule.forFeature([ProfitDistributions])],
  controllers: [ProfitDistributionsController],
  providers: [ProfitDistributionsService],
  exports: [ProfitDistributionsService],
})
export class ProfitDistributionsModule {}
