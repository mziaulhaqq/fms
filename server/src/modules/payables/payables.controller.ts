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
import { PayablesService } from './payables.service';
import { CreateLiabilityDto, UpdateLiabilityDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Payables')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('payables')
export class PayablesController {
  constructor(private readonly service: PayablesService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new payable (Advance Payment from client)' })
  @ApiResponse({ status: 201, description: 'Payable created successfully' })
  create(@Body() createDto: CreateLiabilityDto, @CurrentUserId() userId: number) {
    return this.service.create(createDto, userId);
  }

  @Get()
  @ApiOperation({ summary: 'Get all payables or filter by client/mining site' })
  @ApiQuery({ name: 'clientId', required: false, description: 'Filter by client ID' })
  @ApiQuery({ name: 'miningSiteId', required: false, description: 'Filter by mining site ID' })
  @ApiResponse({ status: 200, description: 'Returns payables' })
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

  @Get('active/client/:clientId')
  @ApiOperation({ summary: 'Get active payables for a specific client' })
  @ApiResponse({ status: 200, description: 'Returns active payables for client' })
  findActiveByClient(@Param('clientId') clientId: string) {
    return this.service.findActiveByClient(+clientId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get payable by ID' })
  @ApiResponse({ status: 200, description: 'Returns payable' })
  @ApiResponse({ status: 404, description: 'Payable not found' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(+id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update payable' })
  @ApiResponse({ status: 200, description: 'Payable updated successfully' })
  @ApiResponse({ status: 404, description: 'Payable not found' })
  update(@Param('id') id: string, @Body() updateDto: UpdateLiabilityDto, @CurrentUserId() userId: number) {
    return this.service.update(+id, updateDto, userId);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete payable' })
  @ApiResponse({ status: 200, description: 'Payable deleted successfully' })
  @ApiResponse({ status: 404, description: 'Payable not found' })
  remove(@Param('id') id: string) {
    return this.service.remove(+id);
  }
}
