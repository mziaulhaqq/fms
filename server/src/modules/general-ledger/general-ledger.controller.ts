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
import { GeneralLedgerService } from './general-ledger.service';
import { CreateGeneralLedgerDto, UpdateGeneralLedgerDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('General Ledger')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('general-ledger')
export class GeneralLedgerController {
  constructor(private readonly service: GeneralLedgerService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new general ledger account' })
  @ApiResponse({ status: 201, description: 'Account created successfully' })
  @ApiResponse({ status: 409, description: 'Account code already exists in this mining site' })
  create(@Body() createDto: CreateGeneralLedgerDto, @Request() req) {
    return this.service.create(createDto, req.user.sub);
  }

  @Get()
  @ApiOperation({ summary: 'Get all general ledger accounts or filter by mining site or account type' })
  @ApiQuery({ name: 'miningSiteId', required: false, description: 'Filter by mining site ID' })
  @ApiQuery({ name: 'accountTypeId', required: false, description: 'Filter by account type ID' })
  @ApiResponse({ status: 200, description: 'Returns general ledger accounts' })
  findAll(
    @Query('miningSiteId') miningSiteId?: string,
    @Query('accountTypeId') accountTypeId?: string,
  ) {
    if (miningSiteId) {
      return this.service.findByMiningSite(+miningSiteId);
    }
    if (accountTypeId) {
      return this.service.findByAccountType(+accountTypeId);
    }
    return this.service.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get general ledger account by ID' })
  @ApiResponse({ status: 200, description: 'Returns account' })
  @ApiResponse({ status: 404, description: 'Account not found' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(+id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update general ledger account' })
  @ApiResponse({ status: 200, description: 'Account updated successfully' })
  @ApiResponse({ status: 404, description: 'Account not found' })
  update(@Param('id') id: string, @Body() updateDto: UpdateGeneralLedgerDto, @Request() req) {
    return this.service.update(+id, updateDto, req.user.sub);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete general ledger account' })
  @ApiResponse({ status: 200, description: 'Account deleted successfully' })
  @ApiResponse({ status: 404, description: 'Account not found' })
  remove(@Param('id') id: string) {
    return this.service.remove(+id);
  }
}
