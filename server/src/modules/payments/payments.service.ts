import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { Payment } from '../../entities/Payment.entity';
import { Payable } from '../../entities/Payable.entity';
import { Receivable } from '../../entities/Receivable.entity';
import { CreatePaymentDto, UpdatePaymentDto } from './dto';

@Injectable()
export class PaymentsService {
  constructor(
    @InjectRepository(Payment)
    private readonly repository: Repository<Payment>,
    @InjectRepository(Payable)
    private readonly payableRepository: Repository<Payable>,
    @InjectRepository(Receivable)
    private readonly receivableRepository: Repository<Receivable>,
    private readonly dataSource: DataSource,
  ) {}

  async create(createDto: CreatePaymentDto, userId?: number): Promise<Payment> {
    return await this.dataSource.transaction(async (manager) => {
      // Validate and update payable or receivable
      if (createDto.paymentType === 'Payable Deduction' && createDto.payableId) {
        const payable = await manager.findOne(Payable, {
          where: { id: createDto.payableId },
        });

        if (!payable) {
          throw new NotFoundException(`Payable with ID ${createDto.payableId} not found`);
        }

        const remainingBalance = parseFloat(payable.remainingBalance);
        if (createDto.amount > remainingBalance) {
          throw new BadRequestException(
            `Payment amount ($${createDto.amount}) exceeds payable remaining balance ($${remainingBalance})`
          );
        }

        // Update payable balance
        const newBalance = remainingBalance - createDto.amount;
        payable.remainingBalance = String(newBalance);
        
        if (newBalance === 0) {
          payable.status = 'Fully Used';
        } else if (newBalance < parseFloat(payable.totalAmount)) {
          payable.status = 'Partially Used';
        }

        await manager.save(Payable, payable);
      } else if (createDto.paymentType === 'Receivable Payment' && createDto.receivableId) {
        const receivable = await manager.findOne(Receivable, {
          where: { id: createDto.receivableId },
        });

        if (!receivable) {
          throw new NotFoundException(`Receivable with ID ${createDto.receivableId} not found`);
        }

        const remainingBalance = parseFloat(receivable.remainingBalance);
        if (createDto.amount > remainingBalance) {
          throw new BadRequestException(
            `Payment amount ($${createDto.amount}) exceeds receivable remaining balance ($${remainingBalance})`
          );
        }

        // Update receivable balance
        const newBalance = remainingBalance - createDto.amount;
        receivable.remainingBalance = String(newBalance);
        
        if (newBalance === 0) {
          receivable.status = 'Fully Paid';
        } else if (newBalance < parseFloat(receivable.totalAmount)) {
          receivable.status = 'Partially Paid';
        }

        await manager.save(Receivable, receivable);
      }

      // Create payment record
      const entity = manager.create(Payment, {
        clientId: createDto.clientId,
        miningSiteId: createDto.miningSiteId,
        paymentType: createDto.paymentType,
        payableId: createDto.payableId || null,
        receivableId: createDto.receivableId || null,
        amount: createDto.amount.toString(),
        paymentDate: createDto.paymentDate,
        paymentMethod: createDto.paymentMethod,
        proof: createDto.proof,
        receivedBy: createDto.receivedBy,
        notes: createDto.notes,
        createdBy: userId || null,
      });

      return await manager.save(Payment, entity);
    });
  }

  async findAll(): Promise<Payment[]> {
    return await this.repository.find({
      relations: ['client', 'miningSite', 'payable', 'receivable'],
      order: { paymentDate: 'DESC' },
    });
  }

  async findByClient(clientId: number): Promise<Payment[]> {
    return await this.repository.find({
      where: { clientId },
      relations: ['miningSite', 'payable', 'receivable'],
      order: { paymentDate: 'DESC' },
    });
  }

  async findByMiningSite(miningSiteId: number): Promise<Payment[]> {
    return await this.repository.find({
      where: { miningSiteId },
      relations: ['client', 'creator'],
      order: { paymentDate: 'DESC' },
    });
  }

  async findByType(paymentType: 'Payable Deduction' | 'Receivable Payment'): Promise<Payment[]> {
    return await this.repository.find({
      where: { paymentType },
      relations: ['client', 'miningSite', 'creator'],
      order: { paymentDate: 'DESC' },
    });
  }

  async findByPayable(payableId: number): Promise<Payment[]> {
    return await this.repository.find({
      where: { payableId },
      relations: ['client', 'miningSite', 'payable', 'creator'],
      order: { paymentDate: 'DESC' },
    });
  }

  async findByReceivable(receivableId: number): Promise<Payment[]> {
    return await this.repository.find({
      where: { receivableId },
      relations: ['client', 'miningSite', 'receivable', 'creator'],
      order: { paymentDate: 'DESC' },
    });
  }

  async findOne(id: number): Promise<Payment> {
    const entity = await this.repository.findOne({
      where: { id },
      relations: ['client', 'miningSite', 'creator'],
    });
    if (!entity) {
      throw new NotFoundException(`Payment with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdatePaymentDto, userId: number): Promise<Payment> {
    const entity = await this.findOne(id);
    
    // Convert amount to string if provided
    const data: any = { ...updateDto };
    if (updateDto.amount !== undefined) {
      data.amount = String(updateDto.amount);
    }

    Object.assign(entity, data);
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
