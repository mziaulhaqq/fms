import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PayablesService } from './payables.service';
import { PayablesController } from './payables.controller';
import { Payable } from '../../entities/Payable.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Payable])],
  controllers: [PayablesController],
  providers: [PayablesService],
  exports: [PayablesService],
})
export class PayablesModule {}
