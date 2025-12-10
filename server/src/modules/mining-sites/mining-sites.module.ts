import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MiningSites } from '../../entities/MiningSites.entity';
import { MiningSitesService } from './mining-sites.service';
import { MiningSitesController } from './mining-sites.controller';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([MiningSites]),
    AuthModule,
  ],
  controllers: [MiningSitesController],
  providers: [MiningSitesService],
  exports: [MiningSitesService],
})
export class MiningSitesModule {}
