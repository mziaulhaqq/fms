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
import { AccountTypesService } from './account-types.service';
import { CreateAccountTypeDto, UpdateAccountTypeDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Account Types')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('account-types')
export class AccountTypesController {
  constructor(private readonly service: AccountTypesService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new account type' })
  @ApiResponse({ status: 201, description: 'Account type created successfully' })
  @ApiResponse({ status: 409, description: 'Account type already exists' })
  create(@Body() createDto: CreateAccountTypeDto, @Request() req) {
    return this.service.create(createDto, req.user.sub);
  }

  @Get()
  @ApiOperation({ summary: 'Get all account types' })
  @ApiResponse({ status: 200, description: 'Returns all account types' })
  findAll() {
    return this.service.findAll();
  }

  @Get('active')
  @ApiOperation({ summary: 'Get active account types only' })
  @ApiResponse({ status: 200, description: 'Returns active account types' })
  findActive() {
    return this.service.findActive();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get account type by ID' })
  @ApiResponse({ status: 200, description: 'Returns account type' })
  @ApiResponse({ status: 404, description: 'Account type not found' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(+id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update account type' })
  @ApiResponse({ status: 200, description: 'Account type updated successfully' })
  @ApiResponse({ status: 404, description: 'Account type not found' })
  update(@Param('id') id: string, @Body() updateDto: UpdateAccountTypeDto, @Request() req) {
    return this.service.update(+id, updateDto, req.user.sub);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete account type' })
  @ApiResponse({ status: 200, description: 'Account type deleted successfully' })
  @ApiResponse({ status: 404, description: 'Account type not found' })
  remove(@Param('id') id: string) {
    return this.service.remove(+id);
  }
}
