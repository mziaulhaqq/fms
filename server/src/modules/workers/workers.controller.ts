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
import { CurrentUserId } from '../../common/decorators/current-user.decorator';
import { LaborsService } from './workers.service';
import { CreateLaborDto, UpdateLaborDto } from './dto';

@ApiTags('workers')
@Controller('workers')
export class LaborsController {
  constructor(private readonly service: LaborsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new worker' })
  @ApiResponse({ status: 201, description: 'Worker created successfully' })
  create(@Body() createDto: CreateLaborDto): Promise<any> {
    return this.service.create(createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all workers' })
  @ApiResponse({ status: 200, description: 'List of workers' })
  findAll(): Promise<any[]> {
    return this.service.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a worker by ID' })
  @ApiParam({ name: 'id', description: 'Worker ID' })
  @ApiResponse({ status: 200, description: 'Worker found' })
  @ApiResponse({ status: 404, description: 'Worker not found' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<any> {
    return this.service.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a worker' })
  @ApiParam({ name: 'id', description: 'Worker ID' })
  @ApiResponse({ status: 200, description: 'Worker updated successfully' })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateLaborDto,
  ): Promise<any> {
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
