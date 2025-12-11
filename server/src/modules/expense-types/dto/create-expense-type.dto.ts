import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsBoolean, MaxLength } from 'class-validator';

export class CreateExpenseTypeDto {
  @ApiProperty({ description: 'Expense type name', example: 'Worker' })
  @IsString()
  @MaxLength(100)
  name: string;

  @ApiProperty({ description: 'Type description', required: false })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ description: 'Is active', default: true, required: false })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
