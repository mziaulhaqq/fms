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
import { SiteSupervisorsService } from './site-supervisors.service';
import { CreateSiteSupervisorDto, UpdateSiteSupervisorDto } from './dto';
import { SiteSupervisors } from '../../entities/SiteSupervisors.entity';

@ApiTags('site-supervisors')
@Controller('site-supervisors')
export class SiteSupervisorsController {
  constructor(private readonly service: SiteSupervisorsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new site supervisor' })
  @ApiResponse({ status: 201, description: 'Site Supervisor created successfully', type: SiteSupervisor })
  create(@Body() createDto: CreateSiteSupervisorDto): Promise<SiteSupervisors> {
    return this.service.create(createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all site-supervisors' })
  @ApiResponse({ status: 200, description: 'List of site-supervisors', type: [SiteSupervisor] })
  findAll(): Promise<SiteSupervisor[]> {
    return this.service.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a site supervisor by ID' })
  @ApiParam({ name: 'id', description: 'Site Supervisor ID' })
  @ApiResponse({ status: 200, description: 'Site Supervisor found', type: SiteSupervisor })
  @ApiResponse({ status: 404, description: 'Site Supervisor not found' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<SiteSupervisors> {
    return this.service.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a site supervisor' })
  @ApiParam({ name: 'id', description: 'Site Supervisor ID' })
  @ApiResponse({ status: 200, description: 'Site Supervisor updated successfully', type: SiteSupervisor })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateSiteSupervisorDto,
  ): Promise<SiteSupervisors> {
    return this.service.update(id, updateDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a site supervisor' })
  @ApiParam({ name: 'id', description: 'Site Supervisor ID' })
  @ApiResponse({ status: 204, description: 'Site Supervisor deleted successfully' })
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.service.remove(id);
  }
}
