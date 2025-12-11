import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsInt } from 'class-validator';

export class CreateMiningSiteDto {
  @ApiProperty({ description: 'Name of the mining site', example: 'Site 1' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ description: 'Location of the mining site', example: 'Tharparkar, Sindh' })
  @IsString()
  @IsNotEmpty()
  location: string;

  @ApiProperty({ description: 'Description of the mining site', required: false })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({ description: 'Lease ID associated with this site', required: false })
  @IsInt()
  @IsOptional()
  leaseId?: number;

  @ApiProperty({ description: 'Active status', default: true })
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;
}
