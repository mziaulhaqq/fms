import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LiabilitiesService } from './liabilities.service';
import { LiabilitiesController } from './liabilities.controller';
import { Liability } from '../../entities/Liability.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Liability])],
  controllers: [LiabilitiesController],
  providers: [LiabilitiesService],
  exports: [LiabilitiesService],
})
export class LiabilitiesModule {}
