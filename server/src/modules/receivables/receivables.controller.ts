import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags, ApiQuery } from '@nestjs/swagger';
import { CurrentUserId } from '../../common/decorators/current-user.decorator';
import { ReceivablesService } from './receivables.service';
import { CreateReceivableDto, UpdateReceivableDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Receivables')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('receivables')
export class ReceivablesController {
  constructor(private readonly service: ReceivablesService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new receivable (Client owes us money)' })
  @ApiResponse({ status: 201, description: 'Receivable created successfully' })
  create(@Body() createDto: CreateReceivableDto, @CurrentUserId() userId: number) {
    return this.service.create(createDto, userId);
  }

  @Get()
  @ApiOperation({ summary: 'Get all receivables or filter by client/mining site' })
  @ApiQuery({ name: 'clientId', required: false, description: 'Filter by client ID' })
  @ApiQuery({ name: 'miningSiteId', required: false, description: 'Filter by mining site ID' })
  @ApiResponse({ status: 200, description: 'Returns receivables' })
  findAll(
    @Query('clientId') clientId?: string,
    @Query('miningSiteId') miningSiteId?: string,
  ) {
    if (clientId) {
      return this.service.findByClient(+clientId);
    }
    if (miningSiteId) {
      return this.service.findByMiningSite(+miningSiteId);
    }
    return this.service.findAll();
  }

  @Get('pending/client/:clientId')
  @ApiOperation({ summary: 'Get pending receivables for a specific client' })
  @ApiResponse({ status: 200, description: 'Returns pending receivables for client' })
  findPendingByClient(@Param('clientId') clientId: string) {
    return this.service.findPendingByClient(+clientId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get receivable by ID' })
  @ApiResponse({ status: 200, description: 'Returns receivable' })
  @ApiResponse({ status: 404, description: 'Receivable not found' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(+id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update receivable' })
  @ApiResponse({ status: 200, description: 'Receivable updated successfully' })
  @ApiResponse({ status: 404, description: 'Receivable not found' })
  update(@Param('id') id: string, @Body() updateDto: UpdateReceivableDto, @CurrentUserId() userId: number) {
    return this.service.update(+id, updateDto, userId);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete receivable' })
  @ApiResponse({ status: 200, description: 'Receivable deleted successfully' })
  @ApiResponse({ status: 404, description: 'Receivable not found' })
  remove(@Param('id') id: string) {
    return this.service.remove(+id);
  }
}
