import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AccountType } from '../../entities/AccountType.entity';
import { CreateAccountTypeDto, UpdateAccountTypeDto } from './dto';

@Injectable()
export class AccountTypesService {
  constructor(
    @InjectRepository(AccountType)
    private readonly repository: Repository<AccountType>,
  ) {}

  async create(createDto: CreateAccountTypeDto, userId: number): Promise<AccountType> {
    // Check for duplicate name
    const existing = await this.repository.findOne({ where: { name: createDto.name } });
    if (existing) {
      throw new ConflictException(`Account type with name "${createDto.name}" already exists`);
    }

    const entity = this.repository.create({
      ...createDto,
      createdById: userId,
      modifiedById: userId,
    });
    return await this.repository.save(entity);
  }

  async findAll(): Promise<AccountType[]> {
    return await this.repository.find({
      relations: ['createdBy', 'modifiedBy'],
      order: { name: 'ASC' },
    });
  }

  async findActive(): Promise<AccountType[]> {
    return await this.repository.find({
      where: { isActive: true },
      order: { name: 'ASC' },
    });
  }

  async findOne(id: number): Promise<AccountType> {
    const entity = await this.repository.findOne({
      where: { id },
      relations: ['createdBy', 'modifiedBy'],
    });
    if (!entity) {
      throw new NotFoundException(`Account type with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateAccountTypeDto, userId: number): Promise<AccountType> {
    const entity = await this.findOne(id);

    // Check for duplicate name if name is being updated
    if (updateDto.name && updateDto.name !== entity.name) {
      const existing = await this.repository.findOne({ where: { name: updateDto.name } });
      if (existing) {
        throw new ConflictException(`Account type with name "${updateDto.name}" already exists`);
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
