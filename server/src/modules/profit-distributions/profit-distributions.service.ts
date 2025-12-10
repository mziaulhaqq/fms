import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ProfitDistributions } from '../../entities/ProfitDistributions.entity';
import { CreateProfitDistributionDto, UpdateProfitDistributionDto } from './dto';

@Injectable()
export class ProfitDistributionsService {
  constructor(
    @InjectRepository(ProfitDistributions)
    private readonly repository: Repository<ProfitDistributions>,
  ) {}

  async create(createDto: CreateProfitDistributionDto): Promise<ProfitDistributions> {
    const entity = this.repository.create(createDto);
    return await this.repository.save(entity);
  }

  async findAll(): Promise<ProfitDistributions[]> {
    return await this.repository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<ProfitDistributions> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Profit Distribution with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateProfitDistributionDto): Promise<ProfitDistributions> {
    const entity = await this.findOne(id);
    Object.assign(entity, updateDto);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
