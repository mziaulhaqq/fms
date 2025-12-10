import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { User } from './user.entity';
import { UserRole } from './user-role.entity';

@Entity({ schema: 'coal_mining', name: 'user_assigned_roles' })
export class UserAssignedRole {
  @ApiProperty({ description: 'Unique identifier' })
  @PrimaryGeneratedColumn()
  id: number;

  @ApiProperty({ description: 'User ID' })
  @Column({ name: 'user_id' })
  userId: number;

  @ApiProperty({ description: 'Role ID' })
  @Column({ name: 'role_id' })
  roleId: number;

  @ApiProperty({ description: 'Assignment date' })
  @CreateDateColumn({ name: 'assigned_at' })
  assignedAt: Date;

  @ManyToOne(() => User, user => user.assignedRoles)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @ManyToOne(() => UserRole, role => role.assignedUsers)
  @JoinColumn({ name: 'role_id' })
  role: UserRole;
}
