import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Production } from '../../entities/production.entity';
import { CreateProductionDto, UpdateProductionDto } from './dto';

@Injectable()
export class ProductionsService {
  constructor(
    @InjectRepository(Production)
    private readonly repository: Repository<Production>,
  ) {}

  async create(createDto: CreateProductionDto): Promise<Production> {
    const entity = this.repository.create(createDto);
    return await this.repository.save(entity);
  }

  async findAll(): Promise<Production[]> {
    return await this.repository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<Production> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Production with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateProductionDto): Promise<Production> {
    const entity = await this.findOne(id);
    Object.assign(entity, updateDto);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
