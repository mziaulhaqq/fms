import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsNumber, IsString, IsOptional, IsEnum, IsDateString } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateIncomeDto {
  @ApiProperty({ description: 'Mining site ID' })
  @IsNotEmpty()
  @IsNumber()
  @Type(() => Number)
  siteId: number;

  @ApiPropertyOptional({ description: 'Client ID' })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  clientId?: number;

  @ApiProperty({ description: 'Truck number' })
  @IsNotEmpty()
  @IsString()
  truckNumber: string;

  @ApiProperty({ description: 'Loading date' })
  @IsNotEmpty()
  @IsDateString()
  loadingDate: string;

  @ApiProperty({ description: 'Driver name' })
  @IsNotEmpty()
  @IsString()
  driverName: string;

  @ApiPropertyOptional({ description: 'Driver phone' })
  @IsOptional()
  @IsString()
  driverPhone?: string;

  @ApiProperty({ description: 'Coal price per ton' })
  @IsNotEmpty()
  coalPrice: string | number;

  @ApiPropertyOptional({ description: 'Company commission' })
  @IsOptional()
  companyCommission?: string | number;

  @ApiPropertyOptional({ description: 'Buyer name' })
  @IsOptional()
  @IsString()
  buyerName?: string;

  @ApiPropertyOptional({ description: 'Vehicle number' })
  @IsOptional()
  @IsString()
  vehicleNumber?: string;

  @ApiPropertyOptional({ description: 'Quantity in tons' })
  @IsOptional()
  quantityTons?: string | number;

  @ApiPropertyOptional({ description: 'Total price' })
  @IsOptional()
  totalPrice?: string | number;

  @ApiPropertyOptional({ description: 'Status', enum: ['draft', 'completed'], default: 'draft' })
  @IsOptional()
  @IsEnum(['draft', 'completed'])
  status?: 'draft' | 'completed';

  @ApiPropertyOptional({ description: 'Evidence photos URLs', type: [String] })
  @IsOptional()
  evidencePhotos?: string[];

  @ApiPropertyOptional({ description: 'Description' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ description: 'Notes' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({ description: 'Amount from liability' })
  @IsOptional()
  amountFromLiability?: string | number;

  @ApiPropertyOptional({ description: 'Amount paid in cash' })
  @IsOptional()
  amountCash?: string | number;

  @ApiPropertyOptional({ description: 'Liability ID' })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  liabilityId?: number;
}
