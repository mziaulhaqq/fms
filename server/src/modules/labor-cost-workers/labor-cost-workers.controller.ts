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
import { LaborCostWorkersService } from './labor-cost-workers.service';
import { CreateLaborCostWorkerDto, UpdateLaborCostWorkerDto } from './dto';
import { LaborCostWorkers } from '../../entities/LaborCostWorkers.entity';

@ApiTags('labor-cost-workers')
@Controller('labor-cost-workers')
export class LaborCostWorkersController {
  constructor(private readonly service: LaborCostWorkersService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new labor cost worker' })
  @ApiResponse({ status: 201, description: 'Labor Cost Worker created successfully' })
  create(@Body() createDto: CreateLaborCostWorkerDto): Promise<LaborCostWorkers> {
    return this.service.create(createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all labor-cost-workers' })
  @ApiResponse({ status: 200, description: 'List of labor-cost-workers' })
  findAll(): Promise<LaborCostWorkers[]> {
    return this.service.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a labor cost worker by ID' })
  @ApiParam({ name: 'id', description: 'Labor Cost Worker ID' })
  @ApiResponse({ status: 200, description: 'Labor Cost Worker found' })
  @ApiResponse({ status: 404, description: 'Labor Cost Worker not found' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<LaborCostWorkers> {
    return this.service.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a labor cost worker' })
  @ApiParam({ name: 'id', description: 'Labor Cost Worker ID' })
  @ApiResponse({ status: 200, description: 'Labor Cost Worker updated successfully' })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateLaborCostWorkerDto,
  ): Promise<LaborCostWorkers> {
    return this.service.update(id, updateDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a labor cost worker' })
  @ApiParam({ name: 'id', description: 'Labor Cost Worker ID' })
  @ApiResponse({ status: 204, description: 'Labor Cost Worker deleted successfully' })
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.service.remove(id);
  }
}
