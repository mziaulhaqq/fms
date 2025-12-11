import { ApiProperty } from '@nestjs/swagger';
import { IsDateString, IsEnum, IsNumber, IsOptional, IsString } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateProfitDistributionDto {
  @ApiProperty({ description: 'Mining site ID', required: false, example: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  siteId?: number;

  @ApiProperty({ description: 'Period start date', example: '2024-01-01' })
  @IsDateString()
  periodStart: string;

  @ApiProperty({ description: 'Period end date', example: '2024-01-31' })
  @IsDateString()
  periodEnd: string;

  @ApiProperty({ description: 'Total revenue', example: 500000.00 })
  @IsNumber()
  @Type(() => Number)
  totalRevenue: number;

  @ApiProperty({ description: 'Total expenses', example: 300000.00 })
  @IsNumber()
  @Type(() => Number)
  totalExpenses: number;

  @ApiProperty({ description: 'Total profit', example: 200000.00 })
  @IsNumber()
  @Type(() => Number)
  totalProfit: number;

  @ApiProperty({ description: 'Status', enum: ['pending', 'approved', 'rejected'], default: 'pending' })
  @IsOptional()
  @IsEnum(['pending', 'approved', 'rejected'])
  status?: 'pending' | 'approved' | 'rejected';

  @ApiProperty({ description: 'Notes', required: false })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiProperty({ description: 'Approved by user ID', required: false })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  approvedBy?: number;
}
