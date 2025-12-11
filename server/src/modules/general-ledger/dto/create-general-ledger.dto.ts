import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsBoolean, IsNumber, MaxLength } from 'class-validator';

export class CreateGeneralLedgerDto {
  @ApiProperty({ description: 'Account code', example: '1010' })
  @IsString()
  @MaxLength(50)
  accountCode: string;

  @ApiProperty({ description: 'Account name', example: 'Cash in Hand' })
  @IsString()
  @MaxLength(255)
  accountName: string;

  @ApiProperty({ description: 'Account type ID (FK to account_types)' })
  @IsNumber()
  accountTypeId: number;

  @ApiProperty({ description: 'Mining site ID (FK to mining_sites)' })
  @IsNumber()
  miningSiteId: number;

  @ApiProperty({ description: 'Account description', required: false })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ description: 'Is active', default: true, required: false })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
