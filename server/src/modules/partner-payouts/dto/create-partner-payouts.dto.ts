import { ApiProperty } from '@nestjs/swagger';
import { IsNumber, IsOptional } from 'class-validator';
import { Type } from 'class-transformer';

export class CreatePartnerPayoutDto {
  @ApiProperty({ description: 'Mining site ID', required: false, example: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  siteId?: number;

  @ApiProperty({ description: 'Profit distribution ID', example: 1 })
  @IsNumber()
  @Type(() => Number)
  distributionId: number;

  @ApiProperty({ description: 'Partner ID', example: 1 })
  @IsNumber()
  @Type(() => Number)
  partnerId: number;

  @ApiProperty({ description: 'Share percentage (0-100)', example: 25.50 })
  @IsNumber()
  @Type(() => Number)
  sharePercentage: number;

  @ApiProperty({ description: 'Payout amount', example: 50000.00 })
  @IsNumber()
  @Type(() => Number)
  payoutAmount: number;
}
