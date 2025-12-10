import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SiteSupervisor } from '../../entities/site-supervisor.entity';
import { CreateSiteSupervisorDto, UpdateSiteSupervisorDto } from './dto';

@Injectable()
export class SiteSupervisorsService {
  constructor(
    @InjectRepository(SiteSupervisor)
    private readonly repository: Repository<SiteSupervisor>,
  ) {}

  async create(createDto: CreateSiteSupervisorDto): Promise<SiteSupervisor> {
    const entity = this.repository.create(createDto);
    return await this.repository.save(entity);
  }

  async findAll(): Promise<SiteSupervisor[]> {
    return await this.repository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<SiteSupervisor> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Site Supervisor with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateSiteSupervisorDto): Promise<SiteSupervisor> {
    const entity = await this.findOne(id);
    Object.assign(entity, updateDto);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
