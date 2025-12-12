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

  async create(createDto: CreatePartnerPayoutDto, userId?: number): Promise<PartnerPayouts> {
    const entity = this.repository.create({
      ...createDto,
      sharePercentage: createDto.sharePercentage.toString(),
      payoutAmount: createDto.payoutAmount.toString(),
    });
    return await this.repository.save(entity);
  }

  async findAll(): Promise<PartnerPayouts[]> {
    return await this.repository.find({
      relations: ['distribution', 'partner', 'miningSite'],
      order: { createdAt: 'DESC' },
    });
  }

  async findBySite(siteId: number): Promise<PartnerPayouts[]> {
    return await this.repository.find({
      where: { siteId },
      relations: ['distribution', 'partner', 'miningSite'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<PartnerPayouts> {
    const entity = await this.repository.findOne({ 
      where: { id },
      relations: ['distribution', 'partner', 'miningSite'],
    });
    if (!entity) {
      throw new NotFoundException(`Partner Payout with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdatePartnerPayoutDto, userId?: number): Promise<PartnerPayouts> {
    const entity = await this.findOne(id);
    const updateData: any = { ...updateDto };
    if (updateDto.sharePercentage !== undefined) {
      updateData.sharePercentage = updateDto.sharePercentage.toString();
    }
    if (updateDto.payoutAmount !== undefined) {
      updateData.payoutAmount = updateDto.payoutAmount.toString();
    }
    Object.assign(entity, updateData);
    if (userId) {
      (entity as any)._userId = userId;
    }
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
