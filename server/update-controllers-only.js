const fs = require('fs');
const path = require('path');

const modulesDir = path.join(__dirname, 'src', 'modules');

const modulesToUpdate = [
  'clients', 'client-types', 'expense-types', 'account-types',
  'leases', 'mining-sites', 'expenses', 'income', 'equipment',
  'labor-costs', 'partners', 'liabilities', 'general-ledger',
  'workers', 'partner-payouts', 'profit-distributions',
];

function updateServiceMethod(content, methodName, entityVar) {
  const regex = new RegExp(
    `(async ${methodName}\\([^)]+\\):[^{]+{[^}]*const ${entityVar} = [^;]+;)`,
    's'
  );
  
  if (!regex.test(content)) return content;
  
  return content.replace(regex, (match) => {
    if (match.includes('_userId')) return match; // Already updated
    return match + `\n    if (arguments[${methodName === 'create' ? 1 : 2}]) {\n      (${entityVar} as any)._userId = arguments[${methodName === 'create' ? 1 : 2}];\n    }`;
  });
}

function updateService(modulePath, moduleName) {
  const serviceFile = path.join(modulePath, `${moduleName}.service.ts`);
  if (!fs.existsSync(serviceFile)) return;

  let content = fs.readFileSync(serviceFile, 'utf8');
  
  // Add userId parameter to create method
  content = content.replace(
    /(async create\([^)]+Dto)(\): Promise)/,
    '$1, userId?: number$2'
  );
  
  // Add userId parameter to update method
  content = content.replace(
    /(async update\(id: number, [^)]+Dto)(\): Promise)/,
    '$1, userId?: number$2'
  );

  fs.writeFileSync(serviceFile, content, 'utf8');
  console.log(`✅ Updated service: ${moduleName}.service.ts`);
}

function updateController(modulePath, moduleName) {
  const controllerFile = path.join(modulePath, `${moduleName}.controller.ts`);
  if (!fs.existsSync(controllerFile)) return;

  let content = fs.readFileSync(controllerFile, 'utf8');

  // Add import
  if (!content.includes('CurrentUserId')) {
    content = content.replace(
      /from '@nestjs\/swagger';/,
      "from '@nestjs/swagger';\nimport { CurrentUserId } from '../../common/decorators/current-user.decorator';"
    );
  }

  // Add @CurrentUserId() to create method
  content = content.replace(
    /(create\(\s*@Body\(\) [^:]+:[^,\n)]+)([\),])/,
    '$1,\n    @CurrentUserId() userId: number$2'
  );

  // Add userId to create service call
  content = content.replace(
    /(this\.\w+Service\.create\([^)]+)()\)/,
    '$1, userId)'
  );

  // Add @CurrentUserId() to update method
  content = content.replace(
    /(update\([^@]*@Body\(\) [^:]+:[^,\n)]+)([\),])/,
    '$1,\n    @CurrentUserId() userId: number$2'
  );

  // Add userId to update service call  
  content = content.replace(
    /(this\.\w+Service\.update\([^,]+, [^)]+)()\)/,
    '$1, userId)'
  );

  fs.writeFileSync(controllerFile, content, 'utf8');
  console.log(`✅ Updated controller: ${moduleName}.controller.ts`);
}

console.log('🔧 Updating services and controllers for audit tracking...\n');

modulesToUpdate.forEach(moduleName => {
  const modulePath = path.join(modulesDir, moduleName);
  if (!fs.existsSync(modulePath)) return;

  console.log(`\n📦 Processing: ${moduleName}`);
  updateService(modulePath, moduleName);
  updateController(modulePath, moduleName);
});

console.log('\n✅ Done! Run npm run build to compile.');
