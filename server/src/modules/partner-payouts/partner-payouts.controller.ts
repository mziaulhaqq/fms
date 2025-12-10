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
import { PartnerPayoutsService } from './partner-payouts.service';
import { CreatePartnerPayoutDto, UpdatePartnerPayoutDto } from './dto';
import { PartnerPayouts } from '../../entities/PartnerPayouts.entity';

@ApiTags('partner-payouts')
@Controller('partner-payouts')
export class PartnerPayoutsController {
  constructor(private readonly service: PartnerPayoutsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new partner payout' })
  @ApiResponse({ status: 201, description: 'Partner Payout created successfully' })
  create(@Body() createDto: CreatePartnerPayoutDto): Promise<PartnerPayouts> {
    return this.service.create(createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all partner-payouts' })
  @ApiResponse({ status: 200, description: 'List of partner-payouts' })
  findAll(): Promise<PartnerPayouts[]> {
    return this.service.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a partner payout by ID' })
  @ApiParam({ name: 'id', description: 'Partner Payout ID' })
  @ApiResponse({ status: 200, description: 'Partner Payout found' })
  @ApiResponse({ status: 404, description: 'Partner Payout not found' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<PartnerPayouts> {
    return this.service.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a partner payout' })
  @ApiParam({ name: 'id', description: 'Partner Payout ID' })
  @ApiResponse({ status: 200, description: 'Partner Payout updated successfully' })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdatePartnerPayoutDto,
  ): Promise<PartnerPayouts> {
    return this.service.update(id, updateDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a partner payout' })
  @ApiParam({ name: 'id', description: 'Partner Payout ID' })
  @ApiResponse({ status: 204, description: 'Partner Payout deleted successfully' })
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.service.remove(id);
  }
}
