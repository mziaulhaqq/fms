import { PartialType } from '@nestjs/swagger';
import { CreateLaborCostWorkerDto } from './create-labor-cost-workers.dto';

export class UpdateLaborCostWorkerDto extends PartialType(CreateLaborCostWorkerDto) {}
