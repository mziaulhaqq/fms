import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ExpenseCategory } from '../../entities/expense-category.entity';
import { CreateExpenseCategoryDto, UpdateExpenseCategoryDto } from './dto';

@Injectable()
export class ExpenseCategorysService {
  constructor(
    @InjectRepository(ExpenseCategory)
    private readonly repository: Repository<ExpenseCategory>,
  ) {}

  async create(createDto: CreateExpenseCategoryDto): Promise<ExpenseCategory> {
    const entity = this.repository.create(createDto);
    return await this.repository.save(entity);
  }

  async findAll(): Promise<ExpenseCategory[]> {
    return await this.repository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<ExpenseCategory> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Expense Category with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateExpenseCategoryDto): Promise<ExpenseCategory> {
    const entity = await this.findOne(id);
    Object.assign(entity, updateDto);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
