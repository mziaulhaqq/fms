import { PartialType } from '@nestjs/swagger';
import { CreateSiteSupervisorDto } from './create-site-supervisors.dto';

export class UpdateSiteSupervisorDto extends PartialType(CreateSiteSupervisorDto) {}
