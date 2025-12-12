import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PaymentsService } from './payments.service';
import { PaymentsController } from './payments.controller';
import { Payment } from '../../entities/Payment.entity';
import { Payable } from '../../entities/Payable.entity';
import { Receivable } from '../../entities/Receivable.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Payment, Payable, Receivable])],
  controllers: [PaymentsController],
  providers: [PaymentsService],
  exports: [PaymentsService],
})
export class PaymentsModule {}
