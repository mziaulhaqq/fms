import { PartialType } from '@nestjs/swagger';
import { CreateGeneralLedgerDto } from './create-general-ledger.dto';

export class UpdateGeneralLedgerDto extends PartialType(CreateGeneralLedgerDto) {}
