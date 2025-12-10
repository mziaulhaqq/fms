import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, IsNumber, IsBoolean, IsDateString } from 'class-validator';

export class CreateLaborDto {
  @ApiProperty({ description: 'Full name of the worker' })
  @IsString()
  fullName: string;

  @ApiPropertyOptional({ description: 'Employee ID / CNIC' })
  @IsOptional()
  @IsString()
  employeeId?: string;

  @ApiPropertyOptional({ description: 'Job role' })
  @IsOptional()
  @IsString()
  role?: string;

  @ApiPropertyOptional({ description: 'Team name' })
  @IsOptional()
  @IsString()
  team?: string;

  @ApiPropertyOptional({ description: 'Phone number' })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiPropertyOptional({ description: 'Email address' })
  @IsOptional()
  @IsString()
  email?: string;

  @ApiPropertyOptional({ description: 'Employment status', default: 'active' })
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional({ description: 'Is worker active', default: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @ApiPropertyOptional({ description: 'Hire/onboarding date' })
  @IsOptional()
  @IsString()
  hireDate?: string;

  @ApiPropertyOptional({ description: 'Photo URL' })
  @IsOptional()
  @IsString()
  photoUrl?: string;

  @ApiPropertyOptional({ description: 'Supervisor ID' })
  @IsOptional()
  @IsNumber()
  supervisorId?: number;

  @ApiPropertyOptional({ description: 'Father name' })
  @IsOptional()
  @IsString()
  fatherName?: string;

  @ApiPropertyOptional({ description: 'Address' })
  @IsOptional()
  @IsString()
  address?: string;

  @ApiPropertyOptional({ description: 'Mobile number' })
  @IsOptional()
  @IsString()
  mobileNumber?: string;

  @ApiPropertyOptional({ description: 'Emergency contact number' })
  @IsOptional()
  @IsString()
  emergencyNumber?: string;

  @ApiPropertyOptional({ description: 'Start date of employment' })
  @IsOptional()
  @IsString()
  startDate?: string;

  @ApiPropertyOptional({ description: 'End date of employment' })
  @IsOptional()
  @IsString()
  endDate?: string;

  @ApiPropertyOptional({ description: 'Daily wage amount' })
  @IsOptional()
  @IsNumber()
  dailyWage?: number;

  @ApiPropertyOptional({ description: 'Additional notes' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({ description: 'Other details' })
  @IsOptional()
  @IsString()
  otherDetail?: string;
}
