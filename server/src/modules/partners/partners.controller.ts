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
import { PartnersService } from './partners.service';
import { CreatePartnerDto, UpdatePartnerDto } from './dto';
import { Partners } from '../../entities/Partners.entity';

@ApiTags('partners')
@Controller('partners')
export class PartnersController {
  constructor(private readonly service: PartnersService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new partner' })
  @ApiResponse({ status: 201, description: 'Partner created successfully' })
  create(@Body() createDto: CreatePartnerDto): Promise<Partners> {
    return this.service.create(createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all partners' })
  @ApiResponse({ status: 200, description: 'List of partners' })
  findAll(): Promise<Partners[]> {
    return this.service.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a partner by ID' })
  @ApiParam({ name: 'id', description: 'Partner ID' })
  @ApiResponse({ status: 200, description: 'Partner found' })
  @ApiResponse({ status: 404, description: 'Partner not found' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<Partners> {
    return this.service.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a partner' })
  @ApiParam({ name: 'id', description: 'Partner ID' })
  @ApiResponse({ status: 200, description: 'Partner updated successfully' })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdatePartnerDto,
  ): Promise<Partners> {
    return this.service.update(id, updateDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a partner' })
  @ApiParam({ name: 'id', description: 'Partner ID' })
  @ApiResponse({ status: 204, description: 'Partner deleted successfully' })
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.service.remove(id);
  }
}
