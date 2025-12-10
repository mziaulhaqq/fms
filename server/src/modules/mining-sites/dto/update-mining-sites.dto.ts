import { PartialType } from '@nestjs/mapped-types';
import { CreateMiningSiteDto } from './create-mining-sites.dto';

export class UpdateMiningSiteDto extends PartialType(CreateMiningSiteDto) {}
