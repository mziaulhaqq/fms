import { PartialType } from '@nestjs/mapped-types';
import { CreateTruckDeliveryDto } from './create-truck-deliveries.dto';

export class UpdateTruckDeliveryDto extends PartialType(CreateTruckDeliveryDto) {}
