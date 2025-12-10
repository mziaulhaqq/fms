import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MiningSite } from '../../entities/mining-site.entity';
import { MiningSitesService } from './mining-sites.service';
import { MiningSitesController } from './mining-sites.controller';

@Module({
  imports: [TypeOrmModule.forFeature([MiningSite])],
  controllers: [MiningSitesController],
  providers: [MiningSitesService],
  exports: [MiningSitesService],
})
export class MiningSitesModule {}
