import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsBoolean, MaxLength } from 'class-validator';

export class CreateLeaseDto {
  @ApiProperty({ description: 'Lease name', example: 'Main Coal Lease' })
  @IsString()
  @MaxLength(255)
  leaseName: string;

  @ApiProperty({ description: 'Lease location', required: false })
  @IsOptional()
  @IsString()
  location?: string;

  @ApiProperty({ description: 'Is active', default: true, required: false })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
