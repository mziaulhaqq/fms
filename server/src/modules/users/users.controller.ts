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
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { CreateUserDto, UpdateUserDto } from './dto';
import { Users } from '../../entities/Users.entity';
import { Public } from '../auth/decorators/public.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { RolesGuard } from '../auth/guards/roles.guard';

@ApiTags('users')
@ApiBearerAuth()
@Controller('users')
@UseGuards(RolesGuard)
export class UsersController {
  constructor(private readonly service: UsersService) {}

  @Public() // Allow public access to create the first user
  @Post()
  @ApiOperation({ summary: 'Create a new user' })
  @ApiResponse({ status: 201, description: 'User created successfully' })
  create(@Body() createDto: CreateUserDto): Promise<Users> {
    return this.service.create(createDto);
  }

  @Roles('admin')
  @Get()
  @ApiOperation({ summary: 'Get all users (Admin only)' })
  @ApiResponse({ status: 200, description: 'List of users' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  findAll(): Promise<Users[]> {
    return this.service.findAll();
  }

  @Roles('admin')
  @Get(':id')
  @ApiOperation({ summary: 'Get a user by ID (Admin only)' })
  @ApiParam({ name: 'id', description: 'User ID' })
  @ApiResponse({ status: 200, description: 'User found' })
  @ApiResponse({ status: 404, description: 'User not found' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<Users> {
    return this.service.findOne(id);
  }

  @Roles('admin')
  @Patch(':id')
  @ApiOperation({ summary: 'Update a user (Admin only)' })
  @ApiParam({ name: 'id', description: 'User ID' })
  @ApiResponse({ status: 200, description: 'User updated successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateUserDto,
  ): Promise<Users> {
    return this.service.update(id, updateDto);
  }

  @Roles('admin')
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a user (Admin only)' })
  @ApiParam({ name: 'id', description: 'User ID' })
  @ApiResponse({ status: 204, description: 'User deleted successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.service.remove(id);
  }

  @Roles('admin')
  @Patch(':id/toggle-status')
  @ApiOperation({ summary: 'Toggle user active status (Admin only)' })
  @ApiParam({ name: 'id', description: 'User ID' })
  @ApiResponse({ status: 200, description: 'User status toggled successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  toggleStatus(@Param('id', ParseIntPipe) id: number): Promise<Users> {
    return this.service.toggleUserStatus(id);
  }
}
