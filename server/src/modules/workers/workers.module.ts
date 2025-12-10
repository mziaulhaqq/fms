import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Labor } from '../../entities/Labor.entity';
import { LaborsService } from './workers.service';
import { LaborsController } from './workers.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Labor])],
  controllers: [LaborsController],
  providers: [LaborsService],
  exports: [LaborsService],
})
export class LaborsModule {}
