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
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags, ApiQuery } from '@nestjs/swagger';
import { CurrentUserId } from '../../common/decorators/current-user.decorator';
import { LiabilitiesService } from './liabilities.service';
import { CreateLiabilityDto, UpdateLiabilityDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Liabilities')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('liabilities')
export class LiabilitiesController {
  constructor(private readonly service: LiabilitiesService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new liability (Loan or Advanced Payment)' })
  @ApiResponse({ status: 201, description: 'Liability created successfully' })
  create(@Body() createDto: CreateLiabilityDto, @Request() req) {
    return this.service.create(createDto, req.user.sub);
  }

  @Get()
  @ApiOperation({ summary: 'Get all liabilities or filter by client/mining site/type' })
  @ApiQuery({ name: 'clientId', required: false, description: 'Filter by client ID' })
  @ApiQuery({ name: 'miningSiteId', required: false, description: 'Filter by mining site ID' })
  @ApiQuery({ name: 'type', required: false, enum: ['Loan', 'Advanced Payment'] })
  @ApiResponse({ status: 200, description: 'Returns liabilities' })
  findAll(
    @Query('clientId') clientId?: string,
    @Query('miningSiteId') miningSiteId?: string,
    @Query('type') type?: 'Loan' | 'Advanced Payment',
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

  @Get('active/client/:clientId')
  @ApiOperation({ summary: 'Get active liabilities for a specific client' })
  @ApiResponse({ status: 200, description: 'Returns active liabilities for client' })
  findActiveByClient(@Param('clientId') clientId: string) {
    return this.service.findActiveByClient(+clientId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get liability by ID' })
  @ApiResponse({ status: 200, description: 'Returns liability' })
  @ApiResponse({ status: 404, description: 'Liability not found' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(+id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update liability' })
  @ApiResponse({ status: 200, description: 'Liability updated successfully' })
  @ApiResponse({ status: 404, description: 'Liability not found' })
  update(@Param('id') id: string, @Body() updateDto: UpdateLiabilityDto, @Request() req) {
    return this.service.update(+id, updateDto, req.user.sub);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete liability' })
  @ApiResponse({ status: 200, description: 'Liability deleted successfully' })
  @ApiResponse({ status: 404, description: 'Liability not found' })
  remove(@Param('id') id: string) {
    return this.service.remove(+id);
  }
}
