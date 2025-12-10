import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SiteSupervisors } from '../../entities/SiteSupervisors.entity';
import { CreateSiteSupervisorDto, UpdateSiteSupervisorDto } from './dto';

@Injectable()
export class SiteSupervisorsService {
  constructor(
    @InjectRepository(SiteSupervisors)
    private readonly repository: Repository<SiteSupervisors>,
  ) {}

  async create(createDto: CreateSiteSupervisorDto): Promise<SiteSupervisors> {
    const entity = this.repository.create(createDto);
    return await this.repository.save(entity);
  }

  async findAll(): Promise<SiteSupervisors[]> {
    return await this.repository.find();
  }

  async findOne(id: number): Promise<SiteSupervisors> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Site Supervisor with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateSiteSupervisorDto): Promise<SiteSupervisors> {
    const entity = await this.findOne(id);
    Object.assign(entity, updateDto);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
