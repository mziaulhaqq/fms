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
import { ProductionsService } from './production.service';
import { CreateProductionDto, UpdateProductionDto } from './dto';
import { Production } from '../../entities/production.entity';

@ApiTags('production')
@Controller('production')
export class ProductionsController {
  constructor(private readonly service: ProductionsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new production' })
  @ApiResponse({ status: 201, description: 'Production created successfully' })
  create(@Body() createDto: CreateProductionDto): Promise<Production> {
    return this.service.create(createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all production' })
  @ApiResponse({ status: 200, description: 'List of production' })
  findAll(): Promise<Production[]> {
    return this.service.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a production by ID' })
  @ApiParam({ name: 'id', description: 'Production ID' })
  @ApiResponse({ status: 200, description: 'Production found' })
  @ApiResponse({ status: 404, description: 'Production not found' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<Production> {
    return this.service.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a production' })
  @ApiParam({ name: 'id', description: 'Production ID' })
  @ApiResponse({ status: 200, description: 'Production updated successfully' })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateProductionDto,
  ): Promise<Production> {
    return this.service.update(id, updateDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a production' })
  @ApiParam({ name: 'id', description: 'Production ID' })
  @ApiResponse({ status: 204, description: 'Production deleted successfully' })
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.service.remove(id);
  }
}
