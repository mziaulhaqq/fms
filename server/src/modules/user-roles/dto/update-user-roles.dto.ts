import { PartialType } from '@nestjs/swagger';
import { CreateUserRoleDto } from './create-user-roles.dto';

export class UpdateUserRoleDto extends PartialType(CreateUserRoleDto) {}
