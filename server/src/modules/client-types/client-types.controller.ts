import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { CurrentUserId } from '../../common/decorators/current-user.decorator';
import { ClientTypesService } from './client-types.service';
import { CreateClientTypeDto, UpdateClientTypeDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Client Types')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('client-types')
export class ClientTypesController {
  constructor(private readonly service: ClientTypesService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new client type' })
  @ApiResponse({ status: 201, description: 'Client type created successfully' })
  @ApiResponse({ status: 409, description: 'Client type already exists' })
  create(@Body() createDto: CreateClientTypeDto, @CurrentUserId() userId: number) {
    return this.service.create(createDto, userId);
  }

  @Get()
  @ApiOperation({ summary: 'Get all client types' })
  @ApiResponse({ status: 200, description: 'Returns all client types' })
  findAll() {
    return this.service.findAll();
  }

  @Get('active')
  @ApiOperation({ summary: 'Get active client types only' })
  @ApiResponse({ status: 200, description: 'Returns active client types' })
  findActive() {
    return this.service.findActive();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get client type by ID' })
  @ApiResponse({ status: 200, description: 'Returns client type' })
  @ApiResponse({ status: 404, description: 'Client type not found' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(+id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update client type' })
  @ApiResponse({ status: 200, description: 'Client type updated successfully' })
  @ApiResponse({ status: 404, description: 'Client type not found' })
  update(@Param('id') id: string, @Body() updateDto: UpdateClientTypeDto, @CurrentUserId() userId: number) {
    return this.service.update(+id, updateDto, userId);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete client type' })
  @ApiResponse({ status: 200, description: 'Client type deleted successfully' })
  @ApiResponse({ status: 404, description: 'Client type not found' })
  remove(@Param('id') id: string) {
    return this.service.remove(+id);
  }
}
