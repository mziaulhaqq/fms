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
import { TruckDeliverysService } from './truck-deliveries.service';
import { CreateTruckDeliveryDto, UpdateTruckDeliveryDto } from './dto';
import { TruckDelivery } from '../../entities/truck-delivery.entity';

@ApiTags('truck-deliveries')
@Controller('truck-deliveries')
export class TruckDeliverysController {
  constructor(private readonly service: TruckDeliverysService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new truck delivery' })
  @ApiResponse({ status: 201, description: 'Truck Delivery created successfully', type: TruckDelivery })
  create(@Body() createDto: CreateTruckDeliveryDto): Promise<TruckDelivery> {
    return this.service.create(createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all truck-deliveries' })
  @ApiResponse({ status: 200, description: 'List of truck-deliveries', type: [TruckDelivery] })
  findAll(): Promise<TruckDelivery[]> {
    return this.service.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a truck delivery by ID' })
  @ApiParam({ name: 'id', description: 'Truck Delivery ID' })
  @ApiResponse({ status: 200, description: 'Truck Delivery found', type: TruckDelivery })
  @ApiResponse({ status: 404, description: 'Truck Delivery not found' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<TruckDelivery> {
    return this.service.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a truck delivery' })
  @ApiParam({ name: 'id', description: 'Truck Delivery ID' })
  @ApiResponse({ status: 200, description: 'Truck Delivery updated successfully', type: TruckDelivery })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateTruckDeliveryDto,
  ): Promise<TruckDelivery> {
    return this.service.update(id, updateDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a truck delivery' })
  @ApiParam({ name: 'id', description: 'Truck Delivery ID' })
  @ApiResponse({ status: 204, description: 'Truck Delivery deleted successfully' })
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.service.remove(id);
  }
}
