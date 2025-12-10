import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Labor } from '../../entities/Labor.entity';
import { CreateLaborDto, UpdateLaborDto } from './dto';

@Injectable()
export class LaborsService {
  constructor(
    @InjectRepository(Labor)
    private readonly repository: Repository<Labor>,
  ) {}

  // Transform Labor entity to match mobile app's Worker model
  private transformToWorkerModel(labor: Labor) {
    return {
      id: labor.id,
      fullName: labor.name,
      employeeId: labor.cnic, // Using CNIC as employee ID
      role: null, // Not in current schema
      team: null, // Not in current schema
      phone: labor.phone,
      email: null, // Not in current schema
      status: labor.status, // 'active' or 'inactive'
      isActive: labor.status === 'active',
      hireDate: labor.onboardingDate || labor.startDate,
      photoUrl: null, // Not in current schema
      supervisedBy: labor.supervisedBy,
    };
  }

  // Transform mobile app's Worker data to Labor entity
  private transformFromWorkerModel(workerData: any) {
    return {
      name: workerData.fullName,
      cnic: workerData.employeeId || 'N/A',
      phone: workerData.phone,
      status: workerData.status || 'active',
      onboardingDate: workerData.hireDate,
      startDate: workerData.hireDate || new Date().toISOString().split('T')[0],
      siteId: 1, // Default site ID - should be updated based on your business logic
      supervisedBy: workerData.supervisedBy,
    };
  }

  async create(createDto: CreateLaborDto): Promise<any> {
    const laborData = this.transformFromWorkerModel(createDto);
    const entity = this.repository.create(laborData as Partial<Labor>);
    const saved: Labor = await this.repository.save(entity);
    return this.transformToWorkerModel(saved);
  }

  async findAll(): Promise<any[]> {
    const entities = await this.repository.find({
      order: { createdAt: 'DESC' },
    });
    return entities.map(entity => this.transformToWorkerModel(entity));
  }

  async findOne(id: number): Promise<any> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Worker with ID ${id} not found`);
    }
    return this.transformToWorkerModel(entity);
  }

  async update(id: number, updateDto: UpdateLaborDto): Promise<any> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Worker with ID ${id} not found`);
    }
    const laborData = this.transformFromWorkerModel(updateDto);
    Object.assign(entity, laborData);
    const saved: Labor = await this.repository.save(entity);
    return this.transformToWorkerModel(saved);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Worker with ID ${id} not found`);
    }
    await this.repository.remove(entity);
  }
}
