import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  ParseIntPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam } from '@nestjs/swagger';
import { UserAssignedRolesService } from './user-assigned-roles.service';
import { CreateUserAssignedRoleDto, UpdateUserAssignedRoleDto } from './dto';
import { UserAssignedRoles } from '../../entities/UserAssignedRoles.entity';

@ApiTags('user-assigned-roles')
@Controller('user-assigned-roles')
export class UserAssignedRolesController {
  constructor(private readonly service: UserAssignedRolesService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new user assigned role' })
  @ApiResponse({ status: 201, description: 'User Assigned Role created successfully', type: UserAssignedRole })
  create(@Body() createDto: CreateUserAssignedRoleDto): Promise<UserAssignedRoles> {
    return this.service.create(createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all user-assigned-roles' })
  @ApiResponse({ status: 200, description: 'List of user-assigned-roles', type: [UserAssignedRole] })
  findAll(): Promise<UserAssignedRole[]> {
    return this.service.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a user assigned role by ID' })
  @ApiParam({ name: 'id', description: 'User Assigned Role ID' })
  @ApiResponse({ status: 200, description: 'User Assigned Role found', type: UserAssignedRole })
  @ApiResponse({ status: 404, description: 'User Assigned Role not found' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<UserAssignedRoles> {
    return this.service.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a user assigned role' })
  @ApiParam({ name: 'id', description: 'User Assigned Role ID' })
  @ApiResponse({ status: 200, description: 'User Assigned Role updated successfully', type: UserAssignedRole })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateUserAssignedRoleDto,
  ): Promise<UserAssignedRoles> {
    return this.service.update(id, updateDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a user assigned role' })
  @ApiParam({ name: 'id', description: 'User Assigned Role ID' })
  @ApiResponse({ status: 204, description: 'User Assigned Role deleted successfully' })
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.service.remove(id);
  }
}
