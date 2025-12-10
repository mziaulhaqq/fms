import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsNumber, IsString, IsOptional, IsDateString, IsArray } from 'class-validator';

export class CreateExpenseDto {
  @ApiProperty({ description: 'Site ID', example: 1 })
  @IsNotEmpty()
  @IsNumber()
  siteId: number;

  @ApiProperty({ description: 'Category ID', example: 1, required: false })
  @IsOptional()
  @IsNumber()
  categoryId?: number;

  @ApiProperty({ description: 'Expense date', example: '2024-11-02' })
  @IsNotEmpty()
  @IsDateString()
  expenseDate: string;

  @ApiProperty({ description: 'Amount', example: 25000.0 })
  @IsNotEmpty()
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
  @IsNumber()
  laborCostId?: number;

  @ApiProperty({ description: 'Partner ID', required: false })
  @IsOptional()
  @IsNumber()
  partnerId?: number;
}
