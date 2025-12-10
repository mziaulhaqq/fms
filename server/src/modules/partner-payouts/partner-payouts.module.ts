import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PartnerPayout } from '../../entities/partner-payout.entity';
import { PartnerPayoutsService } from './partner-payouts.service';
import { PartnerPayoutsController } from './partner-payouts.controller';

@Module({
  imports: [TypeOrmModule.forFeature([PartnerPayout])],
  controllers: [PartnerPayoutsController],
  providers: [PartnerPayoutsService],
  exports: [PartnerPayoutsService],
})
export class PartnerPayoutsModule {}
