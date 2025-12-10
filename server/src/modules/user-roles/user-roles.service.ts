import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserRoles } from '../../entities/UserRoles.entity';
import { CreateUserRoleDto, UpdateUserRoleDto } from './dto';

@Injectable()
export class UserRolesService {
  constructor(
    @InjectRepository(UserRoles)
    private readonly repository: Repository<UserRoles>,
  ) {}

  async create(createDto: CreateUserRoleDto): Promise<UserRoles> {
    const entity = this.repository.create(createDto);
    return await this.repository.save(entity);
  }

  async findAll(): Promise<UserRoles[]> {
    return await this.repository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<UserRoles> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`User Role with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateUserRoleDto): Promise<UserRoles> {
    const entity = await this.findOne(id);
    Object.assign(entity, updateDto);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
