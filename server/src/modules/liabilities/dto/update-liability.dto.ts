import { PartialType, ApiProperty } from '@nestjs/swagger';
import { CreateLiabilityDto } from './create-liability.dto';
import { IsEnum, IsNumber, IsOptional } from 'class-validator';

export class UpdateLiabilityDto extends PartialType(CreateLiabilityDto) {
  @ApiProperty({ 
    description: 'Liability status', 
    enum: ['Active', 'Partially Settled', 'Fully Settled'],
    required: false 
  })
  @IsOptional()
  @IsEnum(['Active', 'Partially Settled', 'Fully Settled'])
  status?: 'Active' | 'Partially Settled' | 'Fully Settled';

  @ApiProperty({ description: 'Remaining balance', required: false })
  @IsOptional()
  @IsNumber()
  remainingBalance?: number;
}
