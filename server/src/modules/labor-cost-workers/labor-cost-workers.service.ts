import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { LaborCostWorkers } from '../../entities/LaborCostWorkers.entity';
import { CreateLaborCostWorkerDto, UpdateLaborCostWorkerDto } from './dto';

@Injectable()
export class LaborCostWorkersService {
  constructor(
    @InjectRepository(LaborCostWorkers)
    private readonly repository: Repository<LaborCostWorkers>,
  ) {}

  async create(createDto: CreateLaborCostWorkerDto): Promise<LaborCostWorkers> {
    const entity = this.repository.create(createDto);
    return await this.repository.save(entity);
  }

  async findAll(): Promise<LaborCostWorkers[]> {
    return await this.repository.find();
  }

  async findOne(id: number): Promise<LaborCostWorkers> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Labor Cost Worker with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateLaborCostWorkerDto): Promise<LaborCostWorkers> {
    const entity = await this.findOne(id);
    Object.assign(entity, updateDto);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
