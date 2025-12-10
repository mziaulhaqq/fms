import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateExpenseCategoryDto {
  @ApiProperty({ description: 'Category name', example: 'Fuel & Energy' })
  @IsNotEmpty()
  @IsString()
  @MaxLength(100)
  name: string;

  @ApiProperty({ description: 'Category description', example: 'Diesel, electricity, and other energy costs', required: false })
  @IsOptional()
  @IsString()
  description?: string;
}
