import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Liability } from '../../entities/Liability.entity';
import { CreateLiabilityDto, UpdateLiabilityDto } from './dto';

@Injectable()
export class LiabilitiesService {
  constructor(
    @InjectRepository(Liability)
    private readonly repository: Repository<Liability>,
  ) {}

  async create(createDto: CreateLiabilityDto, userId?: number): Promise<Liability> {
    const entity = this.repository.create({
      type: createDto.type,
      clientId: createDto.clientId,
      miningSiteId: createDto.miningSiteId,
      date: createDto.date,
      description: createDto.description,
      totalAmount: createDto.totalAmount.toString(),
      remainingBalance: createDto.totalAmount.toString(),
      status: 'Active',
      proof: createDto.proof,
      createdById: userId,
      modifiedById: userId,
    });
    return await this.repository.save(entity);
  }

  async findAll(): Promise<Liability[]> {
    return await this.repository.find({
      relations: ['client', 'miningSite'],
      order: { date: 'DESC' },
    });
  }

  async findByClient(clientId: number): Promise<Liability[]> {
    return await this.repository.find({
      where: { clientId },
      relations: ['miningSite'],
      order: { date: 'DESC' },
    });
  }

  async findActiveByClient(clientId: number): Promise<Liability[]> {
    return await this.repository.find({
      where: { 
        clientId,
        status: 'Active'
      },
      relations: ['miningSite'],
      order: { date: 'ASC' },
    });
  }

  async findByMiningSite(miningSiteId: number): Promise<Liability[]> {
    return await this.repository.find({
      where: { miningSiteId },
      relations: ['client'],
      order: { date: 'DESC' },
    });
  }

  async findByType(type: 'Loan' | 'Advanced Payment'): Promise<Liability[]> {
    return await this.repository.find({
      where: { type },
      relations: ['client', 'miningSite'],
      order: { date: 'DESC' },
    });
  }

  async findOne(id: number): Promise<Liability> {
    const entity = await this.repository.findOne({
      where: { id },
      relations: ['client', 'miningSite'],
    });
    if (!entity) {
      throw new NotFoundException(`Liability with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateLiabilityDto, userId: number): Promise<Liability> {
    const entity = await this.findOne(id);
    
    // Auto-update status based on remaining balance
    if (updateDto.remainingBalance !== undefined) {
      if (updateDto.remainingBalance <= 0) {
        updateDto.status = 'Fully Settled';
      } else if (updateDto.remainingBalance < Number(entity.totalAmount)) {
        updateDto.status = 'Partially Settled';
      }
    }

    Object.assign(entity, updateDto);
    entity.modifiedById = userId;
    return await this.repository.save(entity);
  }

  async deductAmount(id: number, amount: number, userId: number): Promise<Liability> {
    const entity = await this.findOne(id);
    const newBalance = Number(entity.remainingBalance) - amount;
    
    return this.update(id, { remainingBalance: Number(newBalance.toFixed(2)) }, userId);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
