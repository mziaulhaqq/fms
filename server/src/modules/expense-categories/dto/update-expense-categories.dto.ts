import { PartialType } from '@nestjs/swagger';
import { CreateExpenseCategoryDto } from './create-expense-categories.dto';

export class UpdateExpenseCategoryDto extends PartialType(CreateExpenseCategoryDto) {}
