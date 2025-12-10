import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PartnerPayouts } from '../../entities/PartnerPayouts.entity';
import { PartnerPayoutsService } from './partner-payouts.service';
import { PartnerPayoutsController } from './partner-payouts.controller';

@Module({
  imports: [TypeOrmModule.forFeature([PartnerPayouts])],
  controllers: [PartnerPayoutsController],
  providers: [PartnerPayoutsService],
  exports: [PartnerPayoutsService],
})
export class PartnerPayoutsModule {}
