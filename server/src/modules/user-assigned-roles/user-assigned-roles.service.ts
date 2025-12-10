import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserAssignedRole } from '../../entities/user-assigned-role.entity';
import { CreateUserAssignedRoleDto, UpdateUserAssignedRoleDto } from './dto';

@Injectable()
export class UserAssignedRolesService {
  constructor(
    @InjectRepository(UserAssignedRole)
    private readonly repository: Repository<UserAssignedRole>,
  ) {}

  async create(createDto: CreateUserAssignedRoleDto): Promise<UserAssignedRole> {
    const entity = this.repository.create(createDto);
    return await this.repository.save(entity);
  }

  async findAll(): Promise<UserAssignedRole[]> {
    return await this.repository.find({
      order: { assignedAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<UserAssignedRole> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`User Assigned Role with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateUserAssignedRoleDto): Promise<UserAssignedRole> {
    const entity = await this.findOne(id);
    Object.assign(entity, updateDto);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
