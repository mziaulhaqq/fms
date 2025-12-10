import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Partners } from '../../entities/Partners.entity';
import { CreatePartnerDto, UpdatePartnerDto } from './dto';

@Injectable()
export class PartnersService {
  constructor(
    @InjectRepository(Partners)
    private readonly repository: Repository<Partners>,
  ) {}

  async create(createDto: CreatePartnerDto): Promise<Partners> {
    const entity = this.repository.create(createDto);
    return await this.repository.save(entity);
  }

  async findAll(): Promise<Partner[]> {
    return await this.repository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<Partners> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Partner with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdatePartnerDto): Promise<Partners> {
    const entity = await this.findOne(id);
    Object.assign(entity, updateDto);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
