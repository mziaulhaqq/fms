import { PartialType } from '@nestjs/mapped-types';
import { CreateUserAssignedRoleDto } from './create-user-assigned-roles.dto';

export class UpdateUserAssignedRoleDto extends PartialType(CreateUserAssignedRoleDto) {}
