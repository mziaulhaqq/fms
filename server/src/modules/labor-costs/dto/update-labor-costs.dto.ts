import { PartialType } from '@nestjs/swagger';
import { CreateLaborCostDto } from './create-labor-costs.dto';

export class UpdateLaborCostDto extends PartialType(CreateLaborCostDto) {}
