#!/bin/bash

echo "🔧 Updating all services and controllers to populate createdBy/modifiedBy fields..."
echo ""

# List of modules that have create/update operations
MODULES=(
  "client-types"
  "expense-types"
  "account-types"
  "leases"
  "mining-sites"
  "expenses"
  "income"
  "equipment"
  "labor-costs"
  "partners"
  "liabilities"
  "general-ledger"
  "workers"
)

cd "$(dirname "$0")"

# Update services - add userId parameter to create and update methods
for module in "${MODULES[@]}"; do
  SERVICE_FILE="src/modules/${module}/${module}.service.ts"
  
  if [ -f "$SERVICE_FILE" ]; then
    echo "📝 Updating service: $SERVICE_FILE"
    
    # Update create method
    sed -i.bak -E 's/async create\(create([A-Za-z]+)Dto: Create([A-Za-z]+)Dto\)/async create(create\1Dto: Create\2Dto, userId?: number)/g' "$SERVICE_FILE"
    
    # Add userId logic after repository.create in create method
    perl -i.bak2 -pe 'if (/const \w+ = this\.\w+Repository\.create/) { 
      $_ .= "    if (userId) {\n      (\$entity as any)._userId = userId;\n    }\n";
    }' "$SERVICE_FILE"
    
    # Update update method
    sed -i.bak3 -E 's/async update\(id: number, update([A-Za-z]+)Dto: Update([A-Za-z]+)Dto\)/async update(id: number, update\1Dto: Update\2Dto, userId?: number)/g' "$SERVICE_FILE"
    
    # Add userId logic before save in update method
    perl -i.bak4 -pe 'if (/Object\.assign\(\w+, update\w+Dto\);/) {
      $_ .= "    if (userId) {\n      (\$entity as any)._userId = userId;\n    }\n";
    }' "$SERVICE_FILE"
    
    # Clean up backup files
    rm -f "$SERVICE_FILE.bak" "$SERVICE_FILE.bak2" "$SERVICE_FILE.bak3" "$SERVICE_FILE.bak4"
  fi
done

# Update controllers - add @CurrentUserId() decorator
for module in "${MODULES[@]}"; do
  CONTROLLER_FILE="src/modules/${module}/${module}.controller.ts"
  
  if [ -f "$CONTROLLER_FILE" ]; then
    echo "📝 Updating controller: $CONTROLLER_FILE"
    
    # Add import if not exists
    if ! grep -q "CurrentUserId" "$CONTROLLER_FILE"; then
      sed -i.bak "s|from '@nestjs/swagger';|from '@nestjs/swagger';\nimport { CurrentUserId } from '../../common/decorators/current-user.decorator';|" "$CONTROLLER_FILE"
    fi
    
    # Update create method - add @CurrentUserId() userId: number parameter
    perl -i.bak2 -0777 -pe 's/(@Post\(\)[^\{]+create\([^)]+)(\): Promise)/\1,\n    \@CurrentUserId() userId: number,\2/gs' "$CONTROLLER_FILE"
    
    # Update create service call to pass userId
    sed -i.bak3 -E 's/this\.(\w+)Service\.create\(create(\w+)Dto\)/this.\1Service.create(create\2Dto, userId)/g' "$CONTROLLER_FILE"
    
    # Update update method - add @CurrentUserId() userId: number parameter
    perl -i.bak4 -0777 -pe 's/(@Patch\([^)]*\)[^\{]+update\([^)]+)(\): Promise)/\1,\n    \@CurrentUserId() userId: number,\2/gs' "$CONTROLLER_FILE"
    
    # Update update service call to pass userId
    sed -i.bak5 -E 's/this\.(\w+)Service\.update\(id, update(\w+)Dto\)/this.\1Service.update(id, update\2Dto, userId)/g' "$CONTROLLER_FILE"
    
    # Clean up backup files
    rm -f "$CONTROLLER_FILE.bak" "$CONTROLLER_FILE.bak2" "$CONTROLLER_FILE.bak3" "$CONTROLLER_FILE.bak4" "$CONTROLLER_FILE.bak5"
  fi
done

echo ""
echo "✅ All services and controllers updated!"
echo ""
echo "Next steps:"
echo "1. Update all entity files to extend BaseEntityWithAudit"
echo "2. Build and restart the server"
echo "3. Test create/update operations"
