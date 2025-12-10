import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TruckDelivery } from '../../entities/truck-delivery.entity';
import { CreateTruckDeliveryDto, UpdateTruckDeliveryDto } from './dto';

@Injectable()
export class TruckDeliverysService {
  constructor(
    @InjectRepository(TruckDelivery)
    private readonly repository: Repository<TruckDelivery>,
  ) {}

  async create(createDto: CreateTruckDeliveryDto): Promise<TruckDelivery> {
    const entity = this.repository.create(createDto);
    return await this.repository.save(entity);
  }

  async findAll(): Promise<TruckDelivery[]> {
    return await this.repository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<TruckDelivery> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Truck Delivery with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateTruckDeliveryDto): Promise<TruckDelivery> {
    const entity = await this.findOne(id);
    Object.assign(entity, updateDto);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
