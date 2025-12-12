const fs = require('fs');
const path = require('path');

const modulesDir = path.join(__dirname, 'src', 'modules');

// List of modules to update (exclude auth, users, site-supervisors, etc.)
const modulesToUpdate = [
  'clients',
  'client-types',
  'expense-types',
  'account-types',
  'leases',
  'mining-sites',
  'expenses',
  'income',
  'equipment',
  'labor-costs',
  'partners',
  'liabilities',
  'general-ledger',
  'workers',
  'partner-payouts',
  'profit-distributions',
];

function updateServiceFile(modulePath, moduleName) {
  const serviceFile = path.join(modulePath, `${moduleName}.service.ts`);
  
  if (!fs.existsSync(serviceFile)) {
    console.log(`⚠️  Service file not found: ${serviceFile}`);
    return;
  }

  let content = fs.readFileSync(serviceFile, 'utf8');
  let modified = false;

  // Update create method signature
  const createRegex = /async create\(create(\w+)Dto: Create(\w+)Dto\): Promise/g;
  if (createRegex.test(content)) {
    content = content.replace(
      /async create\(create(\w+)Dto: Create(\w+)Dto\): Promise/g,
      'async create(create$1Dto: Create$2Dto, userId?: number): Promise'
    );
    modified = true;
  }

  // Add userId assignment after repository.create
  const lines = content.split('\n');
  for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes('.create(create') && lines[i].includes('Dto)')) {
      // Check if next lines already have userId logic
      if (!lines[i + 1]?.includes('_userId')) {
        lines.splice(i + 1, 0, '    if (userId) {');
        lines.splice(i + 2, 0, '      (entity as any)._userId = userId;');
        lines.splice(i + 3, 0, '    }');
        modified = true;
      }
    }
  }
  content = lines.join('\n');

  // Update update method signature
  const updateRegex = /async update\(id: number, update(\w+)Dto: Update(\w+)Dto\): Promise/g;
  if (updateRegex.test(content)) {
    content = content.replace(
      /async update\(id: number, update(\w+)Dto: Update(\w+)Dto\): Promise/g,
      'async update(id: number, update$1Dto: Update$2Dto, userId?: number): Promise'
    );
    modified = true;
  }

  // Add userId assignment before save in update method
  const lines2 = content.split('\n');
  for (let i = 0; i < lines2.length; i++) {
    if (lines2[i].includes('Object.assign(') && lines2[i].includes('Dto)')) {
      // Check if next lines already have userId logic
      if (!lines2[i + 1]?.includes('_userId')) {
        lines2.splice(i + 1, 0, '    if (userId) {');
        lines2.splice(i + 2, 0, '      (entity as any)._userId = userId;');
        lines2.splice(i + 3, 0, '    }');
        modified = true;
      }
    }
  }
  content = lines2.join('\n');

  if (modified) {
    fs.writeFileSync(serviceFile, content, 'utf8');
    console.log(`✅ Updated service: ${moduleName}.service.ts`);
  } else {
    console.log(`⏭️  No changes needed: ${moduleName}.service.ts`);
  }
}

function updateControllerFile(modulePath, moduleName) {
  const controllerFile = path.join(modulePath, `${moduleName}.controller.ts`);
  
  if (!fs.existsSync(controllerFile)) {
    console.log(`⚠️  Controller file not found: ${controllerFile}`);
    return;
  }

  let content = fs.readFileSync(controllerFile, 'utf8');
  let modified = false;

  // Add import for CurrentUserId if not exists
  if (!content.includes('CurrentUserId')) {
    content = content.replace(
      /from '@nestjs\/swagger';/,
      "from '@nestjs/swagger';\nimport { CurrentUserId } from '../../common/decorators/current-user.decorator';"
    );
    modified = true;
  }

  // Update create method to add @CurrentUserId() parameter
  content = content.replace(
    /(@Post\(\)[^{]+create\([^)]+)()\): Promise/,
    '$1,\n    @CurrentUserId() userId: number,\n  ): Promise'
  );

  // Update create service call to pass userId
  content = content.replace(
    /this\.(\w+)Service\.create\(create(\w+)Dto\)/g,
    'this.$1Service.create(create$2Dto, userId)'
  );

  // Update update method to add @CurrentUserId() parameter  
  content = content.replace(
    /(@Patch\([^)]*\)[^{]+update\([^)]+)()\): Promise/,
    '$1,\n    @CurrentUserId() userId: number,\n  ): Promise'
  );

  // Update update service call to pass userId
  content = content.replace(
    /this\.(\w+)Service\.update\(id, update(\w+)Dto\)/g,
    'this.$1Service.update(id, update$2Dto, userId)'
  );

  fs.writeFileSync(controllerFile, content, 'utf8');
  console.log(`✅ Updated controller: ${moduleName}.controller.ts`);
}

console.log('🔧 Updating all services and controllers to populate createdBy/modifiedBy fields...\n');

modulesToUpdate.forEach(moduleName => {
  const modulePath = path.join(modulesDir, moduleName);
  
  if (!fs.existsSync(modulePath)) {
    console.log(`⚠️  Module directory not found: ${moduleName}`);
    return;
  }

  console.log(`\n📦 Processing module: ${moduleName}`);
  updateServiceFile(modulePath, moduleName);
  updateControllerFile(modulePath, moduleName);
});

console.log('\n✅ All modules processed!');
console.log('\nNext steps:');
console.log('1. Run: npm run build');
console.log('2. Restart the server');
console.log('3. Test create/update operations - createdBy/modifiedBy should now be populated');
