import { PartialType } from '@nestjs/swagger';
import { CreateTruckDeliveryDto } from './create-truck-deliveries.dto';

export class UpdateTruckDeliveryDto extends PartialType(CreateTruckDeliveryDto) {}
