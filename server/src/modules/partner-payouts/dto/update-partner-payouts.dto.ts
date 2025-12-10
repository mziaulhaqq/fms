import { PartialType } from '@nestjs/swagger';
import { CreatePartnerPayoutDto } from './create-partner-payouts.dto';

export class UpdatePartnerPayoutDto extends PartialType(CreatePartnerPayoutDto) {}
