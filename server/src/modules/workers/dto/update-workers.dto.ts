import { PartialType } from '@nestjs/swagger';
import { CreateLaborDto } from './create-workers.dto';

export class UpdateLaborDto extends PartialType(CreateLaborDto) {}
