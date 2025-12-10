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
import { EquipmentsService } from './equipment.service';
import { CreateEquipmentDto, UpdateEquipmentDto } from './dto';
import { Equipment } from '../../entities/equipment.entity';

@ApiTags('equipment')
@Controller('equipment')
export class EquipmentsController {
  constructor(private readonly service: EquipmentsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new equipment' })
  @ApiResponse({ status: 201, description: 'Equipment created successfully' })
  create(@Body() createDto: CreateEquipmentDto): Promise<Equipment> {
    return this.service.create(createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all equipment' })
  @ApiResponse({ status: 200, description: 'List of equipment' })
  findAll(): Promise<Equipment[]> {
    return this.service.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a equipment by ID' })
  @ApiParam({ name: 'id', description: 'Equipment ID' })
  @ApiResponse({ status: 200, description: 'Equipment found' })
  @ApiResponse({ status: 404, description: 'Equipment not found' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<Equipment> {
    return this.service.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a equipment' })
  @ApiParam({ name: 'id', description: 'Equipment ID' })
  @ApiResponse({ status: 200, description: 'Equipment updated successfully' })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateEquipmentDto,
  ): Promise<Equipment> {
    return this.service.update(id, updateDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a equipment' })
  @ApiParam({ name: 'id', description: 'Equipment ID' })
  @ApiResponse({ status: 204, description: 'Equipment deleted successfully' })
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.service.remove(id);
  }
}
