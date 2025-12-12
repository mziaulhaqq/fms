import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { CurrentUserId } from '../../common/decorators/current-user.decorator';
import { ExpenseTypesService } from './expense-types.service';
import { CreateExpenseTypeDto, UpdateExpenseTypeDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Expense Types')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('expense-types')
export class ExpenseTypesController {
  constructor(private readonly service: ExpenseTypesService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new expense type' })
  @ApiResponse({ status: 201, description: 'Expense type created successfully' })
  @ApiResponse({ status: 409, description: 'Expense type already exists' })
  create(@Body() createDto: CreateExpenseTypeDto, @Request() req) {
    return this.service.create(createDto, req.user.sub);
  }

  @Get()
  @ApiOperation({ summary: 'Get all expense types' })
  @ApiResponse({ status: 200, description: 'Returns all expense types' })
  findAll() {
    return this.service.findAll();
  }

  @Get('active')
  @ApiOperation({ summary: 'Get active expense types only' })
  @ApiResponse({ status: 200, description: 'Returns active expense types' })
  findActive() {
    return this.service.findActive();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get expense type by ID' })
  @ApiResponse({ status: 200, description: 'Returns expense type' })
  @ApiResponse({ status: 404, description: 'Expense type not found' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(+id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update expense type' })
  @ApiResponse({ status: 200, description: 'Expense type updated successfully' })
  @ApiResponse({ status: 404, description: 'Expense type not found' })
  update(@Param('id') id: string, @Body() updateDto: UpdateExpenseTypeDto, @Request() req) {
    return this.service.update(+id, updateDto, req.user.sub);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete expense type' })
  @ApiResponse({ status: 200, description: 'Expense type deleted successfully' })
  @ApiResponse({ status: 404, description: 'Expense type not found' })
  remove(@Param('id') id: string) {
    return this.service.remove(+id);
  }
}
