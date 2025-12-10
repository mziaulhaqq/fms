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
import { ProfitDistributionsService } from './profit-distributions.service';
import { CreateProfitDistributionDto, UpdateProfitDistributionDto } from './dto';
import { ProfitDistribution } from '../../entities/profit-distribution.entity';

@ApiTags('profit-distributions')
@Controller('profit-distributions')
export class ProfitDistributionsController {
  constructor(private readonly service: ProfitDistributionsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new profit distribution' })
  @ApiResponse({ status: 201, description: 'Profit Distribution created successfully', type: ProfitDistribution })
  create(@Body() createDto: CreateProfitDistributionDto): Promise<ProfitDistribution> {
    return this.service.create(createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all profit-distributions' })
  @ApiResponse({ status: 200, description: 'List of profit-distributions', type: [ProfitDistribution] })
  findAll(): Promise<ProfitDistribution[]> {
    return this.service.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a profit distribution by ID' })
  @ApiParam({ name: 'id', description: 'Profit Distribution ID' })
  @ApiResponse({ status: 200, description: 'Profit Distribution found', type: ProfitDistribution })
  @ApiResponse({ status: 404, description: 'Profit Distribution not found' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<ProfitDistribution> {
    return this.service.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a profit distribution' })
  @ApiParam({ name: 'id', description: 'Profit Distribution ID' })
  @ApiResponse({ status: 200, description: 'Profit Distribution updated successfully', type: ProfitDistribution })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateProfitDistributionDto,
  ): Promise<ProfitDistribution> {
    return this.service.update(id, updateDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a profit distribution' })
  @ApiParam({ name: 'id', description: 'Profit Distribution ID' })
  @ApiResponse({ status: 204, description: 'Profit Distribution deleted successfully' })
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.service.remove(id);
  }
}
