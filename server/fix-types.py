#!/usr/bin/env python3
import os
import re

# Mapping of singular to plural
mappings = {
    'Client': 'Clients',
    'MiningSite': 'MiningSites',
    'Partner': 'Partners',
    'Expense': 'Expenses',
    'ExpenseCategory': 'ExpenseCategories',
    'LaborCost': 'LaborCosts',
    'LaborCostWorker': 'LaborCostWorkers',
    'PartnerPayout': 'PartnerPayouts',
    'ProfitDistribution': 'ProfitDistributions',
    'SiteSupervisor': 'SiteSupervisors',
    'TruckDelivery': 'TruckDeliveries',
    'User': 'Users',
    'UserRole': 'UserRoles',
    'UserAssignedRole': 'UserAssignedRoles',
}

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    original = content
    
    for singular, plural in mappings.items():
        # Fix array types in decorators: type: [Client] -> type: [Clients]
        content = re.sub(rf'type: \[{singular}\]', f'type: [{plural}]', content)
        
        # Fix single types in decorators: type: Client } -> type: Clients }
        content = re.sub(rf'type: {singular}\}}', f'type: {plural}}}', content)
        
        # Fix single types in decorators: type: Client) -> type: Clients)
        content = re.sub(rf'type: {singular}\)', f'type: {plural})', content)
        
        # Fix Promise return types: Promise<Client[]> -> Promise<Clients[]>
        content = re.sub(rf'Promise<{singular}\[\]>', f'Promise<{plural}[]>', content)
        
        # Fix module imports: [Client] -> [Clients]
        content = re.sub(rf'\[{singular}\]', f'[{plural}]', content)
    
    # Fix typo: ClientssService -> ClientsService
    content = content.replace('ClientssService', 'ClientsService')
    
    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        return True
    return False

# Process all files in modules
base_dir = 'src/modules'
files_changed = 0

for root, dirs, files in os.walk(base_dir):
    for file in files:
        if file.endswith(('.controller.ts', '.service.ts', '.module.ts')):
            filepath = os.path.join(root, file)
            if fix_file(filepath):
                files_changed += 1
                print(f"Fixed: {filepath}")

print(f"\n✅ Fixed {files_changed} files!")
