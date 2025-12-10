import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ProfitDistribution } from '../../entities/profit-distribution.entity';
import { CreateProfitDistributionDto, UpdateProfitDistributionDto } from './dto';

@Injectable()
export class ProfitDistributionsService {
  constructor(
    @InjectRepository(ProfitDistribution)
    private readonly repository: Repository<ProfitDistribution>,
  ) {}

  async create(createDto: CreateProfitDistributionDto): Promise<ProfitDistribution> {
    const entity = this.repository.create(createDto);
    return await this.repository.save(entity);
  }

  async findAll(): Promise<ProfitDistribution[]> {
    return await this.repository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<ProfitDistribution> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Profit Distribution with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateProfitDistributionDto): Promise<ProfitDistribution> {
    const entity = await this.findOne(id);
    Object.assign(entity, updateDto);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
