const fs = require('fs');
const path = require('path');

const modulesDir = path.join(__dirname, 'src', 'modules');

const services = {
  'clients': 'client',
  'client-types': 'clientType',
  'expense-types': 'expenseType',
  'account-types': 'accountType',
  'leases': 'lease',
  'mining-sites': 'miningSite',
  'expenses': 'expense',
  'income': 'entity', // uses 'entity'
  'equipment': 'equipment',
  'labor-costs': 'laborCost',
  'partners': 'partner',
  'liabilities': 'liability',
  'general-ledger': 'entity', // uses 'entity'
  'workers': 'entity', // uses 'entity'
  'partner-payouts': 'entity', // uses 'entity'
  'profit-distributions': 'entity', // uses 'entity'
};

function addUserIdLogic(content, varName) {
  // After repository.create, add _userId logic for CREATE
  let lines = content.split('\n');
  let inCreateMethod = false;
  let createFound = false;
  
  for (let i = 0; i < lines.length; i++) {
    // Detect start of create method
    if (lines[i].includes('async create(')) {
      inCreateMethod = true;
    }
    
    // Find the line with repository.create
    if (inCreateMethod && lines[i].includes('.create(') && !createFound) {
      // Check if next line already has _userId logic
      if (!lines[i + 1]?.includes('_userId')) {
        lines.splice(i + 1, 0, `    if (userId) {`);
        lines.splice(i + 2, 0, `      (${varName} as any)._userId = userId;`);
        lines.splice(i + 3, 0, `    }`);
        createFound = true;
      }
    }
    
    // Detect end of method
    if (inCreateMethod && lines[i].trim() === '}') {
      inCreateMethod = false;
    }
  }
  
  content = lines.join('\n');
  
  // For UPDATE method - add before save
  lines = content.split('\n');
  let inUpdateMethod = false;
  let updateFound = false;
  
  for (let i = 0; i < lines.length; i++) {
    // Detect start of update method
    if (lines[i].includes('async update(')) {
      inUpdateMethod = true;
    }
    
    // Find Object.assign line
    if (inUpdateMethod && lines[i].includes('Object.assign(') && !updateFound) {
      // Check if next line already has _userId logic
      if (!lines[i + 1]?.includes('_userId')) {
        lines.splice(i + 1, 0, `    if (userId) {`);
        lines.splice(i + 2, 0, `      (${varName} as any)._userId = userId;`);
        lines.splice(i + 3, 0, `    }`);
        updateFound = true;
      }
    }
    
    // Detect end of method
    if (inUpdateMethod && lines[i].trim().startsWith('}') && lines[i - 1]?.trim().startsWith('}')) {
      inUpdateMethod = false;
    }
  }
  
  return lines.join('\n');
}

console.log('🔧 Adding _userId logic to service methods...\n');

Object.entries(services).forEach(([moduleName, varName]) => {
  const servicePath = path.join(modulesDir, moduleName, `${moduleName}.service.ts`);
  
  if (!fs.existsSync(servicePath)) {
    console.log(`⚠️  Skipping: ${moduleName} (service not found)`);
    return;
  }

  let content = fs.readFileSync(servicePath, 'utf8');
  content = addUserIdLogic(content, varName);
  fs.writeFileSync(servicePath, content, 'utf8');
  
  console.log(`✅ Updated: ${moduleName}.service.ts (var: ${varName})`);
});

console.log('\n✅ All services updated! Run npm run build');
