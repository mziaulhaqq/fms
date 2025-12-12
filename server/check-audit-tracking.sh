#!/bin/bash

echo "🔧 Fixing audit tracking for all modules..."
echo ""

# List of modules that need fixing
modules=(
  "client-types"
  "account-types"
  "expense-types"
)

for module in "${modules[@]}"; do
  echo "📦 Processing: $module"
  
  controller_file="src/modules/$module/$module.controller.ts"
  service_file="src/modules/$module/$module.service.ts"
  
  if [ -f "$controller_file" ]; then
    # Check if it uses @Request() req instead of @CurrentUserId()
    if grep -q "@Request() req" "$controller_file"; then
      echo "   ⚠️  Controller uses @Request() req - needs manual fix"
    elif grep -q "@CurrentUserId()" "$controller_file"; then
      echo "   ✅ Controller already has @CurrentUserId()"
    else
      echo "   ❌ Controller missing @CurrentUserId()"
    fi
  fi
  
  if [ -f "$service_file" ]; then
    # Check if service has userId parameter
    if grep -q "userId?: number" "$service_file"; then
      echo "   ✅ Service has userId parameter"
    else
      echo "   ❌ Service missing userId parameter"
    fi
  fi
  
  echo ""
done

echo "Manual fixes needed for controllers using @Request() req"
