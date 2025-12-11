import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ProfitDistributions } from '../../entities/ProfitDistributions.entity';
import { CreateProfitDistributionDto, UpdateProfitDistributionDto } from './dto';

@Injectable()
export class ProfitDistributionsService {
  constructor(
    @InjectRepository(ProfitDistributions)
    private readonly repository: Repository<ProfitDistributions>,
  ) {}

  async create(createDto: CreateProfitDistributionDto): Promise<ProfitDistributions> {
    const { approvedBy, totalRevenue, totalExpenses, totalProfit, ...rest } = createDto;
    const entity = this.repository.create({
      ...rest,
      totalRevenue: totalRevenue.toString(),
      totalExpenses: totalExpenses.toString(),
      totalProfit: totalProfit.toString(),
      ...(approvedBy && { approvedBy: { id: approvedBy } as any }),
    });
    return await this.repository.save(entity);
  }

  async findAll(): Promise<ProfitDistributions[]> {
    return await this.repository.find({
      relations: ['approvedBy', 'miningSite'],
      order: { createdAt: 'DESC' },
    });
  }

  async findBySite(siteId: number): Promise<ProfitDistributions[]> {
    return await this.repository.find({
      where: { siteId },
      relations: ['approvedBy', 'miningSite'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<ProfitDistributions> {
    const entity = await this.repository.findOne({ 
      where: { id },
      relations: ['approvedBy', 'miningSite'],
    });
    if (!entity) {
      throw new NotFoundException(`Profit Distribution with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateProfitDistributionDto): Promise<ProfitDistributions> {
    const entity = await this.findOne(id);
    const updateData: any = { ...updateDto };
    if (updateDto.totalRevenue !== undefined) {
      updateData.totalRevenue = updateDto.totalRevenue.toString();
    }
    if (updateDto.totalExpenses !== undefined) {
      updateData.totalExpenses = updateDto.totalExpenses.toString();
    }
    if (updateDto.totalProfit !== undefined) {
      updateData.totalProfit = updateDto.totalProfit.toString();
    }
    if (updateDto.approvedBy !== undefined) {
      updateData.approvedBy = { id: updateDto.approvedBy };
    }
    Object.assign(entity, updateData);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
