import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Lease } from '../../entities/Lease.entity';
import { CreateLeaseDto, UpdateLeaseDto } from './dto';

@Injectable()
export class LeasesService {
  constructor(
    @InjectRepository(Lease)
    private readonly repository: Repository<Lease>,
  ) {}

  async create(createDto: CreateLeaseDto, userId: number): Promise<Lease> {
    const entity = this.repository.create({
      ...createDto,
      createdById: userId,
      modifiedById: userId,
    });
    return await this.repository.save(entity);
  }

  async findAll(): Promise<Lease[]> {
    return await this.repository.find({
      relations: ['miningSites', 'partners'],
      order: { leaseName: 'ASC' },
    });
  }

  async findActive(): Promise<Lease[]> {
    return await this.repository.find({
      where: { isActive: true },
      relations: ['miningSites'],
      order: { leaseName: 'ASC' },
    });
  }

  async findOne(id: number): Promise<Lease> {
    const entity = await this.repository.findOne({
      where: { id },
      relations: ['miningSites', 'partners'],
    });
    if (!entity) {
      throw new NotFoundException(`Lease with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateLeaseDto, userId: number): Promise<Lease> {
    const entity = await this.findOne(id);
    Object.assign(entity, updateDto);
    entity.modifiedById = userId;
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
