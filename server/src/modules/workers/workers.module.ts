import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Worker } from '../../entities/Worker.entity';
import { LaborsService } from './workers.service';
import { LaborsController } from './workers.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Worker])],
  controllers: [LaborsController],
  providers: [LaborsService],
  exports: [LaborsService],
})
export class LaborsModule {}
