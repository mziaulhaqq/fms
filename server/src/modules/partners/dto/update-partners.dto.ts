import { PartialType } from '@nestjs/mapped-types';
import { CreatePartnerDto } from './create-partners.dto';

export class UpdatePartnerDto extends PartialType(CreatePartnerDto) {}
