import { PartialType } from '@nestjs/swagger';
import { CreateMiningSiteDto } from './create-mining-sites.dto';

export class UpdateMiningSiteDto extends PartialType(CreateMiningSiteDto) {}
