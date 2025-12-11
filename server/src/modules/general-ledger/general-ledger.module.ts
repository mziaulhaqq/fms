import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { GeneralLedgerService } from './general-ledger.service';
import { GeneralLedgerController } from './general-ledger.controller';
import { GeneralLedger } from '../../entities/GeneralLedger.entity';

@Module({
  imports: [TypeOrmModule.forFeature([GeneralLedger])],
  controllers: [GeneralLedgerController],
  providers: [GeneralLedgerService],
  exports: [GeneralLedgerService],
})
export class GeneralLedgerModule {}
