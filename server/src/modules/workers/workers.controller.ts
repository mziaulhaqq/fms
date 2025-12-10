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
import { LaborsService } from './workers.service';
import { CreateLaborDto, UpdateLaborDto } from './dto';
import { Labor } from '../../entities/Labor.entity';

@ApiTags('workers')
@Controller('workers')
export class LaborsController {
  constructor(private readonly service: LaborsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new worker' })
  @ApiResponse({ status: 201, description: 'Worker created successfully', type: Labor })
  create(@Body() createDto: CreateLaborDto): Promise<Labor> {
    return this.service.create(createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all workers' })
  @ApiResponse({ status: 200, description: 'List of workers', type: [Labor] })
  findAll(): Promise<Labor[]> {
    return this.service.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a worker by ID' })
  @ApiParam({ name: 'id', description: 'Worker ID' })
  @ApiResponse({ status: 200, description: 'Worker found', type: Labor })
  @ApiResponse({ status: 404, description: 'Worker not found' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<Labor> {
    return this.service.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a worker' })
  @ApiParam({ name: 'id', description: 'Worker ID' })
  @ApiResponse({ status: 200, description: 'Worker updated successfully', type: Labor })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateLaborDto,
  ): Promise<Labor> {
    return this.service.update(id, updateDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a worker' })
  @ApiParam({ name: 'id', description: 'Worker ID' })
  @ApiResponse({ status: 204, description: 'Worker deleted successfully' })
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.service.remove(id);
  }
}
