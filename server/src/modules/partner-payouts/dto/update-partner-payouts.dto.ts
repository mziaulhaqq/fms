import { PartialType } from '@nestjs/mapped-types';
import { CreatePartnerPayoutDto } from './create-partner-payouts.dto';

export class UpdatePartnerPayoutDto extends PartialType(CreatePartnerPayoutDto) {}
