import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TruckDeliveries } from '../../entities/TruckDeliveries.entity';
import { TruckDeliverysService } from './truck-deliveries.service';
import { TruckDeliverysController } from './truck-deliveries.controller';

@Module({
  imports: [TypeOrmModule.forFeature([TruckDelivery])],
  controllers: [TruckDeliverysController],
  providers: [TruckDeliverysService],
  exports: [TruckDeliverysService],
})
export class TruckDeliverysModule {}
