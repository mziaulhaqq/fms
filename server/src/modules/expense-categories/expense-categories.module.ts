import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ExpenseCategory } from '../../entities/expense-category.entity';
import { ExpenseCategorysService } from './expense-categories.service';
import { ExpenseCategorysController } from './expense-categories.controller';

@Module({
  imports: [TypeOrmModule.forFeature([ExpenseCategory])],
  controllers: [ExpenseCategorysController],
  providers: [ExpenseCategorysService],
  exports: [ExpenseCategorysService],
})
export class ExpenseCategorysModule {}
