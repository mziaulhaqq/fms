import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PartnerPayouts } from '../../entities/PartnerPayouts.entity';
import { CreatePartnerPayoutDto, UpdatePartnerPayoutDto } from './dto';

@Injectable()
export class PartnerPayoutsService {
  constructor(
    @InjectRepository(PartnerPayouts)
    private readonly repository: Repository<PartnerPayouts>,
  ) {}

  async create(createDto: CreatePartnerPayoutDto): Promise<PartnerPayouts> {
    const entity = this.repository.create(createDto);
    return await this.repository.save(entity);
  }

  async findAll(): Promise<PartnerPayouts[]> {
    return await this.repository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<PartnerPayouts> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Partner Payout with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdatePartnerPayoutDto): Promise<PartnerPayouts> {
    const entity = await this.findOne(id);
    Object.assign(entity, updateDto);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
