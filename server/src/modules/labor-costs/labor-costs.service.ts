import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { LaborCosts } from '../../entities/LaborCosts.entity';
import { CreateLaborCostDto, UpdateLaborCostDto } from './dto';

@Injectable()
export class LaborCostsService {
  constructor(
    @InjectRepository(LaborCosts)
    private readonly repository: Repository<LaborCosts>,
  ) {}

  async create(createDto: CreateLaborCostDto): Promise<LaborCosts> {
    const entity = this.repository.create(createDto);
    return await this.repository.save(entity);
  }

  async findAll(): Promise<LaborCost[]> {
    return await this.repository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<LaborCosts> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Labor Cost with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateLaborCostDto): Promise<LaborCosts> {
    const entity = await this.findOne(id);
    Object.assign(entity, updateDto);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
