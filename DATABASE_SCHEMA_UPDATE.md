# Database Schema Update - December 2025

## Overview
This document describes the comprehensive database schema updates for the Coal Mining FMS to support:
- Lease management
- Mining site hierarchy  
- Dynamic type management (Client Types, Expense Types, Account Types)
- General Ledger per mining site
- Liability tracking (Loans & Advanced Payments)
- Complete audit trail (createdBy, modifiedBy on all tables)
- Mining site context for all records

---

## New Tables

### 1. **leases**
Manages coal mine leases. One lease can have multiple mining sites.

| Column | Type | Description |
|--------|------|-------------|
| id | SERIAL | Primary key |
| lease_name | VARCHAR(255) | Name of the lease |
| location | TEXT | Lease location |
| is_active | BOOLEAN | Active status |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |
| created_by | INTEGER | FK to users |
| modified_by | INTEGER | FK to users |

**Relationships:**
- One-to-Many with `mining_sites`
- One-to-Many with `partners`

---

### 2. **client_types**
Dynamic client type management (Coal Agent, Bhatta, Factory, etc.).

| Column | Type | Description |
|--------|------|-------------|
| id | SERIAL | Primary key |
| name | VARCHAR(100) | Unique type name |
| description | TEXT | Type description |
| is_active | BOOLEAN | Active status |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |
| created_by | INTEGER | FK to users |
| modified_by | INTEGER | FK to users |

**Default Values:**
- Coal Agent
- Bhatta
- Factory

---

### 3. **expense_types**
Dynamic expense type management (Worker, Vendor, etc.).

| Column | Type | Description |
|--------|------|-------------|
| id | SERIAL | Primary key |
| name | VARCHAR(100) | Unique type name |
| description | TEXT | Type description |
| is_active | BOOLEAN | Active status |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |
| created_by | INTEGER | FK to users |
| modified_by | INTEGER | FK to users |

**Default Values:**
- Worker
- Vendor

---

### 4. **account_types**
Dynamic account type management for General Ledger.

| Column | Type | Description |
|--------|------|-------------|
| id | SERIAL | Primary key |
| name | VARCHAR(100) | Unique type name |
| description | TEXT | Type description |
| is_active | BOOLEAN | Active status |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |
| created_by | INTEGER | FK to users |
| modified_by | INTEGER | FK to users |

**Default Values:**
- Asset
- Liability
- Equity
- Revenue
- Expense

---

### 5. **general_ledger**
Chart of accounts per mining site.

| Column | Type | Description |
|--------|------|-------------|
| id | SERIAL | Primary key |
| account_code | VARCHAR(50) | Account code (e.g., 1010) |
| account_name | VARCHAR(255) | Account name (e.g., Cash in Hand) |
| account_type_id | INTEGER | FK to account_types |
| mining_site_id | INTEGER | FK to mining_sites |
| description | TEXT | Account description |
| is_active | BOOLEAN | Active status |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |
| created_by | INTEGER | FK to users |
| modified_by | INTEGER | FK to users |

**Key Features:**
- Each mining site has its own chart of accounts
- Account types are dynamic and can be added from mobile app
- Expense categories link to accounts where account_type = Expense

---

### 6. **liabilities**
Tracks client liabilities (Loans & Advanced Payments).

| Column | Type | Description |
|--------|------|-------------|
| id | SERIAL | Primary key |
| type | ENUM | 'Loan' or 'Advanced Payment' |
| client_id | INTEGER | FK to clients |
| mining_site_id | INTEGER | FK to mining_sites |
| date | DATE | Liability date |
| description | TEXT | Description |
| total_amount | NUMERIC(12,2) | Total amount |
| remaining_balance | NUMERIC(12,2) | Remaining balance |
| status | ENUM | 'Active', 'Partially Settled', 'Fully Settled' |
| proof | TEXT[] | Array of file paths |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |
| created_by | INTEGER | FK to users |
| modified_by | INTEGER | FK to users |

**Liability Types:**
- **Loan**: Client owes us money (we delivered coal first)
- **Advanced Payment**: We owe client coal (they paid in advance)

**How it works with Income:**
- When creating income, system checks if client has active liabilities
- If Advanced Payment exists, deduct from liability balance
- Track amount taken from liability in `income.amount_from_liability`
- Update liability.remaining_balance and status

---

## Updated Tables

### 1. **mining_sites**
Added lease relationship and audit fields.

**New Columns:**
- `lease_id` INTEGER (FK to leases)
- `created_by` INTEGER (FK to users)
- `modified_by` INTEGER (FK to users)

**New Relationships:**
- Many-to-One with `leases`
- One-to-Many with `general_ledger`
- One-to-Many with `liabilities`

---

### 2. **clients**
Added client type and audit fields.

**New Columns:**
- `client_type_id` INTEGER (FK to client_types)
- `modified_by` INTEGER (FK to users)

**New Relationships:**
- Many-to-One with `client_types`
- One-to-Many with `liabilities`
- One-to-Many with `expenses`

**Note:** Clients are global (can work with multiple sites), but transactions are tracked per site.

---

### 3. **expenses**
Complete restructure with dynamic types.

**New Columns:**
- `expense_type_id` INTEGER (FK to expense_types)
- `worker_id` INTEGER (FK to workers) - nullable
- `client_id` INTEGER (FK to clients) - nullable  
- `proof` TEXT[] (unified field)
- `modified_by` INTEGER (FK to users)

**Removed Columns:**
- `evidence_photos` (replaced by `proof`)
- `payment_proof` (replaced by `proof`)
- `account_type` (replaced by expense_type_id)
- `payee_type` (replaced by expense_type_id)

**How it works:**
1. Category comes from General Ledger where account_type = Expense
2. Expense Type (Worker/Vendor) determines which dropdown shows:
   - Worker → Show workers from current mining site
   - Vendor → Show clients

---

### 4. **income**
Added liability integration.

**New Columns:**
- `client_id` INTEGER (FK to clients)
- `amount_from_liability` NUMERIC(12,2) - Amount deducted from liability
- `liability_id` INTEGER - Reference to liability if used
- `modified_by` INTEGER (FK to users)

**Income Calculation Logic:**
```
If client has Advanced Payment liability:
  - Deduct coal_price from liability.remaining_balance
  - Set income.amount_from_liability = coal_price
  - Set income.liability_id = liability.id
  - Update liability.remaining_balance
  - Update liability.status if fully settled
Else:
  - Create income as normal (instant payment)
  - amount_from_liability = 0
```

---

### 5. **partners**
Added lease, mining site relationships.

**New Columns:**
- `lease_id` INTEGER (FK to leases)
- `mining_site_id` INTEGER (FK to mining_sites)
- `created_by` INTEGER (FK to users)
- `modified_by` INTEGER (FK to users)

**Removed Columns:**
- `lease` VARCHAR (replaced by lease_id FK)
- `mine_number` (replaced by mining_site_id FK)

**Note:** `share_percentage` determines profit distribution per partner per mining site.

---

### 6. **equipment**, **production**, **workers**
Added audit trail fields.

**New Columns for All:**
- `created_by` INTEGER (FK to users)
- `modified_by` INTEGER (FK to users)

---

## Mining Site Context

### How It Works:

1. **User Login** → Selects mining site
2. **Mining site ID stored in JWT token**
3. **All API calls automatically filtered by mining_site_id**
4. **Guards ensure data isolation between sites**

### Tables with mining_site_id:
- ✅ mining_sites (obviously)
- ✅ general_ledger
- ✅ liabilities
- ✅ expenses
- ✅ income
- ✅ workers
- ✅ equipment
- ✅ production
- ✅ partners
- ✅ labor_costs
- ✅ site_supervisors
- ✅ truck_deliveries

### Global Tables (no mining_site_id):
- users
- clients (global, but transactions are per site)
- leases
- client_types
- expense_types
- account_types
- user_roles
- user_assigned_roles

---

## Audit Trail

All tables now have:
- `created_at` - Auto-populated on creation
- `updated_at` - Auto-updated on modification
- `created_by` - User ID who created the record
- `modified_by` - User ID who last modified the record

This is handled by `AuditEntity` base class that entities extend.

---

## API Endpoints to Implement

### Lease Management
- `GET /leases` - List all leases
- `POST /leases` - Create lease
- `GET /leases/:id` - Get lease details
- `PUT /leases/:id` - Update lease
- `DELETE /leases/:id` - Delete lease

### Client Type Management
- `GET /client-types` - List all types
- `POST /client-types` - Create type
- `PUT /client-types/:id` - Update type
- `DELETE /client-types/:id` - Delete type

### Expense Type Management
- `GET /expense-types` - List all types
- `POST /expense-types` - Create type
- `PUT /expense-types/:id` - Update type
- `DELETE /expense-types/:id` - Delete type

### Account Type Management
- `GET /account-types` - List all types
- `POST /account-types` - Create type
- `PUT /account-types/:id` - Update type
- `DELETE /account-types/:id` - Delete type

### General Ledger
- `GET /general-ledger` - List accounts for current mining site
- `POST /general-ledger` - Create account
- `PUT /general-ledger/:id` - Update account
- `DELETE /general-ledger/:id` - Delete account

### Liability Management
- `GET /liabilities` - List liabilities for current mining site
- `POST /liabilities` - Create liability
- `GET /liabilities/:id` - Get liability details
- `PUT /liabilities/:id` - Update liability
- `DELETE /liabilities/:id` - Delete liability
- `GET /liabilities/client/:clientId` - Get client liabilities for current site

### Mining Context
- `POST /auth/select-mine/:mineId` - Set active mining site in JWT

---

## Migration Instructions

1. **Backup database:**
```bash
pg_dump -U postgres -d miningdb > backup_$(date +%Y%m%d).sql
```

2. **Run migration:**
```bash
cd server
npm run migration:run
```

3. **Verify:**
```bash
npm run migration:show
```

4. **Rollback if needed:**
```bash
npm run migration:revert
```

---

## Testing Checklist

- [ ] Create lease
- [ ] Assign mining site to lease
- [ ] Create client types from mobile app
- [ ] Create expense types from mobile app
- [ ] Create account types from mobile app
- [ ] Create general ledger accounts per site
- [ ] Create expenses with Worker type (select worker)
- [ ] Create expenses with Vendor type (select client)
- [ ] Create Advanced Payment liability
- [ ] Create income and verify liability deduction
- [ ] Create Loan liability
- [ ] Create partners with percentage share
- [ ] Verify audit trail on all tables
- [ ] Test mining site context filtering

---

## Next Steps

1. ✅ Schema migration created
2. ⏳ Run migration on database
3. ⏳ Create DTOs for new entities
4. ⏳ Create services and controllers
5. ⏳ Implement mining context guard
6. ⏳ Update existing controllers
7. ⏳ Test all endpoints
8. ⏳ Update mobile app

---

## Notes

- All file uploads (proof, evidence) stored in `uploads/` directory
- Proof files stored as TEXT[] array of file paths
- Liability balance automatically calculated on income creation
- Income formula: `Revenue - (Expenses + Liabilities deducted)`
- Profit distribution uses partner.share_percentage per mining site
- Each mining site maintains its own financial records
- Clients are shared across sites but transactions are site-specific

---

**Migration Created:** December 11, 2025
**Migration File:** `1765481906729-ComprehensiveSchemaUpdate.ts`
**Status:** Ready for execution
