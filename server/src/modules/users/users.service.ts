import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Users } from '../../entities/Users.entity';
import { CreateUserDto, UpdateUserDto } from './dto';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(Users)
    private readonly repository: Repository<Users>,
  ) {}

  async create(createDto: CreateUserDto): Promise<Users> {
    // Check if username or email already exists
    const existingUser = await this.repository.findOne({
      where: [
        { username: createDto.username },
        { email: createDto.email }
      ]
    });

    if (existingUser) {
      if (existingUser.username === createDto.username) {
        throw new ConflictException('Username already exists');
      }
      if (existingUser.email === createDto.email) {
        throw new ConflictException('Email already exists');
      }
    }

    // Hash the password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(createDto.password, saltRounds);

    const entity = this.repository.create({
      username: createDto.username,
      email: createDto.email,
      passwordHash: hashedPassword,
      fullName: createDto.fullName,
      phone: createDto.phone,
      isActive: createDto.isActive ?? true,
    });

    const savedUser = await this.repository.save(entity);
    
    // Remove password hash from response
    const { passwordHash: _, ...userWithoutPassword } = savedUser;
    return userWithoutPassword as Users;
  }

  async findAll(): Promise<Users[]> {
    const users = await this.repository.find({
      order: { createdAt: 'DESC' },
    });
    
    // Remove password hashes from response
    return users.map(user => {
      const { passwordHash: _, ...userWithoutPassword } = user;
      return userWithoutPassword as Users;
    });
  }

  async findOne(id: number): Promise<Users> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    
    // Remove password hash from response
    const { passwordHash: _, ...userWithoutPassword } = entity;
    return userWithoutPassword as Users;
  }

  async update(id: number, updateDto: UpdateUserDto): Promise<Users> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }

    // Check if username or email is being changed and already exists
    if (updateDto.username && updateDto.username !== entity.username) {
      const existingUser = await this.repository.findOne({
        where: { username: updateDto.username }
      });
      if (existingUser) {
        throw new ConflictException('Username already exists');
      }
    }

    if (updateDto.email && updateDto.email !== entity.email) {
      const existingUser = await this.repository.findOne({
        where: { email: updateDto.email }
      });
      if (existingUser) {
        throw new ConflictException('Email already exists');
      }
    }

    // Hash password if it's being updated
    if (updateDto.password) {
      const saltRounds = 10;
      entity.passwordHash = await bcrypt.hash(updateDto.password, saltRounds);
    }

    // Update other fields
    if (updateDto.username) entity.username = updateDto.username;
    if (updateDto.email) entity.email = updateDto.email;
    if (updateDto.fullName) entity.fullName = updateDto.fullName;
    if (updateDto.phone !== undefined) entity.phone = updateDto.phone;
    if (updateDto.isActive !== undefined) entity.isActive = updateDto.isActive;

    const savedUser = await this.repository.save(entity);
    
    // Remove password hash from response
    const { passwordHash: _, ...userWithoutPassword } = savedUser;
    return userWithoutPassword as Users;
  }

  async remove(id: number): Promise<void> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    await this.repository.remove(entity);
  }

  // Additional admin methods
  async toggleUserStatus(id: number): Promise<Users> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    
    entity.isActive = !entity.isActive;
    const savedUser = await this.repository.save(entity);
    
    const { passwordHash: _, ...userWithoutPassword } = savedUser;
    return userWithoutPassword as Users;
  }
}
