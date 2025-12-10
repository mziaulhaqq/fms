import { PartialType } from '@nestjs/mapped-types';
import { CreateLaborDto } from './create-workers.dto';

export class UpdateLaborDto extends PartialType(CreateLaborDto) {}
