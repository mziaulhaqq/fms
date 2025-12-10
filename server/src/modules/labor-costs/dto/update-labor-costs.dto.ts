import { PartialType } from '@nestjs/mapped-types';
import { CreateLaborCostDto } from './create-labor-costs.dto';

export class UpdateLaborCostDto extends PartialType(CreateLaborCostDto) {}
