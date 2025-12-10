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
import { LaborCostsService } from './labor-costs.service';
import { CreateLaborCostDto, UpdateLaborCostDto } from './dto';
import { LaborCost } from '../../entities/labor-cost.entity';

@ApiTags('labor-costs')
@Controller('labor-costs')
export class LaborCostsController {
  constructor(private readonly service: LaborCostsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new labor cost' })
  @ApiResponse({ status: 201, description: 'Labor Cost created successfully', type: LaborCost })
  create(@Body() createDto: CreateLaborCostDto): Promise<LaborCost> {
    return this.service.create(createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all labor-costs' })
  @ApiResponse({ status: 200, description: 'List of labor-costs', type: [LaborCost] })
  findAll(): Promise<LaborCost[]> {
    return this.service.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a labor cost by ID' })
  @ApiParam({ name: 'id', description: 'Labor Cost ID' })
  @ApiResponse({ status: 200, description: 'Labor Cost found', type: LaborCost })
  @ApiResponse({ status: 404, description: 'Labor Cost not found' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<LaborCost> {
    return this.service.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a labor cost' })
  @ApiParam({ name: 'id', description: 'Labor Cost ID' })
  @ApiResponse({ status: 200, description: 'Labor Cost updated successfully', type: LaborCost })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateLaborCostDto,
  ): Promise<LaborCost> {
    return this.service.update(id, updateDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a labor cost' })
  @ApiParam({ name: 'id', description: 'Labor Cost ID' })
  @ApiResponse({ status: 204, description: 'Labor Cost deleted successfully' })
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.service.remove(id);
  }
}
