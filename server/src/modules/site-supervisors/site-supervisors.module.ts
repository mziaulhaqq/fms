import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SiteSupervisor } from '../../entities/site-supervisor.entity';
import { SiteSupervisorsService } from './site-supervisors.service';
import { SiteSupervisorsController } from './site-supervisors.controller';

@Module({
  imports: [TypeOrmModule.forFeature([SiteSupervisor])],
  controllers: [SiteSupervisorsController],
  providers: [SiteSupervisorsService],
  exports: [SiteSupervisorsService],
})
export class SiteSupervisorsModule {}
