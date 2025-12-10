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
import { UserRolesService } from './user-roles.service';
import { CreateUserRoleDto, UpdateUserRoleDto } from './dto';
import { UserRoles } from '../../entities/UserRoles.entity';
import { Public } from '../auth/decorators/public.decorator';

@ApiTags('user-roles')
@Controller('user-roles')
export class UserRolesController {
  constructor(private readonly service: UserRolesService) {}

  @Public() // Temporary - for initial setup
  @Post()
  @ApiOperation({ summary: 'Create a new user role' })
  @ApiResponse({ status: 201, description: 'User Role created successfully' })
  create(@Body() createDto: CreateUserRoleDto): Promise<UserRoles> {
    return this.service.create(createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all user-roles' })
  @ApiResponse({ status: 200, description: 'List of user-roles' })
  findAll(): Promise<UserRoles[]> {
    return this.service.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a user role by ID' })
  @ApiParam({ name: 'id', description: 'User Role ID' })
  @ApiResponse({ status: 200, description: 'User Role found' })
  @ApiResponse({ status: 404, description: 'User Role not found' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<UserRoles> {
    return this.service.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a user role' })
  @ApiParam({ name: 'id', description: 'User Role ID' })
  @ApiResponse({ status: 200, description: 'User Role updated successfully' })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateUserRoleDto,
  ): Promise<UserRoles> {
    return this.service.update(id, updateDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a user role' })
  @ApiParam({ name: 'id', description: 'User Role ID' })
  @ApiResponse({ status: 204, description: 'User Role deleted successfully' })
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.service.remove(id);
  }
}
