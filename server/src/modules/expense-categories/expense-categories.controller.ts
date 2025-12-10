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
import { ExpenseCategorysService } from './expense-categories.service';
import { CreateExpenseCategoryDto, UpdateExpenseCategoryDto } from './dto';
import { ExpenseCategory } from '../../entities/expense-category.entity';

@ApiTags('expense-categories')
@Controller('expense-categories')
export class ExpenseCategorysController {
  constructor(private readonly service: ExpenseCategorysService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new expense category' })
  @ApiResponse({ status: 201, description: 'Expense Category created successfully', type: ExpenseCategory })
  create(@Body() createDto: CreateExpenseCategoryDto): Promise<ExpenseCategory> {
    return this.service.create(createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all expense-categories' })
  @ApiResponse({ status: 200, description: 'List of expense-categories', type: [ExpenseCategory] })
  findAll(): Promise<ExpenseCategory[]> {
    return this.service.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a expense category by ID' })
  @ApiParam({ name: 'id', description: 'Expense Category ID' })
  @ApiResponse({ status: 200, description: 'Expense Category found', type: ExpenseCategory })
  @ApiResponse({ status: 404, description: 'Expense Category not found' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<ExpenseCategory> {
    return this.service.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a expense category' })
  @ApiParam({ name: 'id', description: 'Expense Category ID' })
  @ApiResponse({ status: 200, description: 'Expense Category updated successfully', type: ExpenseCategory })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateExpenseCategoryDto,
  ): Promise<ExpenseCategory> {
    return this.service.update(id, updateDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a expense category' })
  @ApiParam({ name: 'id', description: 'Expense Category ID' })
  @ApiResponse({ status: 204, description: 'Expense Category deleted successfully' })
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.service.remove(id);
  }
}
