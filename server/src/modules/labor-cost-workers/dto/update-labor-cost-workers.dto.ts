import { PartialType } from '@nestjs/mapped-types';
import { CreateLaborCostWorkerDto } from './create-labor-cost-workers.dto';

export class UpdateLaborCostWorkerDto extends PartialType(CreateLaborCostWorkerDto) {}
