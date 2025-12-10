import { PartialType } from '@nestjs/mapped-types';
import { CreateSiteSupervisorDto } from './create-site-supervisors.dto';

export class UpdateSiteSupervisorDto extends PartialType(CreateSiteSupervisorDto) {}
