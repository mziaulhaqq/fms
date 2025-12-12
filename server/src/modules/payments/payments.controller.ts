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
import { PaymentsService } from './payments.service';
import { CreatePaymentDto, UpdatePaymentDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Payments')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('payments')
export class PaymentsController {
  constructor(private readonly service: PaymentsService) {}

  @Post()
  @ApiOperation({ summary: 'Record a new payment (Payable Deduction or Receivable Payment)' })
  @ApiResponse({ status: 201, description: 'Payment recorded successfully' })
  create(@Body() createDto: CreatePaymentDto, @CurrentUserId() userId: number) {
    return this.service.create(createDto, userId);
  }

  @Get()
  @ApiOperation({ summary: 'Get all payments or filter by client/mining site/type' })
  @ApiQuery({ name: 'clientId', required: false, description: 'Filter by client ID' })
  @ApiQuery({ name: 'miningSiteId', required: false, description: 'Filter by mining site ID' })
  @ApiQuery({ name: 'type', required: false, enum: ['Payable Deduction', 'Receivable Payment'] })
  @ApiResponse({ status: 200, description: 'Returns payments' })
  findAll(
    @Query('clientId') clientId?: string,
    @Query('miningSiteId') miningSiteId?: string,
    @Query('type') type?: 'Payable Deduction' | 'Receivable Payment',
  ) {
    if (clientId) {
      return this.service.findByClient(+clientId);
    }
    if (miningSiteId) {
      return this.service.findByMiningSite(+miningSiteId);
    }
    if (type) {
      return this.service.findByType(type);
    }
    return this.service.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get payment by ID' })
  @ApiResponse({ status: 200, description: 'Returns payment' })
  @ApiResponse({ status: 404, description: 'Payment not found' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(+id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update payment' })
  @ApiResponse({ status: 200, description: 'Payment updated successfully' })
  @ApiResponse({ status: 404, description: 'Payment not found' })
  update(@Param('id') id: string, @Body() updateDto: UpdatePaymentDto, @CurrentUserId() userId: number) {
    return this.service.update(+id, updateDto, userId);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete payment' })
  @ApiResponse({ status: 200, description: 'Payment deleted successfully' })
  @ApiResponse({ status: 404, description: 'Payment not found' })
  remove(@Param('id') id: string) {
    return this.service.remove(+id);
  }
}
