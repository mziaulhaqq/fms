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

  // Convert file paths to full URLs
  private transformProofPhotos(expense: Expenses): Expenses {
    if (expense.proof && Array.isArray(expense.proof)) {
      expense.proof = expense.proof.map(path => {
        // If it's already a URL, return as is
        if (path.startsWith('http')) {
          return path;
        }
        // Convert local path to URL
        const cleanPath = path.replace(/\\/g, '/'); // Replace backslashes with forward slashes
        return `http://192.168.0.165:3000/${cleanPath}`;
      });
    }
    return expense;
  }

  async create(createDto: CreateExpenseDto, userId?: number): Promise<Expenses> {
    const entity = this.repository.create({
      ...createDto,
      amount: createDto.amount.toString(),
    });
    const saved = await this.repository.save(entity);
    return this.transformProofPhotos(saved);
  }

  async findAll(): Promise<Expenses[]> {
    const expenses = await this.repository.find({
      relations: ['category', 'site'],
      order: { createdAt: 'DESC' },
    });
    return expenses.map(expense => this.transformProofPhotos(expense));
  }

  async findOne(id: number): Promise<Expenses> {
    const entity = await this.repository.findOne({ 
      where: { id },
      relations: ['category', 'site'],
    });
    if (!entity) {
      throw new NotFoundException(`Expense with ID ${id} not found`);
    }
    return this.transformProofPhotos(entity);
  }

  async update(id: number, updateDto: UpdateExpenseDto, userId?: number): Promise<Expenses> {
    const entity = await this.findOne(id);
    const updateData = { ...updateDto };
    if (updateDto.amount !== undefined) {
      updateData.amount = updateDto.amount.toString() as any;
    }
    Object.assign(entity, updateData);
    const saved = await this.repository.save(entity);
    return this.transformProofPhotos(saved);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
