import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsNumber, IsString, IsOptional, IsDateString, IsArray } from 'class-validator';
import { Transform, Type } from 'class-transformer';

export class CreateExpenseDto {
  @ApiProperty({ description: 'Site ID', example: 1 })
  @IsNotEmpty()
  @Type(() => Number)
  @IsNumber()
  siteId: number;

  @ApiProperty({ description: 'Expense type ID', example: 1, required: false })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  expenseTypeId?: number;

  @ApiProperty({ description: 'Category ID', example: 1, required: false })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  categoryId?: number;

  @ApiProperty({ description: 'Expense date', example: '2024-11-02' })
  @IsNotEmpty()
  @IsDateString()
  expenseDate: string;

  @ApiProperty({ description: 'Amount', example: 25000.0 })
  @IsNotEmpty()
  @Type(() => Number)
  @IsNumber()
  amount: number;

  @ApiProperty({ description: 'Notes', required: false })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiProperty({ description: 'Evidence photos', type: [String], required: false })
  @IsOptional()
  @IsArray()
  evidencePhotos?: string[];

  @ApiProperty({ description: 'Labor cost ID', required: false })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  laborCostId?: number;

  @ApiProperty({ description: 'Partner ID', required: false })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  partnerId?: number;
}
