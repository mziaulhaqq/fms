import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Expenses } from '../../entities/Expenses.entity';
import { CreateExpenseDto, UpdateExpenseDto } from './dto';

@Injectable()
export class ExpensesService {
  constructor(
    @InjectRepository(Expenses)
    private readonly repository: Repository<Expenses>,
  ) {}

  async create(createDto: CreateExpenseDto): Promise<Expenses> {
    const entity = this.repository.create({
      ...createDto,
      amount: createDto.amount.toString(),
    });
    return await this.repository.save(entity);
  }

  async findAll(): Promise<Expenses[]> {
    return await this.repository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<Expenses> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Expense with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateExpenseDto): Promise<Expenses> {
    const entity = await this.findOne(id);
    const updateData = { ...updateDto };
    if (updateDto.amount !== undefined) {
      updateData.amount = updateDto.amount.toString() as any;
    }
    Object.assign(entity, updateData);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
