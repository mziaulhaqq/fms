import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsEnum, IsDateString, IsArray } from 'class-validator';

export class CreateLiabilityDto {
  @ApiProperty({ description: 'Liability type', enum: ['Loan', 'Advanced Payment'] })
  @IsEnum(['Loan', 'Advanced Payment'])
  type: 'Loan' | 'Advanced Payment';

  @ApiProperty({ description: 'Client ID (FK to clients)' })
  @IsNumber()
  clientId: number;

  @ApiProperty({ description: 'Mining site ID (FK to mining_sites)' })
  @IsNumber()
  miningSiteId: number;

  @ApiProperty({ description: 'Liability date', example: '2025-12-11' })
  @IsDateString()
  date: string;

  @ApiProperty({ description: 'Description', required: false })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ description: 'Total amount', example: 50000 })
  @IsNumber()
  totalAmount: number;

  @ApiProperty({ description: 'Proof file paths', required: false, type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  proof?: string[];
}
