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
    const entity = this.repository.create(createDto);
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
    Object.assign(entity, updateDto);
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
