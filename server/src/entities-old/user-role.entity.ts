import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { UserAssignedRole } from './user-assigned-role.entity';

@Entity({ schema: 'coal_mining', name: 'user_roles' })
export class UserRole {
  @ApiProperty({ description: 'Unique identifier' })
  @PrimaryGeneratedColumn()
  id: number;

  @ApiProperty({ description: 'Role name' })
  @Column({ length: 100, unique: true, name: 'role_name' })
  roleName: string;

  @ApiProperty({ description: 'Role description', required: false })
  @Column({ type: 'text', nullable: true })
  description: string;

  @ApiProperty({ description: 'Record creation timestamp' })
  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ApiProperty({ description: 'Record update timestamp' })
  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @OneToMany(() => UserAssignedRole, userAssignedRole => userAssignedRole.role)
  assignedUsers: UserAssignedRole[];
}
