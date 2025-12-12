import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ExpenseType } from '../../entities/ExpenseType.entity';
import { CreateExpenseTypeDto, UpdateExpenseTypeDto } from './dto';

@Injectable()
export class ExpenseTypesService {
  constructor(
    @InjectRepository(ExpenseType)
    private readonly repository: Repository<ExpenseType>,
  ) {}

  async create(createDto: CreateExpenseTypeDto, userId?: number): Promise<ExpenseType> {
    // Check for duplicate name
    const existing = await this.repository.findOne({ where: { name: createDto.name } });
    if (existing) {
      throw new ConflictException(`Expense type with name "${createDto.name}" already exists`);
    }

    const entity = this.repository.create({
      ...createDto,
      createdById: userId,
      modifiedById: userId,
    });
    return await this.repository.save(entity);
  }

  async findAll(): Promise<ExpenseType[]> {
    return await this.repository.find({
      order: { name: 'ASC' },
    });
  }

  async findActive(): Promise<ExpenseType[]> {
    return await this.repository.find({
      where: { isActive: true },
      order: { name: 'ASC' },
    });
  }

  async findOne(id: number): Promise<ExpenseType> {
    const entity = await this.repository.findOne({
      where: { id },
    });
    if (!entity) {
      throw new NotFoundException(`Expense type with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateExpenseTypeDto, userId: number): Promise<ExpenseType> {
    const entity = await this.findOne(id);

    // Check for duplicate name if name is being updated
    if (updateDto.name && updateDto.name !== entity.name) {
      const existing = await this.repository.findOne({ where: { name: updateDto.name } });
      if (existing) {
        throw new ConflictException(`Expense type with name "${updateDto.name}" already exists`);
      }
    }

    Object.assign(entity, updateDto);
    entity.modifiedById = userId;
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
