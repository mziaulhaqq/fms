import { PartialType } from '@nestjs/swagger';
import { CreateExpenseDto } from './create-expenses.dto';

export class UpdateExpenseDto extends PartialType(CreateExpenseDto) {}
