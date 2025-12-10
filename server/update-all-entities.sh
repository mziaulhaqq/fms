#!/bin/zsh

cd /Users/mziaulhaq/Desktop/UK/Learning/projects/fms/server

# Array of replacements: "SingularName:PluralName:kebab-case"
replacements=(
  "MiningSite:MiningSites:mining-site"
  "Partner:Partners:partner"
  "Expense:Expenses:expense"
  "ExpenseCategory:ExpenseCategories:expense-category"
  "Income:Income:income"
  "Labor:Labor:labor"
  "LaborCost:LaborCosts:labor-cost"
  "LaborCostWorker:LaborCostWorkers:labor-cost-worker"
  "PartnerPayout:PartnerPayouts:partner-payout"
  "ProfitDistribution:ProfitDistributions:profit-distribution"
  "SiteSupervisor:SiteSupervisors:site-supervisor"
  "TruckDelivery:TruckDeliveries:truck-delivery"
  "User:Users:user"
  "UserRole:UserRoles:user-role"
  "UserAssignedRole:UserAssignedRoles:user-assigned-role"
)

for replacement in "${replacements[@]}"; do
  IFS=':' read -r singular plural kebab <<< "$replacement"
  echo "Updating $singular -> $plural"
  
  find src/modules -type f -name "*.ts" -exec sed -i '' \
    -e "s/from '\.\.\/\.\.\/entities\/${kebab}\.entity'/from '..\/..\/entities\/${plural}.entity'/g" \
    -e "s/{ ${singular} }/{ ${plural} }/g" \
    -e "s/Repository<${singular}>/Repository<${plural}>/g" \
    -e "s/Promise<${singular}>/Promise<${plural}>/g" \
    -e "s/: ${singular}\[\]/: ${plural}[]/g" \
    -e "s/: ${singular}>/: ${plural}>/g" \
    -e "s/: ${singular})/: ${plural})/g" \
    -e "s/@InjectRepository(${singular})/@InjectRepository(${plural})/g" \
    -e "s/TypeOrmModule\.forFeature\(\[${singular}\]\)/TypeOrmModule.forFeature([${plural}])/g" \
    {} \;
done

echo "All entities updated!"
