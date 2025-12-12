import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Income } from '../../entities/Income.entity';
import { Payable } from '../../entities/Payable.entity';
import { IncomesService } from './income.service';
import { IncomesController } from './income.controller';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Income, Payable]),
    AuthModule,
  ],
  controllers: [IncomesController],
  providers: [IncomesService],
  exports: [IncomesService],
})
export class IncomesModule {}
