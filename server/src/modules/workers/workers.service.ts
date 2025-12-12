import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Worker } from '../../entities/Worker.entity';
import { CreateLaborDto, UpdateLaborDto } from './dto';

@Injectable()
export class LaborsService {
  constructor(
    @InjectRepository(Worker)
    private readonly repository: Repository<Worker>,
  ) {}

  // Transform Worker entity to match mobile app's Worker model
  private transformToWorkerModel(worker: Worker) {
    return {
      id: worker.id,
      fullName: worker.name,
      employeeId: worker.cnic, // Using CNIC as employee ID
      role: null, // Not in current schema
      team: null, // Not in current schema
      phone: worker.phone,
      email: null, // Not in current schema
      status: worker.status, // 'active' or 'inactive'
      isActive: worker.status === 'active',
      hireDate: worker.onboardingDate || worker.startDate,
      photoUrl: null, // Not in current schema
      supervisorId: worker.supervisorId,
      supervisorName: worker.supervisor?.name || null,
      fatherName: worker.fatherName,
      address: worker.address,
      mobileNumber: worker.mobileNumber,
      emergencyNumber: worker.emergencyNumber,
      startDate: worker.startDate,
      endDate: worker.endDate,
      dailyWage: worker.dailyWage ? parseFloat(worker.dailyWage) : null,
      notes: worker.notes,
      otherDetail: worker.otherDetail,
    };
  }

  // Transform mobile app's Worker data to Worker entity
  private transformFromWorkerModel(workerData: any) {
    return {
      name: workerData.fullName,
      cnic: workerData.employeeId || 'N/A',
      phone: workerData.phone,
      status: workerData.status || 'active',
      onboardingDate: workerData.hireDate,
      startDate: workerData.startDate || workerData.hireDate || new Date().toISOString().split('T')[0],
      siteId: 1, // Default site ID - should be updated based on your business logic
      supervisorId: workerData.supervisorId || null,
      fatherName: workerData.fatherName || null,
      address: workerData.address || null,
      mobileNumber: workerData.mobileNumber || null,
      emergencyNumber: workerData.emergencyNumber || null,
      endDate: workerData.endDate || null,
      dailyWage: workerData.dailyWage ? workerData.dailyWage.toString() : null,
      notes: workerData.notes || null,
      otherDetail: workerData.otherDetail || null,
    };
  }

  async create(createDto: CreateLaborDto, userId?: number): Promise<any> {
    const laborData = this.transformFromWorkerModel(createDto);
    const entity = this.repository.create(laborData as Partial<Worker>);
    if (userId) {
      (entity as any)._userId = userId;
    }
    const saved: Worker = await this.repository.save(entity);
    return this.transformToWorkerModel(saved);
  }

  async findAll(): Promise<any[]> {
    const entities = await this.repository.find({
      relations: ['supervisor'],
      order: { createdAt: 'DESC' },
    });
    return entities.map(entity => this.transformToWorkerModel(entity));
  }

  async findOne(id: number): Promise<any> {
    const entity = await this.repository.findOne({ 
      where: { id },
      relations: ['supervisor'],
    });
    if (!entity) {
      throw new NotFoundException(`Worker with ID ${id} not found`);
    }
    return this.transformToWorkerModel(entity);
  }

  async update(id: number, updateDto: UpdateLaborDto, userId?: number): Promise<any> {
    const entity = await this.repository.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Worker with ID ${id} not found`);
    }
    const laborData = this.transformFromWorkerModel(updateDto);
    Object.assign(entity, laborData);
    if (userId) {
      (entity as any)._userId = userId;
    }
    const saved: Worker = await this.repository.save(entity);
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
