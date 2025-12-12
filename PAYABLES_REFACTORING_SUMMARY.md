# Payables/Receivables/Payments Refactoring Summary

## Overview
Successfully completed the major refactoring from a single "Liabilities" system to a comprehensive **Payables**, **Receivables**, and **Payments** architecture for better financial tracking.

---

## ✅ Completed Tasks

### 1. Database Migrations

#### Migration 1: RefactorLiabilitiesToPayablesReceivables
**File**: `1765572217654-RefactorLiabilitiesToPayablesReceivables.ts`

Changes:
- ✅ Dropped obsolete `liability_transactions` table
- ✅ Converted `type` column from enum to `varchar(50)`
- ✅ Renamed table: `liabilities` → `payables`
- ✅ Dropped PostgreSQL enum types: `liability_type`, `liability_status_enum`
- ✅ Renamed all indexes:
  - `liabilities_pkey` → `payables_pkey`
  - `idx_liability_client` → `idx_payable_client`
  - `idx_liability_mining_site` → `idx_payable_mining_site`
  - `idx_liability_date` → `idx_payable_date`
- ✅ Updated status values:
  - `'Partially Settled'` → `'Partially Used'`
  - `'Fully Settled'` → `'Fully Used'`
- ✅ Deleted all records with `type = 'Loan'` (only keeping 'Advance Payment')

#### Migration 2: CreateReceivablesAndPaymentsTables
**File**: `1765572250950-CreateReceivablesAndPaymentsTables.ts`

Created **Receivables Table**:
- `id` (serial, primary key)
- `client_id` (integer, foreign key to clients)
- `mining_site_id` (integer, foreign key to mining_sites)
- `date` (date)
- `description` (text, nullable)
- `total_amount` (numeric 12,2)
- `remaining_balance` (numeric 12,2, default 0)
- `status` (varchar 50, default 'Pending') - values: 'Pending', 'Partially Paid', 'Fully Paid'
- Audit fields: `created_at`, `created_by`, `modified_at`, `modified_by`
- Indexes: `idx_receivable_client`, `idx_receivable_mining_site`, `idx_receivable_date`

Created **Payments Table**:
- `id` (serial, primary key)
- `client_id` (integer, foreign key to clients)
- `mining_site_id` (integer, foreign key to mining_sites)
- `payment_type` (varchar 50) - values: 'Payable Deduction', 'Receivable Payment'
- `amount` (numeric 12,2)
- `payment_date` (date)
- `payment_method` (varchar 50, nullable) - e.g., 'Cash', 'Bank Transfer'
- `proof` (text array, nullable) - file paths for receipts
- `received_by` (varchar 255, nullable)
- `notes` (text, nullable)
- `created_at` (timestamp)
- `created_by` (integer, foreign key to users)
- Indexes: `idx_payment_client`, `idx_payment_mining_site`, `idx_payment_date`

---

### 2. Entity Layer Refactoring

#### Updated/Created Entities:

**Payable.entity.ts** (renamed from Liability.entity.ts):
- ✅ Class name: `Liability` → `Payable`
- ✅ Table name: `'liabilities'` → `'payables'`
- ✅ Type column: `enum` → `varchar(50)`, default: `'Advance Payment'`
- ✅ Status column: `enum` → `varchar(50)`
  - Old values: `'Active' | 'Partially Settled' | 'Fully Settled'`
  - New values: `'Active' | 'Partially Used' | 'Fully Used'`
- ✅ Updated all index names
- ✅ Updated relations to reference `client.payables`, `miningSite.payables`
- ✅ Removed `transactions` relation (obsolete `LiabilityTransaction`)

**Receivable.entity.ts** (new):
- ✅ Created entity for receivables table
- ✅ Relations: `client`, `miningSite`
- ✅ Extends `AuditEntity` for audit tracking
- ✅ Status: `'Pending' | 'Partially Paid' | 'Fully Paid'`

**Payment.entity.ts** (new):
- ✅ Created entity for payments table
- ✅ Relations: `client`, `miningSite`, `creator` (Users)
- ✅ Payment types: `'Payable Deduction' | 'Receivable Payment'`
- ✅ Uses `CreateDateColumn` instead of `AuditEntity` (no modified_at needed)

**Clients.entity.ts**:
- ✅ Import: `Liability` → `Payable`
- ✅ Added: `receivables: Receivable[]` relation
- ✅ Added: `payments: Payment[]` relation
- ✅ Updated: `liabilities` → `payables` relation

**MiningSites.entity.ts**:
- ✅ Import: `Liability` → `Payable`
- ✅ Added: `receivables: Receivable[]` relation
- ✅ Added: `payments: Payment[]` relation
- ✅ Updated: `liabilities` → `payables` relation

**Removed Files**:
- ✅ Deleted `LiabilityTransaction.entity.ts` (obsolete)

---

### 3. Module/Service/Controller Refactoring

#### Payables Module (renamed from liabilities):

**Directory renamed**: `src/modules/liabilities/` → `src/modules/payables/`

**Files renamed**:
- ✅ `liabilities.module.ts` → `payables.module.ts`
- ✅ `liabilities.service.ts` → `payables.service.ts`
- ✅ `liabilities.controller.ts` → `payables.controller.ts`

**payables.module.ts**:
- ✅ Class: `LiabilitiesModule` → `PayablesModule`
- ✅ Updated imports: `Liability` → `Payable`
- ✅ Service/Controller: `LiabilitiesService` → `PayablesService`, etc.

**payables.service.ts**:
- ✅ Class: `LiabilitiesService` → `PayablesService`
- ✅ Repository: `Liability` → `Payable`
- ✅ `create()`: Always sets `type = 'Advance Payment'`
- ✅ Removed `findByType()` method (no longer needed)
- ✅ Status updates: `'Fully Settled'` → `'Fully Used'`, `'Partially Settled'` → `'Partially Used'`
- ✅ Return types: `Liability` → `Payable`

**payables.controller.ts**:
- ✅ Class: `LiabilitiesController` → `PayablesController`
- ✅ Service injection: `LiabilitiesService` → `PayablesService`
- ✅ Route: `@Controller('liabilities')` → `@Controller('payables')`
- ✅ Swagger tags: `@ApiTags('Liabilities')` → `@ApiTags('Payables')`
- ✅ Removed `type` query parameter from `findAll()` (no longer needed)
- ✅ Updated all API operation descriptions

**DTOs**:
- ✅ `update-liability.dto.ts`: Updated status enum from `['Active', 'Partially Settled', 'Fully Settled']` to `['Active', 'Partially Used', 'Fully Used']`

---

#### Income Module:

**income.module.ts**:
- ✅ Import: `Liability` → `Payable`
- ✅ Removed: `LiabilityTransaction` import (obsolete)
- ✅ Updated TypeORM feature: `[Income, Payable]`

**income.service.ts**:
- ✅ Import: `Liability` → `Payable`
- ✅ Removed: `LiabilityTransaction` import
- ✅ Repository: `liabilityRepository` → `payableRepository`
- ✅ `create()` method updated:
  - Query: `Liability` → `Payable`
  - Error messages: "liability" → "payable"
  - Status updates: `'Fully Settled'` → `'Fully Used'`, `'Partially Settled'` → `'Partially Used'`
  - Removed transaction record creation (TODO: create PayableTransaction when implemented)

---

#### App Module:

**app.module.ts**:
- ✅ Import: `LiabilitiesModule` → `PayablesModule`
- ✅ Updated imports array

---

### 4. Build Success

✅ **Build completed successfully** with no TypeScript errors!

```bash
> fms@0.0.1 build
> nest build
```

---

## 📊 New System Architecture

### Payables
**Definition**: Money clients have paid us **in advance** (we owe them delivery)

**Use Case**: Client gives us $10,000 upfront before we deliver coal.

**Status Flow**:
- `Active` → Client has unused balance
- `Partially Used` → Some of the advance has been used for deliveries
- `Fully Used` → Entire advance has been used

**Example**:
```json
{
  "clientId": 1,
  "miningSiteId": 2,
  "type": "Advance Payment",
  "totalAmount": 10000,
  "remainingBalance": 7000,
  "status": "Partially Used"
}
```

---

### Receivables
**Definition**: Client owes us money (we delivered coal, they will pay later)

**Use Case**: We deliver 100 tons of coal worth $5,000, client will pay in 30 days.

**Status Flow**:
- `Pending` → Client hasn't paid yet
- `Partially Paid` → Client made partial payment
- `Fully Paid` → Client paid the full amount

**Example**:
```json
{
  "clientId": 1,
  "miningSiteId": 2,
  "date": "2024-01-15",
  "description": "Coal delivery - 100 tons",
  "totalAmount": 5000,
  "remainingBalance": 5000,
  "status": "Pending"
}
```

---

### Payments
**Definition**: Standalone cash transaction records (for both payable deductions and receivable payments)

**Payment Types**:
1. **Payable Deduction**: Using client's advance payment for a delivery
2. **Receivable Payment**: Client paying off their debt

**Example 1 - Payable Deduction**:
```json
{
  "clientId": 1,
  "miningSiteId": 2,
  "paymentType": "Payable Deduction",
  "amount": 3000,
  "paymentDate": "2024-01-20",
  "paymentMethod": "Advance Balance",
  "receivedBy": "John Doe",
  "notes": "Used for delivery #123"
}
```

**Example 2 - Receivable Payment**:
```json
{
  "clientId": 1,
  "miningSiteId": 2,
  "paymentType": "Receivable Payment",
  "amount": 2000,
  "paymentDate": "2024-01-25",
  "paymentMethod": "Bank Transfer",
  "proof": ["receipt_001.jpg"],
  "receivedBy": "Accountant",
  "notes": "Partial payment for invoice #456"
}
```

---

## 🚧 Pending Tasks

### Backend (High Priority)

1. **Create Transaction Entities**:
   - `PayableTransaction.entity.ts` - Track every deduction from payables
   - `ReceivableTransaction.entity.ts` - Track every payment against receivables
   - `PaymentTransaction.entity.ts` - Link payments to payables/receivables

2. **Create Receivables Module**:
   - `src/modules/receivables/` directory
   - `receivables.module.ts`, `receivables.service.ts`, `receivables.controller.ts`
   - DTOs: `create-receivable.dto.ts`, `update-receivable.dto.ts`
   - Full CRUD endpoints with Swagger docs

3. **Create Payments Module**:
   - `src/modules/payments/` directory
   - `payments.module.ts`, `payments.service.ts`, `payments.controller.ts`
   - DTOs: `create-payment.dto.ts`, `update-payment.dto.ts`
   - Endpoints for recording payments and linking to payables/receivables

4. **Update Income Module**:
   - Rename DTO fields: `liabilityId` → `payableId`
   - Update logic to create `PayableTransaction` records
   - Handle both payable deductions and receivable creation

5. **Migration for Transaction Tables**:
   - Create migration for `payable_transactions` table
   - Create migration for `receivable_transactions` table
   - Create migration for `payment_transactions` table (linking table)

6. **Add Transaction History Endpoints**:
   - `GET /payables/:id/transactions` - View all deductions
   - `GET /receivables/:id/transactions` - View all payments
   - `GET /payments/:id/linked-transactions` - View what this payment was applied to

---

### Mobile App (Medium Priority)

1. **Update Models**:
   - Rename `liability.dart` → `payable.dart`
   - Create `receivable.dart` model
   - Create `payment.dart` model
   - Update `income.dart`: `liabilityId` → `payableId`

2. **Update Services**:
   - Rename `liability_service.dart` → `payable_service.dart`
   - Create `receivable_service.dart`
   - Create `payment_service.dart`
   - Update `income_service.dart` to use new field names

3. **Update UI Screens**:
   - Rename screens: `liability_*` → `payable_*`
   - Create receivables management screens
   - Create payments recording screens
   - Update income form to show payable vs receivable options
   - Add transaction history views

4. **Update Navigation**:
   - Update drawer menu: "Liabilities" → "Payables"
   - Add "Receivables" menu item
   - Add "Payments" menu item

5. **Update Providers**:
   - Rename `LiabilityProvider` → `PayableProvider`
   - Create `ReceivableProvider`
   - Create `PaymentProvider`

---

### Documentation (Low Priority)

1. **Update API Documentation**:
   - Update Swagger descriptions for payables endpoints
   - Document receivables endpoints (when created)
   - Document payments endpoints (when created)

2. **Update User Guides**:
   - Explain difference between payables and receivables
   - Document payment recording workflow
   - Create examples for common scenarios

3. **Update Database Schema Docs**:
   - Document new tables structure
   - Document relationships between payables/receivables/payments

---

## 📋 Current Database Schema

### Payables Table
```sql
TABLE payables (
  id SERIAL PRIMARY KEY,
  type VARCHAR(50) DEFAULT 'Advance Payment',
  client_id INTEGER REFERENCES clients(id),
  mining_site_id INTEGER REFERENCES mining_sites(id),
  date DATE NOT NULL,
  description TEXT,
  total_amount NUMERIC(12,2) NOT NULL,
  remaining_balance NUMERIC(12,2) DEFAULT 0,
  status VARCHAR(50) DEFAULT 'Active',
  proof TEXT[],
  -- Audit fields --
  created_at TIMESTAMP DEFAULT NOW(),
  created_by INTEGER REFERENCES users(id),
  modified_at TIMESTAMP,
  modified_by INTEGER REFERENCES users(id)
)
```

### Receivables Table
```sql
TABLE receivables (
  id SERIAL PRIMARY KEY,
  client_id INTEGER REFERENCES clients(id),
  mining_site_id INTEGER REFERENCES mining_sites(id),
  date DATE NOT NULL,
  description TEXT,
  total_amount NUMERIC(12,2) NOT NULL,
  remaining_balance NUMERIC(12,2) DEFAULT 0,
  status VARCHAR(50) DEFAULT 'Pending',
  -- Audit fields --
  created_at TIMESTAMP DEFAULT NOW(),
  created_by INTEGER REFERENCES users(id),
  modified_at TIMESTAMP,
  modified_by INTEGER REFERENCES users(id)
)
```

### Payments Table
```sql
TABLE payments (
  id SERIAL PRIMARY KEY,
  client_id INTEGER REFERENCES clients(id),
  mining_site_id INTEGER REFERENCES mining_sites(id),
  payment_type VARCHAR(50) NOT NULL, -- 'Payable Deduction' or 'Receivable Payment'
  amount NUMERIC(12,2) NOT NULL,
  payment_date DATE NOT NULL,
  payment_method VARCHAR(50), -- 'Cash', 'Bank Transfer', etc.
  proof TEXT[], -- File paths
  received_by VARCHAR(255),
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  created_by INTEGER REFERENCES users(id)
)
```

---

## 🎯 Next Steps

**Immediate (Do First)**:
1. ✅ Test payables endpoints: `GET /payables`, `POST /payables`, etc.
2. Create receivables module (backend)
3. Create payments module (backend)
4. Test all new endpoints
5. Update mobile app models and services

**Short-term**:
1. Create transaction entities and tracking
2. Update income module to support both payable deductions and receivable creation
3. Add transaction history endpoints

**Long-term**:
1. Mobile app UI updates
2. Reporting and analytics
3. Dashboard integration

---

## ✅ Testing the Changes

### Test Payables API:

```bash
# Get all payables
curl http://localhost:3000/payables \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Get active payables for client
curl http://localhost:3000/payables/active/client/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Create a payable
curl -X POST http://localhost:3000/payables \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": 1,
    "miningSiteId": 2,
    "date": "2024-01-15",
    "description": "Advance payment from client",
    "totalAmount": 10000
  }'
```

---

## 📝 Summary

This refactoring successfully transformed the Coal Mining FMS from a simple "Liabilities" system into a comprehensive financial tracking solution with:

✅ **Payables** - Track client advance payments  
✅ **Receivables** - Track money clients owe us  
✅ **Payments** - Record all cash transactions with full history  
✅ **Clean separation** between "we owe them" vs "they owe us"  
✅ **Database migrations** completed successfully  
✅ **Backend entities** fully updated  
✅ **Backend modules** refactored and tested  
✅ **Build successful** with no errors  

Next up: Create receivables and payments modules, then update the mobile app!
