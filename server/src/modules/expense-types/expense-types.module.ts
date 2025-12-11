import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ExpenseTypesService } from './expense-types.service';
import { ExpenseTypesController } from './expense-types.controller';
import { ExpenseType } from '../../entities/ExpenseType.entity';

@Module({
  imports: [TypeOrmModule.forFeature([ExpenseType])],
  controllers: [ExpenseTypesController],
  providers: [ExpenseTypesService],
  exports: [ExpenseTypesService],
})
export class ExpenseTypesModule {}
