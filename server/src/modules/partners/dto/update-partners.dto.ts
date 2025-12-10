import { PartialType } from '@nestjs/swagger';
import { CreatePartnerDto } from './create-partners.dto';

export class UpdatePartnerDto extends PartialType(CreatePartnerDto) {}
