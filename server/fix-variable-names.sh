#!/bin/bash

cd "$(dirname "$0")"

echo "🔧 Fixing variable names in service files..."

# Clients
sed -i.bak 's/(laborCost as any)._userId = userId;/(client as any)._userId = userId;/g' src/modules/clients/clients.service.ts && rm -f src/modules/clients/clients.service.ts.bak

# Equipment
sed -i.bak 's/(laborCost as any)._userId = userId;/(equipment as any)._userId = userId;/g' src/modules/equipment/equipment.service.ts && rm -f src/modules/equipment/equipment.service.ts.bak

# Mining Sites
sed -i.bak 's/(laborCost as any)._userId = userId;/(miningSite as any)._userId = userId;/g' src/modules/mining-sites/mining-sites.service.ts && rm -f src/modules/mining-sites/mining-sites.service.ts.bak

# Liabilities
sed -i.bak 's/(laborCost as any)._userId = userId;/(liability as any)._userId = userId;/g' src/modules/liabilities/liabilities.service.ts && rm -f src/modules/liabilities/liabilities.service.ts.bak

# Income
sed -i.bak 's/(laborCost as any)._userId = userId;/(income as any)._userId = userId;/g' src/modules/income/income.service.ts && rm -f src/modules/income/income.service.ts.bak

# General Ledger
sed -i.bak 's/(laborCost as any)._userId = userId;/(generalLedger as any)._userId = userId;/g' src/modules/general-ledger/general-ledger.service.ts && rm -f src/modules/general-ledger/general-ledger.service.ts.bak

# Labor Costs - this one is correct already
echo "✅ Labor costs already correct"

# Expense Types
sed -i.bak 's/(laborCost as any)._userId = userId;/(expenseType as any)._userId = userId;/g' src/modules/expense-types/expense-types.service.ts && rm -f src/modules/expense-types/expense-types.service.ts.bak

# Leases
sed -i.bak 's/(laborCost as any)._userId = userId;/(lease as any)._userId = userId;/g' src/modules/leases/leases.service.ts && rm -f src/modules/leases/leases.service.ts.bak

# Account Types
sed -i.bak 's/(laborCost as any)._userId = userId;/(accountType as any)._userId = userId;/g' src/modules/account-types/account-types.service.ts && rm -f src/modules/account-types/account-types.service.ts.bak

# Client Types
sed -i.bak 's/(laborCost as any)._userId = userId;/(clientType as any)._userId = userId;/g' src/modules/client-types/client-types.service.ts && rm -f src/modules/client-types/client-types.service.ts.bak

echo "✅ All variable names fixed!"
