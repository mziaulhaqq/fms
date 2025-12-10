import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { LaborCostWorker } from '../../entities/labor-cost-worker.entity';
import { CreateLaborCostWorkerDto, UpdateLaborCostWorkerDto } from './dto';

@Injectable()
export class LaborCostWorkersService {
  constructor(
    @InjectRepository(LaborCostWorker)
    private readonly repository: Repository<LaborCostWorker>,
  ) {}

  async create(createDto: CreateLaborCostWorkerDto): Promise<LaborCostWorker> {
    const entity = this.repository.create(createDto);
    return await this.repository.save(entity);
  }

  async findAll(): Promise<LaborCostWorker[]> {
    return await this.repository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<LaborCostWorker> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Labor Cost Worker with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateLaborCostWorkerDto): Promise<LaborCostWorker> {
    const entity = await this.findOne(id);
    Object.assign(entity, updateDto);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
