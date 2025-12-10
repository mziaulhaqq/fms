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
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiBearerAuth } from '@nestjs/swagger';
import { ProfitDistributionsService } from './profit-distributions.service';
import { CreateProfitDistributionDto, UpdateProfitDistributionDto } from './dto';
import { ProfitDistributions } from '../../entities/ProfitDistributions.entity';
import { Roles } from '../auth/decorators/roles.decorator';
import { RolesGuard } from '../auth/guards/roles.guard';

@ApiTags('profit-distributions')
@ApiBearerAuth()
@Controller('profit-distributions')
@UseGuards(RolesGuard)
@Roles('admin')
export class ProfitDistributionsController {
  constructor(private readonly service: ProfitDistributionsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new profit distribution (Admin only)' })
  @ApiResponse({ status: 201, description: 'Profit Distribution created successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  create(@Body() createDto: CreateProfitDistributionDto): Promise<ProfitDistributions> {
    return this.service.create(createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all profit-distributions (Admin only)' })
  @ApiResponse({ status: 200, description: 'List of profit-distributions' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  findAll(): Promise<ProfitDistributions[]> {
    return this.service.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a profit distribution by ID (Admin only)' })
  @ApiParam({ name: 'id', description: 'Profit Distribution ID' })
  @ApiResponse({ status: 200, description: 'Profit Distribution found' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  @ApiResponse({ status: 404, description: 'Profit Distribution not found' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<ProfitDistributions> {
    return this.service.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a profit distribution' })
  @ApiParam({ name: 'id', description: 'Profit Distribution ID' })
  @ApiResponse({ status: 200, description: 'Profit Distribution updated successfully' })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateProfitDistributionDto,
  ): Promise<ProfitDistributions> {
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
