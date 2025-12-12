const fs = require('fs');
const path = require('path');

const modulesDir = path.join(__dirname, 'src', 'modules');

// Define modules and their variable names used in create() method
const modules = {
  'clients': { varName: 'client', usesEntity: false },
  'client-types': { varName: 'clientType', usesEntity: false },
  'expense-types': { varName: 'expenseType', usesEntity: false },
  'account-types': { varName: 'accountType', usesEntity: false },
  'leases': { varName: 'lease', usesEntity: false },
  'mining-sites': { varName: 'miningSite', usesEntity: false },
  'expenses': { varName: 'expense', usesEntity: false },
  'income': { varName: 'entity', usesEntity: true },
  'equipment': { varName: 'equipment', usesEntity: false },
  'labor-costs': { varName: 'laborCost', usesEntity: false },
  'partners': { varName: 'partner', usesEntity: false },
  'liabilities': { varName: 'liability', usesEntity: false },
  'general-ledger': { varName: 'entity', usesEntity: true },
  'workers': { varName: 'entity', usesEntity: true },
  'partner-payouts': { varName: 'entity', usesEntity: true },
  'profit-distributions': { varName: 'entity', usesEntity: true },
};

function updateService(moduleName, config) {
  const servicePath = path.join(modulesDir, moduleName, `${moduleName}.service.ts`);
  
  if (!fs.existsSync(servicePath)) {
    console.log(`⚠️  Service not found: ${moduleName}`);
    return false;
  }

  let content = fs.readFileSync(servicePath, 'utf8');
  const { varName } = config;
  
  // 1. Update create() method signature
  content = content.replace(
    /async create\([^)]+\):/,
    `async create(createDto, userId?: number):`
  );
  
  // 2. Add _userId logic after repository.create() in create method
  content = content.replace(
    new RegExp(`(const ${varName} = this\\.\\w+\\.create\\([^)]+\\);)`),
    `$1\n    if (userId) {\n      (${varName} as any)._userId = userId;\n    }`
  );
  
  // 3. Update update() method signature
  content = content.replace(
    /async update\(id: number, [^,]+,?\):/,
    `async update(id: number, updateDto, userId?: number):`
  );
  
  // 4. Add _userId logic before save() in update method
  content = content.replace(
    new RegExp(`(Object\\.assign\\(${varName}, [^)]+\\);)`),
    `$1\n    if (userId) {\n      (${varName} as any)._userId = userId;\n    }`
  );
  
  fs.writeFileSync(servicePath, content, 'utf8');
  return true;
}

function updateController(moduleName) {
  const controllerPath = path.join(modulesDir, moduleName, `${moduleName}.controller.ts`);
  
  if (!fs.existsSync(controllerPath)) {
    console.log(`⚠️  Controller not found: ${moduleName}`);
    return false;
  }

  let content = fs.readFileSync(controllerPath, 'utf8');
  
  // 1. Add import for CurrentUserId decorator (only if not already present)
  if (!content.includes('CurrentUserId')) {
    content = content.replace(
      /(import.*from '@nestjs\/common';)/,
      `$1\nimport { CurrentUserId } from '../../common/decorators/current-user.decorator';`
    );
  }
  
  // 2. Update create() method - add @CurrentUserId() parameter
  content = content.replace(
    /(@Post\(\)[^@]*)(create\([^@]*@Body\(\) \w+: \w+,?\))/,
    `$1create(@Body() createDto, @CurrentUserId() userId: number)`
  );
  
  // 3. Update create() service call
  content = content.replace(
    /(return this\.\w+Service\.create\()(\w+)\)/,
    `$1$2, userId)`
  );
  
  // 4. Update update() method - add @CurrentUserId() parameter  
  content = content.replace(
    /(@Patch\(['"]:id['"]\)[^@]*)(update\([^@]*@Param\(['"]\w+['"]\)[^,]+,[^@]*@Body\(\) \w+: \w+,?\))/,
    `$1update(@Param('id') id: string, @Body() updateDto, @CurrentUserId() userId: number)`
  );
  
  // 5. Update update() service call
  content = content.replace(
    /(return this\.\w+Service\.update\([^,]+, )(\w+)\)/,
    `$1$2, userId)`
  );
  
  fs.writeFileSync(controllerPath, content, 'utf8');
  return true;
}

console.log('🚀 Comprehensive Audit Tracking Update\n');
console.log('This will update all services and controllers for audit tracking.\n');

let successCount = 0;
let failCount = 0;

Object.entries(modules).forEach(([moduleName, config]) => {
  console.log(`\n📦 Processing: ${moduleName}`);
  
  const serviceOk = updateService(moduleName, config);
  const controllerOk = updateController(moduleName);
  
  if (serviceOk && controllerOk) {
    console.log(`   ✅ Service updated (var: ${config.varName})`);
    console.log(`   ✅ Controller updated`);
    successCount++;
  } else {
    console.log(`   ❌ Failed`);
    failCount++;
  }
});

console.log(`\n${'='.repeat(60)}`);
console.log(`✅ Success: ${successCount} modules`);
console.log(`❌ Failed: ${failCount} modules`);
console.log(`\n🔨 Next step: npm run build`);
