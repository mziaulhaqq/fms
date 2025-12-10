import { PartialType } from '@nestjs/swagger';
import { CreateUserAssignedRoleDto } from './create-user-assigned-roles.dto';

export class UpdateUserAssignedRoleDto extends PartialType(CreateUserAssignedRoleDto) {}
