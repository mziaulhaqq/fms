import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsNumber, IsString, IsDateString, IsOptional, IsArray, IsEnum } from 'class-validator';

export class CreatePaymentDto {
  @ApiProperty({ description: 'Client ID' })
  @IsNotEmpty()
  @IsNumber()
  clientId: number;

  @ApiProperty({ description: 'Mining site ID' })
  @IsNotEmpty()
  @IsNumber()
  miningSiteId: number;

  @ApiProperty({ 
    description: 'Payment type', 
    enum: ['Payable Deduction', 'Receivable Payment'] 
  })
  @IsNotEmpty()
  @IsEnum(['Payable Deduction', 'Receivable Payment'])
  paymentType: 'Payable Deduction' | 'Receivable Payment';

  @ApiProperty({ description: 'Payment amount' })
  @IsNotEmpty()
  @IsNumber()
  amount: number;

  @ApiProperty({ description: 'Payment date' })
  @IsNotEmpty()
  @IsDateString()
  paymentDate: string;

  @ApiProperty({ description: 'Payment method (Cash, Bank Transfer, etc.)', required: false })
  @IsOptional()
  @IsString()
  paymentMethod?: string;

  @ApiProperty({ description: 'Proof documents/receipts', type: [String], required: false })
  @IsOptional()
  @IsArray()
  proof?: string[];

  @ApiProperty({ description: 'Received by (person name)', required: false })
  @IsOptional()
  @IsString()
  receivedBy?: string;

  @ApiProperty({ description: 'Additional notes', required: false })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiProperty({ description: 'Payable ID (if paymentType is Payable Deduction)', required: false })
  @IsOptional()
  @IsNumber()
  payableId?: number;

  @ApiProperty({ description: 'Receivable ID (if paymentType is Receivable Payment)', required: false })
  @IsOptional()
  @IsNumber()
  receivableId?: number;
}
