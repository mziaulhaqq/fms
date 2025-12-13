import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { Payable } from '../../entities/Payable.entity';
import { CreateLiabilityDto, UpdateLiabilityDto } from './dto';

@Injectable()
export class PayablesService {
  constructor(
    @InjectRepository(Payable)
    private readonly repository: Repository<Payable>,
  ) {}

  async create(createDto: CreateLiabilityDto, userId?: number): Promise<Payable> {
    const entity = this.repository.create({
      type: 'Advance Payment', // Always Advance Payment for payables
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

  async findAll(): Promise<Payable[]> {
    return await this.repository.find({
      relations: ['client', 'miningSite'],
      order: { date: 'DESC' },
    });
  }

  async findByClient(clientId: number): Promise<Payable[]> {
    return await this.repository.find({
      where: { clientId },
      relations: ['miningSite'],
      order: { date: 'DESC' },
    });
  }

  async findActiveByClient(clientId: number): Promise<Payable[]> {
    // Return payables with status 'Active' or 'Partially Used' (i.e., those with remaining balance > 0)
    return await this.repository.find({
      where: { 
        clientId,
        status: In(['Active', 'Partially Used'])
      },
      relations: ['miningSite'],
      order: { date: 'ASC' },
    });
  }

  async findByMiningSite(miningSiteId: number): Promise<Payable[]> {
    return await this.repository.find({
      where: { miningSiteId },
      relations: ['client'],
      order: { date: 'DESC' },
    });
  }

  async findOne(id: number): Promise<Payable> {
    const entity = await this.repository.findOne({
      where: { id },
      relations: ['client', 'miningSite'],
    });
    if (!entity) {
      throw new NotFoundException(`Payable with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateLiabilityDto, userId: number): Promise<Payable> {
    const entity = await this.findOne(id);
    
    // Auto-update status based on remaining balance
    if (updateDto.remainingBalance !== undefined) {
      if (updateDto.remainingBalance <= 0) {
        updateDto.status = 'Fully Used';
      } else if (updateDto.remainingBalance < Number(entity.totalAmount)) {
        updateDto.status = 'Partially Used';
      }
    }

    Object.assign(entity, updateDto);
    entity.modifiedById = userId;
    return await this.repository.save(entity);
  }

  async deductAmount(id: number, amount: number, userId: number): Promise<Payable> {
    const entity = await this.findOne(id);
    const newBalance = Number(entity.remainingBalance) - amount;
    
    return this.update(id, { remainingBalance: Number(newBalance.toFixed(2)) }, userId);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
