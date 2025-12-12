import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { CurrentUserId } from '../../common/decorators/current-user.decorator';
import { EquipmentService } from './equipment.service';
import { CreateEquipmentDto } from './dto/create-equipment.dto';
import { UpdateEquipmentDto } from './dto/update-equipment.dto';
import { Equipment } from '../../entities/Equipment.entity';

@ApiTags('equipment')
@Controller('equipment')
export class EquipmentController {
  constructor(private readonly equipmentService: EquipmentService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new equipment' })
  @ApiResponse({ status: 201, description: 'Equipment created successfully', type: Equipment })
  create(@Body() createDto: CreateEquipmentDto, @CurrentUserId() userId: number): Promise<Equipment> {
    return this.equipmentService.create(createDto, userId);
  }

  @Get()
  @ApiOperation({ summary: 'Get all equipment' })
  @ApiResponse({ status: 200, description: 'List of all equipment', type: [Equipment] })
  findAll(): Promise<Equipment[]> {
    return this.equipmentService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get equipment by ID' })
  @ApiResponse({ status: 200, description: 'Equipment found', type: Equipment })
  @ApiResponse({ status: 404, description: 'Equipment not found' })
  findOne(@Param('id') id: string): Promise<Equipment> {
    return this.equipmentService.findOne(+id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update equipment' })
  @ApiResponse({ status: 200, description: 'Equipment updated successfully', type: Equipment })
  @ApiResponse({ status: 404, description: 'Equipment not found' })
  update(
    @Param('id') id: string,
    @Body() updateEquipmentDto: UpdateEquipmentDto,
    @CurrentUserId() userId: number,
  ): Promise<Equipment> {
    return this.equipmentService.update(+id, updateEquipmentDto, userId);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete equipment' })
  @ApiResponse({ status: 204, description: 'Equipment deleted successfully' })
  @ApiResponse({ status: 404, description: 'Equipment not found' })
  remove(@Param('id') id: string): Promise<void> {
    return this.equipmentService.remove(+id);
  }
}
