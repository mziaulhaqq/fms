import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { APP_GUARD } from '@nestjs/core';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { typeOrmConfig } from './config/typeorm.config';

// Import all modules
import { AuthModule } from './modules/auth/auth.module';
import { JwtAuthGuard } from './modules/auth/guards/jwt-auth.guard';
import { ClientsModule } from './modules/clients/clients.module';
import { MiningSitesModule } from './modules/mining-sites/mining-sites.module';
import { PartnersModule } from './modules/partners/partners.module';
import { ExpensesModule } from './modules/expenses/expenses.module';
import { ExpenseCategorysModule } from './modules/expense-categories/expense-categories.module';
import { IncomesModule } from './modules/income/income.module';
import { LaborsModule } from './modules/workers/workers.module';
import { LaborCostsModule } from './modules/labor-costs/labor-costs.module';
import { LaborCostWorkersModule } from './modules/labor-cost-workers/labor-cost-workers.module';
import { PartnerPayoutsModule } from './modules/partner-payouts/partner-payouts.module';
import { ProfitDistributionsModule } from './modules/profit-distributions/profit-distributions.module';
import { SiteSupervisorsModule } from './modules/site-supervisors/site-supervisors.module';
import { UsersModule } from './modules/users/users.module';
import { UserRolesModule } from './modules/user-roles/user-roles.module';
import { UserAssignedRolesModule } from './modules/user-assigned-roles/user-assigned-roles.module';
import { EquipmentModule } from './modules/equipment/equipment.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    TypeOrmModule.forRootAsync({
      useFactory: typeOrmConfig,
    }),
    // Auth module
    AuthModule,
    // Feature modules
    ClientsModule,
    MiningSitesModule,
    PartnersModule,
    ExpensesModule,
    ExpenseCategorysModule,
    IncomesModule,
    LaborsModule,
    LaborCostsModule,
    LaborCostWorkersModule,
    PartnerPayoutsModule,
    ProfitDistributionsModule,
    SiteSupervisorsModule,
    UsersModule,
    UserRolesModule,
    UserAssignedRolesModule,
    EquipmentModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
  ],
})
export class AppModule {}
