import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { typeOrmConfig } from './config/typeorm.config';

// Import all modules
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
import { TruckDeliverysModule } from './modules/truck-deliveries/truck-deliveries.module';
import { UsersModule } from './modules/users/users.module';
import { UserRolesModule } from './modules/user-roles/user-roles.module';
import { UserAssignedRolesModule } from './modules/user-assigned-roles/user-assigned-roles.module';
// import { EquipmentsModule } from './modules/equipment/equipment.module';
// import { ProductionsModule } from './modules/production/production.module';
import { EquipmentModule } from './modules/equipment/equipment.module';
import { ProductionModule } from './modules/production/production.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    TypeOrmModule.forRootAsync({
      useFactory: typeOrmConfig,
    }),
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
    TruckDeliverysModule,
    UsersModule,
    UserRolesModule,
    UserAssignedRolesModule,
    EquipmentModule,
    ProductionModule,
    // EquipmentsModule,
    // ProductionsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
