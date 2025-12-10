import { ApiProperty } from '@nestjs/swagger';
import { IsInt, IsString, IsOptional } from 'class-validator';

export class CreateUserAssignedRoleDto {
  @ApiProperty({ example: 1, description: 'User ID' })
  @IsInt()
  userId: number;

  @ApiProperty({ example: 1, description: 'Role ID' })
  @IsInt()
  roleId: number;

  @ApiProperty({ example: 'active', description: 'Status of the role assignment', required: false })
  @IsString()
  @IsOptional()
  status?: string;

  @ApiProperty({ example: 'Initial role assignment', description: 'Comment about the assignment', required: false })
  @IsString()
  @IsOptional()
  updatedComment?: string;
}
