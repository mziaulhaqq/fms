import { PartialType } from '@nestjs/mapped-types';
import { CreateProfitDistributionDto } from './create-profit-distributions.dto';

export class UpdateProfitDistributionDto extends PartialType(CreateProfitDistributionDto) {}
