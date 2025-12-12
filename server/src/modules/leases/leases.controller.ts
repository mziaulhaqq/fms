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
import { LeasesService } from './leases.service';
import { CreateLeaseDto, UpdateLeaseDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Leases')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('leases')
export class LeasesController {
  constructor(private readonly service: LeasesService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new lease' })
  @ApiResponse({ status: 201, description: 'Lease created successfully' })
  create(@Body() createDto: CreateLeaseDto, @Request() req) {
    return this.service.create(createDto, req.user.sub);
  }

  @Get()
  @ApiOperation({ summary: 'Get all leases' })
  @ApiResponse({ status: 200, description: 'Returns all leases with mining sites and partners' })
  findAll() {
    return this.service.findAll();
  }

  @Get('active')
  @ApiOperation({ summary: 'Get active leases only' })
  @ApiResponse({ status: 200, description: 'Returns active leases with mining sites' })
  findActive() {
    return this.service.findActive();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get lease by ID' })
  @ApiResponse({ status: 200, description: 'Returns lease with related data' })
  @ApiResponse({ status: 404, description: 'Lease not found' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(+id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update lease' })
  @ApiResponse({ status: 200, description: 'Lease updated successfully' })
  @ApiResponse({ status: 404, description: 'Lease not found' })
  update(@Param('id') id: string, @Body() updateDto: UpdateLeaseDto, @Request() req) {
    return this.service.update(+id, updateDto, req.user.sub);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete lease' })
  @ApiResponse({ status: 200, description: 'Lease deleted successfully' })
  @ApiResponse({ status: 404, description: 'Lease not found' })
  remove(@Param('id') id: string) {
    return this.service.remove(+id);
  }
}
