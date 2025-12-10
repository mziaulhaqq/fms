import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Production } from '../../entities/Production.entity';
import { CreateProductionDto } from './dto/create-production.dto';
import { UpdateProductionDto } from './dto/update-production.dto';

@Injectable()
export class ProductionService {
  constructor(
    @InjectRepository(Production)
    private readonly productionRepository: Repository<Production>,
  ) {}

  async create(createProductionDto: CreateProductionDto): Promise<Production> {
    const production = this.productionRepository.create(createProductionDto);
    return await this.productionRepository.save(production);
  }

  async findAll(): Promise<Production[]> {
    return await this.productionRepository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<Production> {
    const production = await this.productionRepository.findOne({ where: { id } });
    if (!production) {
      throw new NotFoundException(`Production with ID ${id} not found`);
    }
    return production;
  }

  async update(id: number, updateProductionDto: UpdateProductionDto): Promise<Production> {
    const production = await this.findOne(id);
    Object.assign(production, updateProductionDto);
    return await this.productionRepository.save(production);
  }

  async remove(id: number): Promise<void> {
    const production = await this.findOne(id);
    await this.productionRepository.remove(production);
  }
}
