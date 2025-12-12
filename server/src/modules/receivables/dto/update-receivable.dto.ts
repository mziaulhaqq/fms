import { PartialType, ApiProperty } from '@nestjs/swagger';
import { CreateReceivableDto } from './create-receivable.dto';
import { IsEnum, IsNumber, IsOptional } from 'class-validator';

export class UpdateReceivableDto extends PartialType(CreateReceivableDto) {
  @ApiProperty({ 
    description: 'Receivable status', 
    enum: ['Pending', 'Partially Paid', 'Fully Paid'],
    required: false 
  })
  @IsOptional()
  @IsEnum(['Pending', 'Partially Paid', 'Fully Paid'])
  status?: 'Pending' | 'Partially Paid' | 'Fully Paid';

  @ApiProperty({ description: 'Remaining balance', required: false })
  @IsOptional()
  @IsNumber()
  remainingBalance?: number;
}
