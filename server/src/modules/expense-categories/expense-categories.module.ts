import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ExpenseCategories } from '../../entities/ExpenseCategories.entity';
import { ExpenseCategorysService } from './expense-categories.service';
import { ExpenseCategorysController } from './expense-categories.controller';

@Module({
  imports: [TypeOrmModule.forFeature([ExpenseCategory])],
  controllers: [ExpenseCategorysController],
  providers: [ExpenseCategorysService],
  exports: [ExpenseCategorysService],
})
export class ExpenseCategorysModule {}
