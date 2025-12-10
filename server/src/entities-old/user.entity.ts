import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { UserAssignedRole } from './user-assigned-role.entity';

@Entity({ schema: 'coal_mining', name: 'users' })
export class User {
  @ApiProperty({ description: 'Unique identifier' })
  @PrimaryGeneratedColumn()
  id: number;

  @ApiProperty({ description: 'Username' })
  @Column({ length: 100, unique: true })
  username: string;

  @ApiProperty({ description: 'Email address' })
  @Column({ length: 255, unique: true })
  email: string;

  @ApiProperty({ description: 'Password hash', writeOnly: true })
  @Column({ length: 255, name: 'password_hash' })
  passwordHash: string;

  @ApiProperty({ description: 'Full name', required: false })
  @Column({ length: 255, nullable: true, name: 'full_name' })
  fullName: string;

  @ApiProperty({ description: 'Account status', required: false })
  @Column({ length: 50, nullable: true, default: 'active' })
  status: string;

  @ApiProperty({ description: 'Record creation timestamp' })
  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ApiProperty({ description: 'Record update timestamp' })
  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @OneToMany(() => UserAssignedRole, userRole => userRole.user)
  assignedRoles: UserAssignedRole[];
}
