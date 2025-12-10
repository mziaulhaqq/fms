import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Labor } from '../../entities/Labor.entity';
import { CreateLaborDto, UpdateLaborDto } from './dto';

@Injectable()
export class LaborsService {
  constructor(
    @InjectRepository(Labor)
    private readonly repository: Repository<Labor>,
  ) {}

  async create(createDto: CreateLaborDto): Promise<Labor> {
    const entity = this.repository.create(createDto);
    return await this.repository.save(entity);
  }

  async findAll(): Promise<Labor[]> {
    return await this.repository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<Labor> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Worker with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateLaborDto): Promise<Labor> {
    const entity = await this.findOne(id);
    Object.assign(entity, updateDto);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
