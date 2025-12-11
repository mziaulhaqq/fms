# Coal Mining FMS - Schema Update Implementation Summary

## ✅ COMPLETED - Backend Entity Updates

### 1. Base Audit Entity Created
**File:** `/server/src/entities/AuditEntity.ts`
- Provides `createdAt`, `updatedAt`, `createdBy`, `modifiedBy` for all entities
- All entities now extend this base class for audit trail

### 2. New Entities Created

#### a. **Lease** (`/server/src/entities/Lease.entity.ts`)
- `id`, `leaseName`, `location`, `isActive`
- Audit fields inherited
- Relationships:
  - One-to-Many with MiningSites
  - One-to-Many with Partners

#### b. **ClientType** (`/server/src/entities/ClientType.entity.ts`)
- `id`, `name`, `description`, `isActive`
- Audit fields inherited
- Relationship: One-to-Many with Clients

#### c. **ExpenseType** (`/server/src/entities/ExpenseType.entity.ts`)
- `id`, `name`, `description`, `isActive`
- Audit fields inherited
- Relationship: One-to-Many with Expenses

#### d. **AccountType** (`/server/src/entities/AccountType.entity.ts`)
- `id`, `name`, `description`, `isActive`
- Audit fields inherited
- Relationship: One-to-Many with GeneralLedger

#### e. **GeneralLedger** (`/server/src/entities/GeneralLedger.entity.ts`)
- `id`, `accountCode`, `accountName`, `accountTypeId`, `miningSiteId`, `description`, `isActive`
- Audit fields inherited
- Relationships:
  - Many-to-One with AccountType
  - Many-to-One with MiningSite

#### f. **Liability** (`/server/src/entities/Liability.entity.ts`)
- `id`, `type` (Loan/Advanced Payment), `clientId`, `miningSiteId`, `date`, `description`
- `totalAmount`, `remainingBalance`, `status`, `proof[]`
- Audit fields inherited
- Relationships:
  - Many-to-One with Client
  - Many-to-One with MiningSite

### 3. Updated Entities

#### a. **MiningSites**
- Added: `leaseId`, audit fields (createdBy, modifiedBy)
- New relationships:
  - Many-to-One with Lease
  - One-to-Many with GeneralLedger
  - One-to-Many with Liability

#### b. **Clients**
- Added: `clientTypeId`, `modifiedBy`
- Removed: Old audit fields (replaced by AuditEntity)
- New relationships:
  - Many-to-One with ClientType
  - One-to-Many with Liability
  - One-to-Many with Expenses

#### c. **Expenses**
- Added: `expenseTypeId`, `workerId`, `clientId`, `proof[]`, `modifiedBy`
- Removed: `evidencePhotos`, `paymentProof`, `accountType`, `payeeType`
- New relationships:
  - Many-to-One with ExpenseType
  - Many-to-One with Worker
  - Many-to-One with Client

#### d. **Income**
- Added: `clientId`, `amountFromLiability`, `liabilityId`, `modifiedBy`
- Removed: Old audit fields (replaced by AuditEntity)
- New relationship:
  - Many-to-One with Client

#### e. **Partners**
- Added: `leaseId`, `miningSiteId`, audit fields
- Removed: `lease` (string), `mineNumber`
- New relationships:
  - Many-to-One with Lease
  - Many-to-One with MiningSite

---

## ✅ COMPLETED - Database Migration

**File:** `/server/src/migrations/1765481906729-ComprehensiveSchemaUpdate.ts`

### Migration Includes:
1. Create `leases` table
2. Create `client_types` table with default values (Coal Agent, Bhatta, Factory)
3. Create `expense_types` table with default values (Worker, Vendor)
4. Create `account_types` table with default values (Asset, Liability, Equity, Revenue, Expense)
5. Create `general_ledger` table
6. Create `liabilities` table with ENUMs for type and status
7. Update `mining_sites` - add lease_id, created_by, modified_by
8. Update `clients` - add client_type_id, modified_by
9. Update `expenses` - restructure with new fields
10. Update `income` - add liability tracking fields
11. Update `partners` - add lease_id, mining_site_id
12. Update `equipment`, `production`, `workers` - add audit fields

---

## ⏳ PENDING - Migration Execution

**Status:** Migration created but not executed due to TypeORM auto-migration conflicts

**Solution Required:** Execute migration SQL directly or resolve TypeORM conflicts

### Quick Manual Execution:
```sql
-- Run the SQL from migration file directly in psql
-- This bypasses TypeORM's auto-generated migrations
```

---

## ⏳ PENDING - Backend Implementation

### 1. Create DTOs (Data Transfer Objects)

Need to create for:
- `/server/src/modules/lease/dto/create-lease.dto.ts`
- `/server/src/modules/lease/dto/update-lease.dto.ts`
- `/server/src/modules/client-type/dto/`
- `/server/src/modules/expense-type/dto/`
- `/server/src/modules/account-type/dto/`
- `/server/src/modules/general-ledger/dto/`
- `/server/src/modules/liability/dto/`

Update existing:
- `/server/src/modules/clients/dto/` - add clientTypeId
- `/server/src/modules/expenses/dto/` - add expenseTypeId, workerId, clientId
- `/server/src/modules/income/dto/` - add clientId, liability fields
- `/server/src/modules/partners/dto/` - add leaseId, miningSiteId

### 2. Create Services

Need to create:
- `/server/src/modules/lease/lease.service.ts`
- `/server/src/modules/client-type/client-type.service.ts`
- `/server/src/modules/expense-type/expense-type.service.ts`
- `/server/src/modules/account-type/account-type.service.ts`
- `/server/src/modules/general-ledger/general-ledger.service.ts`
- `/server/src/modules/liability/liability.service.ts`

### 3. Create Controllers

Need to create:
- `/server/src/modules/lease/lease.controller.ts`
- `/server/src/modules/client-type/client-type.controller.ts`
- `/server/src/modules/expense-type/expense-type.service.ts`
- `/server/src/modules/account-type/account-type.controller.ts`
- `/server/src/modules/general-ledger/general-ledger.controller.ts`
- `/server/src/modules/liability/liability.controller.ts`

### 4. Create Modules

Need to create:
- `/server/src/modules/lease/lease.module.ts`
- `/server/src/modules/client-type/client-type.module.ts`
- `/server/src/modules/expense-type/expense-type.module.ts`
- `/server/src/modules/account-type/account-type.module.ts`
- `/server/src/modules/general-ledger/general-ledger.module.ts`
- `/server/src/modules/liability/liability.module.ts`

### 5. Update App Module
Add new modules to `/server/src/app.module.ts`

### 6. Implement Mining Context

**Mining Site Selection:**
- Update `/server/src/modules/auth/auth.service.ts`
  - Add `selectMine(userId, mineId)` method
  - Store selected `mining_site_id` in JWT token payload

**Mining Context Guard:**
- Create `/server/src/modules/auth/guards/mining-context.guard.ts`
  - Extract `mining_site_id` from JWT
  - Auto-filter all queries by mining_site_id
  - Apply to all relevant controllers

**Mining Context Decorator:**
- Create `/server/src/decorators/mining-context.decorator.ts`
  - Extract current mining site from request
  - Inject into controller methods

### 7. Update Existing Controllers

Update to handle new fields and relationships:
- `/server/src/modules/clients/clients.controller.ts`
- `/server/src/modules/expenses/expenses.controller.ts`
- `/server/src/modules/income/income.controller.ts`
- `/server/src/modules/partners/partners.controller.ts`

### 8. Implement Liability Logic in Income Service

In `/server/src/modules/income/income.service.ts`:
```typescript
async createIncome(dto: CreateIncomeDto) {
  // 1. Check if client has active liabilities
  const liability = await this.findActiveClientLiability(dto.clientId, dto.miningSiteId);
  
  if (liability && liability.type === 'Advanced Payment') {
    // 2. Deduct from liability
    const amountToDeduct = Math.min(dto.coalPrice, liability.remainingBalance);
    
    // 3. Update liability
    await this.updateLiabilityBalance(liability.id, amountToDeduct);
    
    // 4. Create income with liability reference
    return this.incomeRepository.save({
      ...dto,
      amountFromLiability: amountToDeduct,
      liabilityId: liability.id,
    });
  }
  
  // Regular income creation
  return this.incomeRepository.save(dto);
}
```

---

## ⏳ PENDING - Mobile App Implementation

### 1. Create Models

Create Dart models for:
- `lib/models/lease.dart`
- `lib/models/client_type.dart`
- `lib/models/expense_type.dart`
- `lib/models/account_type.dart`
- `lib/models/general_ledger.dart`
- `lib/models/liability.dart`

### 2. Create Services

- `lib/services/lease_service.dart`
- `lib/services/client_type_service.dart`
- `lib/services/expense_type_service.dart`
- `lib/services/account_type_service.dart`
- `lib/services/general_ledger_service.dart`
- `lib/services/liability_service.dart`

Update:
- `lib/services/auth_service.dart` - add mining site selection
- `lib/services/client_service.dart` - add client type
- `lib/services/expense_service.dart` - add expense type, worker/client selection
- `lib/services/income_service.dart` - add liability integration

### 3. Create Screens

- `lib/screens/lease/lease_list_screen.dart`
- `lib/screens/lease/lease_form_screen.dart`
- `lib/screens/general_ledger/ledger_list_screen.dart`
- `lib/screens/general_ledger/ledger_form_screen.dart`
- `lib/screens/liability/liability_list_screen.dart`
- `lib/screens/liability/liability_form_screen.dart`
- `lib/screens/settings/client_type_management_screen.dart`
- `lib/screens/settings/expense_type_management_screen.dart`
- `lib/screens/settings/account_type_management_screen.dart`

Update:
- `lib/screens/auth/login_screen.dart` - add mining site selection after login
- `lib/screens/clients/client_form_screen.dart` - add client type dropdown
- `lib/screens/expenses/expense_form_screen.dart` - add expense type, conditional worker/client dropdown
- `lib/screens/income/income_form_screen.dart` - show liability info if exists

### 4. Update Navigation

Add routes in `lib/main.dart` or route configuration

---

## 📋 Testing Checklist

### Database
- [ ] Run migration successfully
- [ ] Verify all tables created
- [ ] Verify relationships (foreign keys)
- [ ] Verify default data inserted (types)

### Backend API
- [ ] Lease CRUD endpoints
- [ ] Client Type management
- [ ] Expense Type management
- [ ] Account Type management
- [ ] General Ledger CRUD
- [ ] Liability CRUD
- [ ] Updated Clients API
- [ ] Updated Expenses API
- [ ] Updated Income API (with liability deduction)
- [ ] Updated Partners API
- [ ] Mining site selection endpoint
- [ ] Verify mining context filtering

### Mobile App
- [ ] Login + Select mining site
- [ ] Create lease
- [ ] Manage client types
- [ ] Manage expense types
- [ ] Manage account types
- [ ] Create general ledger accounts
- [ ] Create expense (Worker type)
- [ ] Create expense (Vendor type)
- [ ] Create liability (Advanced Payment)
- [ ] Create income (verify liability deduction)
- [ ] Create liability (Loan)
- [ ] View audit trail (createdBy, modifiedBy)

---

## 📚 Documentation Created

1. ✅ `DATABASE_SCHEMA_UPDATE.md` - Comprehensive database schema documentation
2. ✅ `IMPLEMENTATION_SUMMARY.md` (this file) - Implementation status and next steps

---

## 🚀 Next Immediate Steps

1. **Execute Migration:**
   - Manually run SQL from migration file, OR
   - Resolve TypeORM conflicts and run migration

2. **Create DTOs** for all new entities (2-3 hours)

3. **Create Services and Controllers** for new entities (4-5 hours)

4. **Implement Mining Context** (2 hours)
   - Update AuthService
   - Create MiningContextGuard
   - Create MiningContext decorator

5. **Update Existing Controllers** (2-3 hours)

6. **Implement Liability Logic** in Income Service (1-2 hours)

7. **Test All Backend APIs** (2-3 hours)

8. **Create Mobile App Models and Services** (3-4 hours)

9. **Create Mobile App Screens** (8-10 hours)

10. **Test Full Flow** (3-4 hours)

**Total Estimated Time:** 27-36 hours

---

## 🎯 Priority Order

1. Execute migration (Critical)
2. Create DTOs + Services + Controllers for:
   - Lease
   - General Ledger
   - Liability
3. Implement Mining Context
4. Update existing controllers
5. Implement liability logic
6. Test backend
7. Implement mobile app
8. Test full system

---

**Status as of:** December 11, 2025  
**Completed:** Entity updates, Migration file, Documentation  
**Pending:** Migration execution, Services, Controllers, Mobile app

---

## ⚠️ Known Issues

1. TypeORM auto-migration conflicts with manual migrations
   - **Solution:** Execute SQL directly or clean migration table

2. Old Worker Supervisor migration records in database
   - **Solution:** Cleaned manually with SQL DELETE

---

## 💡 Recommendations

1. Use SQL transactions when executing migrations
2. Backup database before running migrations
3. Test liability deduction logic thoroughly
4. Consider adding mining_site_id index on all relevant tables
5. Implement soft deletes for audit purposes
6. Add data validation in DTOs
7. Add permission checks in guards
8. Consider adding query result caching for types (rarely change)

---

**Document Updated:** December 11, 2025
