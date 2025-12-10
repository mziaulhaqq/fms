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
import { ProductionService } from './production.service';
import { CreateProductionDto } from './dto/create-production.dto';
import { UpdateProductionDto } from './dto/update-production.dto';
import { Production } from '../../entities/Production.entity';

@ApiTags('production')
@Controller('production')
export class ProductionController {
  constructor(private readonly productionService: ProductionService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new production record' })
  @ApiResponse({ status: 201, description: 'Production record created successfully', type: Production })
  create(@Body() createProductionDto: CreateProductionDto): Promise<Production> {
    return this.productionService.create(createProductionDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all production records' })
  @ApiResponse({ status: 200, description: 'List of all production records', type: [Production] })
  findAll(): Promise<Production[]> {
    return this.productionService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get production record by ID' })
  @ApiResponse({ status: 200, description: 'Production record found', type: Production })
  @ApiResponse({ status: 404, description: 'Production record not found' })
  findOne(@Param('id') id: string): Promise<Production> {
    return this.productionService.findOne(+id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update production record' })
  @ApiResponse({ status: 200, description: 'Production record updated successfully', type: Production })
  @ApiResponse({ status: 404, description: 'Production record not found' })
  update(
    @Param('id') id: string,
    @Body() updateProductionDto: UpdateProductionDto,
  ): Promise<Production> {
    return this.productionService.update(+id, updateProductionDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete production record' })
  @ApiResponse({ status: 204, description: 'Production record deleted successfully' })
  @ApiResponse({ status: 404, description: 'Production record not found' })
  remove(@Param('id') id: string): Promise<void> {
    return this.productionService.remove(+id);
  }
}
