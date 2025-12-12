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

  async create(createDto: CreatePartnerDto, userId?: number): Promise<Partners> {
    const entity = this.repository.create({
      ...createDto,
      sharePercentage: createDto.sharePercentage?.toString() || null,
    });
    return await this.repository.save(entity);
  }

  async findAll(): Promise<Partners[]> {
    return await this.repository.find({
      relations: ['lease', 'miningSite'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<Partners> {
    const entity = await this.repository.findOne({ 
      where: { id },
      relations: ['lease', 'miningSite'],
    });
    if (!entity) {
      throw new NotFoundException(`Partner with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdatePartnerDto, userId?: number): Promise<Partners> {
    const entity = await this.findOne(id);
    const updateData = {
      ...updateDto,
      sharePercentage: updateDto.sharePercentage !== undefined 
        ? updateDto.sharePercentage?.toString() || null 
        : entity.sharePercentage,
    };
    Object.assign(entity, updateData);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
