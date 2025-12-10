import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProfitDistributions } from '../../entities/ProfitDistributions.entity';
import { ProfitDistributionsService } from './profit-distributions.service';
import { ProfitDistributionsController } from './profit-distributions.controller';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([ProfitDistributions]),
    AuthModule,
  ],
  controllers: [ProfitDistributionsController],
  providers: [ProfitDistributionsService],
  exports: [ProfitDistributionsService],
})
export class ProfitDistributionsModule {}
