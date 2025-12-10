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
import { IncomesService } from './income.service';
import { CreateIncomeDto, UpdateIncomeDto } from './dto';
import { Income } from '../../entities/Income.entity';
import { Roles } from '../auth/decorators/roles.decorator';
import { RolesGuard } from '../auth/guards/roles.guard';

@ApiTags('income')
@ApiBearerAuth()
@Controller('income')
@UseGuards(RolesGuard)
@Roles('admin')
export class IncomesController {
  constructor(private readonly service: IncomesService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new income (Admin only)' })
  @ApiResponse({ status: 201, description: 'Income created successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  create(@Body() createDto: CreateIncomeDto): Promise<Income> {
    return this.service.create(createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all income' })
  @ApiResponse({ status: 200, description: 'List of income' })
  findAll(): Promise<Income[]> {
    return this.service.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a income by ID' })
  @ApiParam({ name: 'id', description: 'Income ID' })
  @ApiResponse({ status: 200, description: 'Income found' })
  @ApiResponse({ status: 404, description: 'Income not found' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<Income> {
    return this.service.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a income' })
  @ApiParam({ name: 'id', description: 'Income ID' })
  @ApiResponse({ status: 200, description: 'Income updated successfully' })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateIncomeDto,
  ): Promise<Income> {
    return this.service.update(id, updateDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a income' })
  @ApiParam({ name: 'id', description: 'Income ID' })
  @ApiResponse({ status: 204, description: 'Income deleted successfully' })
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.service.remove(id);
  }
}
