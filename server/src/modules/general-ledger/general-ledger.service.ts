import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { GeneralLedger } from '../../entities/GeneralLedger.entity';
import { CreateGeneralLedgerDto, UpdateGeneralLedgerDto } from './dto';

@Injectable()
export class GeneralLedgerService {
  constructor(
    @InjectRepository(GeneralLedger)
    private readonly repository: Repository<GeneralLedger>,
  ) {}

  async create(createDto: CreateGeneralLedgerDto, userId: number): Promise<GeneralLedger> {
    // Check for duplicate account code in the same mining site
    const existing = await this.repository.findOne({
      where: {
        accountCode: createDto.accountCode,
        miningSiteId: createDto.miningSiteId,
      },
    });
    if (existing) {
      throw new ConflictException(
        `Account code "${createDto.accountCode}" already exists in this mining site`,
      );
    }

    const entity = this.repository.create({
      ...createDto,
      createdById: userId,
      modifiedById: userId,
    });
    return await this.repository.save(entity);
  }

  async findAll(): Promise<GeneralLedger[]> {
    return await this.repository.find({
      relations: ['accountType', 'miningSite'],
      order: { accountCode: 'ASC' },
    });
  }

  async findByMiningSite(miningSiteId: number): Promise<GeneralLedger[]> {
    return await this.repository.find({
      where: { miningSiteId },
      relations: ['accountType'],
      order: { accountCode: 'ASC' },
    });
  }

  async findByAccountType(accountTypeId: number): Promise<GeneralLedger[]> {
    return await this.repository.find({
      where: { accountTypeId },
      relations: ['miningSite'],
      order: { accountCode: 'ASC' },
    });
  }

  async findOne(id: number): Promise<GeneralLedger> {
    const entity = await this.repository.findOne({
      where: { id },
      relations: ['accountType', 'miningSite'],
    });
    if (!entity) {
      throw new NotFoundException(`General ledger account with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateGeneralLedgerDto, userId: number): Promise<GeneralLedger> {
    const entity = await this.findOne(id);

    // Check for duplicate account code if being updated
    if (updateDto.accountCode && updateDto.accountCode !== entity.accountCode) {
      const existing = await this.repository.findOne({
        where: {
          accountCode: updateDto.accountCode,
          miningSiteId: updateDto.miningSiteId || entity.miningSiteId,
        },
      });
      if (existing && existing.id !== id) {
        throw new ConflictException(
          `Account code "${updateDto.accountCode}" already exists in this mining site`,
        );
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
