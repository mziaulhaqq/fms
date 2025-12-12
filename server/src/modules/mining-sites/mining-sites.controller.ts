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
import { CurrentUserId } from '../../common/decorators/current-user.decorator';
import { MiningSitesService } from './mining-sites.service';
import { CreateMiningSiteDto, UpdateMiningSiteDto } from './dto';
import { MiningSites } from '../../entities/MiningSites.entity';
import { Roles } from '../auth/decorators/roles.decorator';
import { RolesGuard } from '../auth/guards/roles.guard';

@ApiTags('mining-sites')
@ApiBearerAuth()
@Controller('mining-sites')
@UseGuards(RolesGuard)
@Roles('admin')
export class MiningSitesController {
  constructor(private readonly service: MiningSitesService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new mining site (Admin only)' })
  @ApiResponse({ status: 201, description: 'Mining Site created successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  create(@Body() createDto: CreateMiningSiteDto, @CurrentUserId() userId: number): Promise<MiningSites> {
    return this.service.create(createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all mining-sites' })
  @ApiResponse({ status: 200, description: 'List of mining-sites' })
  findAll(): Promise<MiningSites[]> {
    return this.service.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a mining site by ID' })
  @ApiParam({ name: 'id', description: 'Mining Site ID' })
  @ApiResponse({ status: 200, description: 'Mining Site found' })
  @ApiResponse({ status: 404, description: 'Mining Site not found' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<MiningSites> {
    return this.service.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a mining site' })
  @ApiParam({ name: 'id', description: 'Mining Site ID' })
  @ApiResponse({ status: 200, description: 'Mining Site updated successfully' })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateMiningSiteDto,
  ): Promise<MiningSites> {
    return this.service.update(id, updateDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a mining site' })
  @ApiParam({ name: 'id', description: 'Mining Site ID' })
  @ApiResponse({ status: 204, description: 'Mining Site deleted successfully' })
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.service.remove(id);
  }
}
