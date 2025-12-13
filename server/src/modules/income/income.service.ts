import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { Income } from '../../entities/Income.entity';
import { Payable } from '../../entities/Payable.entity';
import { Receivable } from '../../entities/Receivable.entity';
import { CreateIncomeDto, UpdateIncomeDto } from './dto';

@Injectable()
export class IncomesService {
  constructor(
    @InjectRepository(Income)
    private readonly repository: Repository<Income>,
    @InjectRepository(Payable)
    private readonly payableRepository: Repository<Payable>,
    @InjectRepository(Receivable)
    private readonly receivableRepository: Repository<Receivable>,
    private readonly dataSource: DataSource,
  ) {}

  async create(createDto: CreateIncomeDto, userId?: number): Promise<Income> {
    // Use transaction to ensure data consistency
    return await this.dataSource.transaction(async (manager) => {
      // Convert numeric values to strings for the entity
      const data: any = {
        ...createDto,
        coalPrice: String(createDto.coalPrice),
        companyCommission: createDto.companyCommission ? String(createDto.companyCommission) : null,
        quantityTons: createDto.quantityTons ? String(createDto.quantityTons) : null,
        totalPrice: createDto.totalPrice ? String(createDto.totalPrice) : null,
        amountFromLiability: createDto.amountFromLiability ? String(createDto.amountFromLiability) : null,
        amountCash: createDto.amountCash ? String(createDto.amountCash) : null,
      };

      const entity = manager.create(Income, data);
      if (userId) {
        (entity as any)._userId = userId;
      }

      const savedIncome = await manager.save(Income, entity);

      // Handle payable deduction if liabilityId (payableId) and amountFromLiability are provided
      if (createDto.liabilityId && createDto.amountFromLiability) {
        const payable = await manager.findOne(Payable, {
          where: { id: createDto.liabilityId },
        });

        if (!payable) {
          throw new NotFoundException(`Payable with ID ${createDto.liabilityId} not found`);
        }

        const amountFromPayable = parseFloat(String(createDto.amountFromLiability));
        const previousBalance = parseFloat(payable.remainingBalance);

        if (amountFromPayable > previousBalance) {
          throw new BadRequestException(
            `Amount from payable ($${amountFromPayable}) exceeds remaining balance ($${previousBalance})`
          );
        }

        const newBalance = previousBalance - amountFromPayable;

        // Update payable remaining balance
        payable.remainingBalance = String(newBalance);
        
        // Update status based on new balance
        if (newBalance === 0) {
          payable.status = 'Fully Used';
        } else if (newBalance < parseFloat(payable.totalAmount)) {
          payable.status = 'Partially Used';
        }

        await manager.save(Payable, payable);

        // TODO: Create payable transaction record when PayableTransaction entity is created
      }

      // Calculate outstanding amount and create receivable if needed
      const coalPrice = parseFloat(String(createDto.coalPrice));
      const companyCommission = createDto.companyCommission ? parseFloat(String(createDto.companyCommission)) : 0;
      const netIncome = coalPrice - companyCommission;
      
      const amountFromPayable = createDto.amountFromLiability ? parseFloat(String(createDto.amountFromLiability)) : 0;
      const amountCash = createDto.amountCash ? parseFloat(String(createDto.amountCash)) : 0;
      const totalPaid = amountFromPayable + amountCash;
      const outstandingAmount = netIncome - totalPaid;

      // Create receivable if there's an outstanding amount and clientId exists
      if (outstandingAmount > 0 && createDto.clientId) {
        const receivableData: any = {
          clientId: createDto.clientId,
          miningSiteId: createDto.siteId,
          totalAmount: String(outstandingAmount),
          remainingBalance: String(outstandingAmount),
          status: 'Pending',
          date: createDto.loadingDate.split('T')[0], // Remove time portion
          description: `Outstanding from Truck ${createDto.truckNumber}`,
        };

        const receivable = manager.create(Receivable, receivableData);
        if (userId) {
          (receivable as any)._userId = userId;
        }

        const savedReceivable = await manager.save(Receivable, receivable);

        // Link the receivable to the income
        savedIncome.receivableId = savedReceivable.id;
        await manager.save(Income, savedIncome);
      }

      // Reload income with all relationships to ensure client/receivable data is included
      const reloadedIncome = await manager.findOne(Income, {
        where: { id: savedIncome.id },
        relations: ['client', 'miningSite', 'liability', 'receivable', 'receivable.client', 'receivable.miningSite', 'creator', 'modifier'],
      });

      return reloadedIncome || savedIncome;
    });
  }

  async findAll(): Promise<Income[]> {
    return await this.repository.find({
      relations: ['client', 'miningSite', 'liability', 'receivable', 'creator', 'modifier'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<Income> {
    const entity = await this.repository.findOne({ 
      where: { id },
      relations: ['client', 'miningSite', 'liability', 'receivable', 'creator', 'modifier'],
    });
    if (!entity) {
      throw new NotFoundException(`Income with ID ${id} not found`);
    }
    return entity;
  }

  async update(id: number, updateDto: UpdateIncomeDto, userId?: number): Promise<Income> {
    const entity = await this.findOne(id);
    
    // Convert numeric values to strings for the entity
    const data: any = { ...updateDto };
    if (updateDto.coalPrice !== undefined) {
      data.coalPrice = String(updateDto.coalPrice);
    }
    if (updateDto.companyCommission !== undefined) {
      data.companyCommission = updateDto.companyCommission ? String(updateDto.companyCommission) : null;
    }
    if (updateDto.quantityTons !== undefined) {
      data.quantityTons = updateDto.quantityTons ? String(updateDto.quantityTons) : null;
    }
    if (updateDto.totalPrice !== undefined) {
      data.totalPrice = updateDto.totalPrice ? String(updateDto.totalPrice) : null;
    }
    if (updateDto.amountFromLiability !== undefined) {
      data.amountFromLiability = updateDto.amountFromLiability ? String(updateDto.amountFromLiability) : null;
    }
    
    Object.assign(entity, data);
    if (userId) {
      (entity as any)._userId = userId;
    }
    return await this.repository.save(entity);
  }

  async remove(id: number): Promise<void> {
    const entity = await this.findOne(id);
    await this.repository.remove(entity);
  }
}
