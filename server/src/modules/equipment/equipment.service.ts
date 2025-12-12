import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Equipment } from '../../entities/Equipment.entity';
import { CreateEquipmentDto } from './dto/create-equipment.dto';
import { UpdateEquipmentDto } from './dto/update-equipment.dto';

@Injectable()
export class EquipmentService {
  constructor(
    @InjectRepository(Equipment)
    private readonly equipmentRepository: Repository<Equipment>,
  ) {}

  async create(createDto: CreateEquipmentDto, userId?: number): Promise<Equipment> {
    const equipment = this.equipmentRepository.create(createDto);
    if (userId) {
      (equipment as any)._userId = userId;
    }
    return await this.equipmentRepository.save(equipment);
  }

  async findAll(): Promise<Equipment[]> {
    return await this.equipmentRepository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<Equipment> {
    const equipment = await this.equipmentRepository.findOne({ where: { id } });
    if (!equipment) {
      throw new NotFoundException(`Equipment with ID ${id} not found`);
    }
    return equipment;
  }

  async update(id: number, updateDto: UpdateEquipmentDto, userId?: number): Promise<Equipment> {
    const equipment = await this.findOne(id);
    Object.assign(equipment, updateDto);
    if (userId) {
      (equipment as any)._userId = userId;
    }
    return await this.equipmentRepository.save(equipment);
  }

  async remove(id: number): Promise<void> {
    const equipment = await this.findOne(id);
    await this.equipmentRepository.remove(equipment);
  }
}
