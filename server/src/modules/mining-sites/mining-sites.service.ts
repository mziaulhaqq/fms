import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MiningSites } from '../../entities/MiningSites.entity';
import { CreateMiningSiteDto, UpdateMiningSiteDto } from './dto';

@Injectable()
export class MiningSitesService {
  constructor(
    @InjectRepository(MiningSites)
    private readonly repository: Repository<MiningSites>,
  ) {}

  async create(createDto: CreateMiningSiteDto): Promise<MiningSites> {
    const entity = this.repository.create(createDto);
    return await this.repository.save(entity);
  }

  async findAll(): Promise<MiningSites[]> {
    return await this.repository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<MiningSites> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Mining Site with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateMiningSiteDto): Promise<MiningSites> {
    const entity = await this.findOne(id);
    Object.assign(entity, updateDto);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
