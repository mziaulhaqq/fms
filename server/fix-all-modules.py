#!/usr/bin/env python3
import os
import re
from pathlib import Path

# Modules to update with their correct DTO parameter names from original files
modules_config = {
    'client-types': 'CreateClientTypeDto',
    'expense-types': 'CreateExpenseTypeDto',
    'account-types': 'CreateAccountTypeDto',
    'leases': 'CreateLeaseDto',
    'mining-sites': 'CreateMiningSiteDto',
    'expenses': 'CreateExpenseDto',
    'income': 'CreateIncomeDto',
    'equipment': 'CreateEquipmentDto',
    'labor-costs': 'CreateLaborCostDto',
    'partners': 'CreatePartnerDto',
    'liabilities': 'CreateLiabilityDto',
    'general-ledger': 'CreateGeneralLedgerEntryDto',
    'workers': 'CreateWorkerDto',
    'partner-payouts': 'CreatePartnerPayoutDto',
    'profit-distributions': 'CreateProfitDistributionDto',
}

def fix_service_file(module_name, create_dto_name):
    """Fix service file with correct DTO type"""
    service_path = f'src/modules/{module_name}/{module_name}.service.ts'
    
    if not os.path.exists(service_path):
        print(f'⚠️  Service not found: {service_path}')
        return False
    
    with open(service_path, 'r') as f:
        content = f.read()
    
    # Fix create method signature
    content = re.sub(
        r'async create\(createDto, userId\?: number\)',
        f'async create(createDto: {create_dto_name}, userId?: number)',
        content
    )
    
    # Fix update method signature - find the update DTO name
    update_dto_name = create_dto_name.replace('Create', 'Update')
    content = re.sub(
        r'async update\(id: number, updateDto, userId\?: number\)',
        f'async update(id: number, updateDto: {update_dto_name}, userId?: number)',
        content
    )
    
    with open(service_path, 'w') as f:
        f.write(content)
    
    print(f'✅ Fixed service: {module_name}')
    return True

def fix_controller_file(module_name, create_dto_name):
    """Fix controller file with imports and decorators"""
    controller_path = f'src/modules/{module_name}/{module_name}.controller.ts'
    
    if not os.path.exists(controller_path):
        print(f'⚠️  Controller not found: {controller_path}')
        return False
    
    with open(controller_path, 'r') as f:
        content = f.read()
    
    # Add CurrentUserId import if not exists
    if 'CurrentUserId' not in content:
        content = content.replace(
            "from '@nestjs/swagger';",
            "from '@nestjs/swagger';\nimport { CurrentUserId } from '../../common/decorators/current-user.decorator';",
            1
        )
    
    # Fix create method - add @CurrentUserId() parameter
    # Pattern: create(@Body() someDto: SomeDto)
    content = re.sub(
        r'(create\(@Body\(\) \w+: ' + create_dto_name + r'\))',
        r'create(@Body() createDto: ' + create_dto_name + r', @CurrentUserId() userId: number)',
        content
    )
    
    # Fix create service call
    content = re.sub(
        r'(this\.\w+Service\.create\()(\w+)\)',
        r'\1\2, userId)',
        content
    )
    
    # Fix update method - add @CurrentUserId() parameter
    update_dto_name = create_dto_name.replace('Create', 'Update')
    content = re.sub(
        r'(update\([^)]*@Param\([\'"]id[\'"]\)[^,]+,\s*@Body\(\) \w+: ' + update_dto_name + r'\))',
        r'update(@Param(\'id\') id: string, @Body() updateDto: ' + update_dto_name + r', @CurrentUserId() userId: number)',
        content
    )
    
    # Fix update service call
    content = re.sub(
        r'(this\.\w+Service\.update\([^,]+,\s*)(\w+)\)',
        r'\1\2, userId)',
        content
    )
    
    with open(controller_path, 'w') as f:
        f.write(content)
    
    print(f'✅ Fixed controller: {module_name}')
    return True

def main():
    print('🔧 Fixing all service and controller files...\n')
    
    success_count = 0
    fail_count = 0
    
    for module_name, create_dto_name in modules_config.items():
        print(f'\n📦 Processing: {module_name}')
        
        service_ok = fix_service_file(module_name, create_dto_name)
        controller_ok = fix_controller_file(module_name, create_dto_name)
        
        if service_ok and controller_ok:
            success_count += 1
        else:
            fail_count += 1
    
    print(f'\n{"="*60}')
    print(f'✅ Success: {success_count} modules')
    print(f'❌ Failed: {fail_count} modules')
    print(f'\n🔨 Next: npm run build')

if __name__ == '__main__':
    main()
