import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserAssignedRoles } from '../../entities/UserAssignedRoles.entity';
import { CreateUserAssignedRoleDto, UpdateUserAssignedRoleDto } from './dto';

@Injectable()
export class UserAssignedRolesService {
  constructor(
    @InjectRepository(UserAssignedRoles)
    private readonly repository: Repository<UserAssignedRoles>,
  ) {}

  async create(createDto: CreateUserAssignedRoleDto): Promise<UserAssignedRoles> {
    const entity = this.repository.create({
      userId: createDto.userId,
      roleId: createDto.roleId,
      status: createDto.status || 'active',
      updatedComment: createDto.updatedComment,
    });
    return await this.repository.save(entity);
  }

  async findAll(): Promise<UserAssignedRoles[]> {
    return await this.repository.find({
      order: { assignedAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<UserAssignedRoles> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`User Assigned Role with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateUserAssignedRoleDto): Promise<UserAssignedRoles> {
    const entity = await this.findOne(id);
    Object.assign(entity, updateDto);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
