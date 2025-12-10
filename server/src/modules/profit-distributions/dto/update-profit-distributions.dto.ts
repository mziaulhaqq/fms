import { PartialType } from '@nestjs/swagger';
import { CreateProfitDistributionDto } from './create-profit-distributions.dto';

export class UpdateProfitDistributionDto extends PartialType(CreateProfitDistributionDto) {}
