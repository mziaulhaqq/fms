import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReceivablesService } from './receivables.service';
import { ReceivablesController } from './receivables.controller';
import { Receivable } from '../../entities/Receivable.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Receivable])],
  controllers: [ReceivablesController],
  providers: [ReceivablesService],
  exports: [ReceivablesService],
})
export class ReceivablesModule {}
