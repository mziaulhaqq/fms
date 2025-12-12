import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsNumber, IsString, IsDateString, IsOptional, IsArray } from 'class-validator';

export class CreateReceivableDto {
  @ApiProperty({ description: 'Client ID' })
  @IsNotEmpty()
  @IsNumber()
  clientId: number;

  @ApiProperty({ description: 'Mining site ID' })
  @IsNotEmpty()
  @IsNumber()
  miningSiteId: number;

  @ApiProperty({ description: 'Receivable date' })
  @IsNotEmpty()
  @IsDateString()
  date: string;

  @ApiProperty({ description: 'Description', required: false })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ description: 'Total amount client owes' })
  @IsNotEmpty()
  @IsNumber()
  totalAmount: number;

  @ApiProperty({ description: 'Proof documents', type: [String], required: false })
  @IsOptional()
  @IsArray()
  proof?: string[];
}
