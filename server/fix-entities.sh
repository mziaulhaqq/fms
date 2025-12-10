#!/bin/bash

# Map of singular to plural entity names
declare -A entity_map=(
  ["Client"]="Clients"
  ["MiningSite"]="MiningSites"
  ["Partner"]="Partners"
  ["Expense"]="Expenses"
  ["ExpenseCategory"]="ExpenseCategories"
  ["Income"]="Income"
  ["Labor"]="Labor"
  ["LaborCost"]="LaborCosts"
  ["LaborCostWorker"]="LaborCostWorkers"
  ["PartnerPayout"]="PartnerPayouts"
  ["ProfitDistribution"]="ProfitDistributions"
  ["SiteSupervisor"]="SiteSupervisors"
  ["TruckDelivery"]="TruckDeliveries"
  ["User"]="Users"
  ["UserRole"]="UserRoles"
  ["UserAssignedRole"]="UserAssignedRoles"
  ["Equipment"]="Equipment"
  ["Production"]="Production"
)

# Update all TypeScript files in modules
for singular in "${!entity_map[@]}"; do
  plural="${entity_map[$singular]}"
  lowercase_singular=$(echo "$singular" | sed 's/\([A-Z]\)/-\1/g' | sed 's/^-//' | tr '[:upper:]' '[:lower:]')
  
  echo "Updating $singular -> $plural"
  
  # Find and replace in all module files
  find src/modules -type f -name "*.ts" -exec sed -i '' \
    -e "s/import { ${singular} } from '..\/..\/entities\/${lowercase_singular}.entity';/import { ${plural} } from '..\/..\/entities\/${plural}.entity';/g" \
    -e "s/: ${singular}\[\]/: ${plural}[]/g" \
    -e "s/: ${singular}/: ${plural}/g" \
    -e "s/Promise<${singular}>/Promise<${plural}>/g" \
    -e "s/Repository<${singular}>/Repository<${plural}>/g" \
    -e "s/@InjectRepository(${singular})/@InjectRepository(${plural})/g" \
    -e "s/TypeOrmModule.forFeature(\[${singular}\])/TypeOrmModule.forFeature([${plural}])/g" \
    {} \;
done

echo "Done!"
