import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { MiningSite } from './mining-site.entity';

@Entity({ schema: 'coal_mining', name: 'site_supervisors' })
export class SiteSupervisor {
  @ApiProperty({ description: 'Unique identifier' })
  @PrimaryGeneratedColumn()
  id: number;

  @ApiProperty({ description: 'Supervisor name' })
  @Column({ length: 255 })
  name: string;

  @ApiProperty({ description: 'Contact information', required: false })
  @Column({ length: 100, nullable: true })
  contact: string;

  @ApiProperty({ description: 'Mining site ID', required: false })
  @Column({ name: 'site_id', nullable: true })
  siteId: number;

  @ApiProperty({ description: 'Record creation timestamp' })
  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ApiProperty({ description: 'Record update timestamp' })
  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => MiningSite, site => site.supervisors)
  @JoinColumn({ name: 'site_id' })
  site: MiningSite;
}
