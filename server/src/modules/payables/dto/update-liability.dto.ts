import { PartialType, ApiProperty } from '@nestjs/swagger';
import { CreateLiabilityDto } from './create-liability.dto';
import { IsEnum, IsNumber, IsOptional } from 'class-validator';

export class UpdateLiabilityDto extends PartialType(CreateLiabilityDto) {
  @ApiProperty({ 
    description: 'Payable status', 
    enum: ['Active', 'Partially Used', 'Fully Used'],
    required: false 
  })
  @IsOptional()
  @IsEnum(['Active', 'Partially Used', 'Fully Used'])
  status?: 'Active' | 'Partially Used' | 'Fully Used';

  @ApiProperty({ description: 'Remaining balance', required: false })
  @IsOptional()
  @IsNumber()
  remainingBalance?: number;
}
