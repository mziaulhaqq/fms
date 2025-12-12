import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Receivable } from '../../entities/Receivable.entity';
import { CreateReceivableDto, UpdateReceivableDto } from './dto';

@Injectable()
export class ReceivablesService {
  constructor(
    @InjectRepository(Receivable)
    private readonly repository: Repository<Receivable>,
  ) {}

  async create(createDto: CreateReceivableDto, userId?: number): Promise<Receivable> {
    const entity = this.repository.create({
      clientId: createDto.clientId,
      miningSiteId: createDto.miningSiteId,
      date: createDto.date,
      description: createDto.description,
      totalAmount: createDto.totalAmount.toString(),
      remainingBalance: createDto.totalAmount.toString(),
      status: 'Pending',
      createdById: userId,
      modifiedById: userId,
    });
    return await this.repository.save(entity);
  }

  async findAll(): Promise<Receivable[]> {
    return await this.repository.find({
      relations: ['client', 'miningSite'],
      order: { date: 'DESC' },
    });
  }

  async findByClient(clientId: number): Promise<Receivable[]> {
    return await this.repository.find({
      where: { clientId },
      relations: ['miningSite'],
      order: { date: 'DESC' },
    });
  }

  async findPendingByClient(clientId: number): Promise<Receivable[]> {
    return await this.repository.find({
      where: { 
        clientId,
        status: 'Pending'
      },
      relations: ['miningSite'],
      order: { date: 'ASC' },
    });
  }

  async findByMiningSite(miningSiteId: number): Promise<Receivable[]> {
    return await this.repository.find({
      where: { miningSiteId },
      relations: ['client'],
      order: { date: 'DESC' },
    });
  }

  async findOne(id: number): Promise<Receivable> {
    const entity = await this.repository.findOne({
      where: { id },
      relations: ['client', 'miningSite'],
    });
    if (!entity) {
      throw new NotFoundException(`Receivable with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateReceivableDto, userId: number): Promise<Receivable> {
    const entity = await this.findOne(id);
    
    // Auto-update status based on remaining balance
    if (updateDto.remainingBalance !== undefined) {
      if (updateDto.remainingBalance <= 0) {
        updateDto.status = 'Fully Paid';
      } else if (updateDto.remainingBalance < Number(entity.totalAmount)) {
        updateDto.status = 'Partially Paid';
      }
    }

    Object.assign(entity, updateDto);
    entity.modifiedById = userId;
    return await this.repository.save(entity);
  }

  async recordPayment(id: number, amount: number, userId: number): Promise<Receivable> {
    const entity = await this.findOne(id);
    const newBalance = Number(entity.remainingBalance) - amount;
    
    return this.update(id, { remainingBalance: Number(newBalance.toFixed(2)) }, userId);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
