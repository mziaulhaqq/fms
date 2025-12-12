import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Income } from '../../entities/Income.entity';
import { CreateIncomeDto, UpdateIncomeDto } from './dto';

@Injectable()
export class IncomesService {
  constructor(
    @InjectRepository(Income)
    private readonly repository: Repository<Income>,
  ) {}

  async create(createDto: CreateIncomeDto, userId?: number): Promise<Income> {
    // Convert numeric values to strings for the entity
    const data: any = {
      ...createDto,
      coalPrice: String(createDto.coalPrice),
      companyCommission: createDto.companyCommission ? String(createDto.companyCommission) : null,
      quantityTons: createDto.quantityTons ? String(createDto.quantityTons) : null,
      totalPrice: createDto.totalPrice ? String(createDto.totalPrice) : null,
      amountFromLiability: createDto.amountFromLiability ? String(createDto.amountFromLiability) : null,
    };
    
    const entity = this.repository.create(data) as unknown as Income;
    if (userId) {
      (entity as any)._userId = userId;
    }
    return await this.repository.save(entity);
  }

  async findAll(): Promise<Income[]> {
    return await this.repository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<Income> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Income with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateIncomeDto, userId?: number): Promise<Income> {
    const entity = await this.findOne(id);
    
    // Convert numeric values to strings for the entity
    const data: any = { ...updateDto };
    if (updateDto.coalPrice !== undefined) {
      data.coalPrice = String(updateDto.coalPrice);
    }
    if (updateDto.companyCommission !== undefined) {
      data.companyCommission = updateDto.companyCommission ? String(updateDto.companyCommission) : null;
    }
    if (updateDto.quantityTons !== undefined) {
      data.quantityTons = updateDto.quantityTons ? String(updateDto.quantityTons) : null;
    }
    if (updateDto.totalPrice !== undefined) {
      data.totalPrice = updateDto.totalPrice ? String(updateDto.totalPrice) : null;
    }
    if (updateDto.amountFromLiability !== undefined) {
      data.amountFromLiability = updateDto.amountFromLiability ? String(updateDto.amountFromLiability) : null;
    }
    
    Object.assign(entity, data);
    if (userId) {
      (entity as any)._userId = userId;
    }
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
