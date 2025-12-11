import { IsString, IsOptional, MaxLength, IsBoolean, IsNumber } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class CreateClientDto {
  @ApiProperty({ description: 'Mining site ID', required: false, example: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  siteId?: number;

  @ApiProperty({ description: 'Client type ID', required: false, example: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  clientTypeId?: number;

  @ApiProperty({ description: 'Business name', example: 'ABC Mining Corp' })
  @IsString()
  @MaxLength(255)
  businessName: string;

  @ApiProperty({ description: 'Owner name', example: 'John Doe' })
  @IsString()
  @MaxLength(255)
  ownerName: string;

  @ApiProperty({ description: 'Address', required: false })
  @IsOptional()
  @IsString()
  address?: string;

  @ApiProperty({ description: 'Owner contact', required: false, example: '+1234567890' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  ownerContact?: string;

  @ApiProperty({ description: 'Munshi name', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  munshiName?: string;

  @ApiProperty({ description: 'Munshi contact', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  munshiContact?: string;

  @ApiProperty({ description: 'Description', required: false })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ description: 'Onboarding date', required: false, example: '2024-01-15' })
  @IsOptional()
  @IsString()
  onboardingDate?: string;

  @ApiProperty({ description: 'Is active', required: false, default: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @ApiProperty({ description: 'Document files', required: false, type: [String] })
  @IsOptional()
  documentFiles?: string[];
}
