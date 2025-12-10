import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsDateString, IsNotEmpty } from 'class-validator';

export class CreateProductionDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsDateString()
  date: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsNumber()
  siteId: number;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  quantity: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  quality?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  shift?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  notes?: string;
}
