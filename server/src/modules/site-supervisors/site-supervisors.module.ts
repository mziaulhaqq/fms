import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SiteSupervisors } from '../../entities/SiteSupervisors.entity';
import { SiteSupervisorsService } from './site-supervisors.service';
import { SiteSupervisorsController } from './site-supervisors.controller';

@Module({
  imports: [TypeOrmModule.forFeature([SiteSupervisors])],
  controllers: [SiteSupervisorsController],
  providers: [SiteSupervisorsService],
  exports: [SiteSupervisorsService],
})
export class SiteSupervisorsModule {}
