import { IsString, IsEmail, IsOptional, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateClientDto {
  @ApiProperty({ description: 'Client name', example: 'ABC Mining Corp' })
  @IsString()
  @MaxLength(255)
  name: string;

  @ApiProperty({ description: 'Client email', required: false, example: 'contact@abcmining.com' })
  @IsOptional()
  @IsEmail()
  @MaxLength(255)
  email?: string;

  @ApiProperty({ description: 'Client phone', required: false, example: '+1234567890' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  phone?: string;

  @ApiProperty({ description: 'Client address', required: false })
  @IsOptional()
  @IsString()
  address?: string;

  @ApiProperty({ description: 'Client type', required: false, example: 'corporate' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  type?: string;
}
