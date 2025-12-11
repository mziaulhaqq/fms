import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsBoolean, MaxLength } from 'class-validator';
import { Type } from 'class-transformer';

export class CreatePartnerDto {
  @ApiProperty({ description: 'Partner name', example: 'John Doe' })
  @IsString()
  @MaxLength(255)
  name: string;

  @ApiProperty({ description: 'CNIC number', example: '12345-1234567-1' })
  @IsString()
  @MaxLength(20)
  cnic: string;

  @ApiProperty({ description: 'Email address', required: false, example: 'john@example.com' })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  email?: string;

  @ApiProperty({ description: 'Phone number', required: false, example: '+1234567890' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  phone?: string;

  @ApiProperty({ description: 'Share percentage', required: false, example: 25.5 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  sharePercentage?: number;

  @ApiProperty({ description: 'Address', required: false })
  @IsOptional()
  @IsString()
  address?: string;

  @ApiProperty({ description: 'Lease ID', required: false, example: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  leaseId?: number;

  @ApiProperty({ description: 'Mining Site ID', required: false, example: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  miningSiteId?: number;

  @ApiProperty({ description: 'Is active', required: false, default: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
