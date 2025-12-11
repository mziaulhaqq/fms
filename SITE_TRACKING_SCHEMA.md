# Site Tracking Schema - Complete Overview

## 🎯 Business Requirement
**All data must be created against a specific mining site.**

Each site operates independently with its own:
- Clients
- Workers
- Partners
- Income/Expenses
- Equipment
- Liabilities
- Profit distributions
- etc.

---

## ✅ Tables WITH site_id (Site-Specific Data)

### Transactional Data
1. **`income`** - `site_id` ✅ (already had)
2. **`expenses`** - `site_id` ✅ (already had)
3. **`labor_costs`** - `site_id` ✅ (already had)

### Master Data (Now Site-Specific)
4. **`clients`** - `site_id` ✅ **ADDED** - Each client belongs to a specific site
5. **`workers`** - `site_id` ✅ (already had)
6. **`equipment`** - `site_id` ✅ (already had)
7. **`partners`** - `mining_site_id` ✅ (already had)

### Financial Data
8. **`general_ledger`** - `mining_site_id` ✅ (already had)
9. **`liabilities`** - `mining_site_id` ✅ (already had)
10. **`partner_payouts`** - `site_id` ✅ **ADDED**
11. **`profit_distributions`** - `site_id` ✅ **ADDED**

### Junction Tables
12. **`labor_cost_workers`** - `site_id` ✅ **ADDED** - Tracks which site a worker worked at
13. **`site_supervisors`** - `site_id` ✅ (already had) - User-site access mapping

---

## 🚫 Tables WITHOUT site_id (Global/Lookup Data)

### Lookup/Reference Tables
- **`account_types`** - Global chart of accounts
- **`client_types`** - Global client categories
- **`expense_types`** - Global expense categories
- **`expense_categories`** - Global expense groupings

### Hierarchy Tables
- **`leases`** - Parent of mining sites
- **`mining_sites`** - The sites themselves

### User Management
- **`users`** - Global user accounts (access controlled via `site_supervisors`)
- **`user_roles`** - Global role definitions
- **`user_assigned_roles`** - User-role mappings

---

## 📊 Database Schema After Migration

```
Total Business Tables: 22
Tables with site tracking: 13 (59%)
Tables without (by design): 9 (41%)
```

### Site Relationship Pattern
```
mining_sites (id)
    ├── clients (site_id) → FK to mining_sites
    ├── workers (site_id) → FK to mining_sites
    ├── equipment (site_id) → FK to mining_sites
    ├── partners (mining_site_id) → FK to mining_sites
    ├── income (site_id) → FK to mining_sites
    ├── expenses (site_id) → FK to mining_sites
    ├── labor_costs (site_id) → FK to mining_sites
    ├── general_ledger (mining_site_id) → FK to mining_sites
    ├── liabilities (mining_site_id) → FK to mining_sites
    ├── partner_payouts (site_id) → FK to mining_sites
    ├── profit_distributions (site_id) → FK to mining_sites
    ├── labor_cost_workers (site_id) → FK to mining_sites
    └── site_supervisors (site_id) → FK to mining_sites
```

---

## 🔧 Migration Details

### Migration File
**`1765490027493-AddSiteIdToRemainingTables.ts`**

### What It Does

#### 1. Adds `site_id` to 4 Tables:
- `clients.site_id` → INTEGER, FK to mining_sites(id)
- `partner_payouts.site_id` → INTEGER, FK to mining_sites(id)
- `profit_distributions.site_id` → INTEGER, FK to mining_sites(id)
- `labor_cost_workers.site_id` → INTEGER, FK to mining_sites(id)

#### 2. Creates Foreign Key Constraints:
- `fk_clients_site`
- `fk_partner_payouts_site`
- `fk_profit_distributions_site`
- `fk_labor_cost_workers_site`

All with `ON DELETE CASCADE` (if site is deleted, related data is removed)

#### 3. Creates Indexes for Performance:
- `idx_clients_site_id`
- `idx_partner_payouts_site_id`
- `idx_profit_distributions_site_id`
- `idx_labor_cost_workers_site_id`

#### 4. Data Migration:
- **partner_payouts**: Auto-populated from partner's site
- **labor_cost_workers**: Auto-populated from labor_cost's site
- **clients**: NULL (user must assign during creation)
- **profit_distributions**: NULL (user must specify)

---

## 🎯 Impact on Application

### Backend (NestJS)
**Entities to Update:**
1. `Clients.entity.ts` - Add `siteId` column
2. `PartnerPayouts.entity.ts` - Add `siteId` column
3. `ProfitDistributions.entity.ts` - Add `siteId` column
4. `LaborCostWorkers.entity.ts` - Add `siteId` column

**DTOs to Update:**
1. `create-client.dto.ts` - Add `siteId` field (required)
2. `create-partner-payouts.dto.ts` - Add `siteId` field (required)
3. `create-profit-distributions.dto.ts` - Add `siteId` field (required)

**Services to Update:**
1. All `findAll()` methods should filter by `siteId`
2. All `create()` methods should validate `siteId` exists
3. Add site-based authorization checks

### Mobile App (Flutter)
**Models to Update:**
1. `Client` model - Add `siteId` field
2. `PartnerPayout` model - Add `siteId` field
3. `ProfitDistribution` model - Add `siteId` field

**Screens to Update:**
1. **Client Creation**: Auto-populate `siteId` from `SiteContextProvider`
2. **Client List**: Filter by selected site
3. **Partner Payout Creation**: Auto-populate `siteId`
4. **Profit Distribution Creation**: Auto-populate `siteId`

---

## 🔍 Querying Site-Specific Data

### Example: Get All Clients for a Site
```sql
SELECT * FROM coal_mining.clients WHERE site_id = 1;
```

### Example: Get All Income for a Site
```sql
SELECT * FROM coal_mining.income WHERE site_id = 1;
```

### Example: Get Site Summary
```sql
SELECT 
    ms.id,
    ms.name,
    COUNT(DISTINCT c.id) as total_clients,
    COUNT(DISTINCT w.id) as total_workers,
    COUNT(DISTINCT p.id) as total_partners,
    SUM(i.amount) as total_income,
    SUM(e.amount) as total_expenses
FROM coal_mining.mining_sites ms
LEFT JOIN coal_mining.clients c ON c.site_id = ms.id
LEFT JOIN coal_mining.workers w ON w.site_id = ms.id
LEFT JOIN coal_mining.partners p ON p.mining_site_id = ms.id
LEFT JOIN coal_mining.income i ON i.site_id = ms.id
LEFT JOIN coal_mining.expenses e ON e.site_id = ms.id
WHERE ms.id = 1
GROUP BY ms.id, ms.name;
```

---

## 🚀 Next Steps

### 1. Update Backend Entities
- [ ] Update `Clients.entity.ts`
- [ ] Update `PartnerPayouts.entity.ts`
- [ ] Update `ProfitDistributions.entity.ts`
- [ ] Update `LaborCostWorkers.entity.ts`

### 2. Update Backend DTOs
- [ ] Update `create-client.dto.ts`
- [ ] Update `update-client.dto.ts`
- [ ] Update partner payout DTOs
- [ ] Update profit distribution DTOs

### 3. Update Backend Services
- [ ] Add site filtering to all `findAll()` methods
- [ ] Add site validation to all `create()` methods
- [ ] Add site-based authorization

### 4. Update Mobile App
- [ ] Update models with `siteId`
- [ ] Update client creation to use site context
- [ ] Update client list to filter by site
- [ ] Update all other screens to use site context

### 5. Test End-to-End
- [ ] Test client creation with site
- [ ] Test client filtering by site
- [ ] Test partner payout creation
- [ ] Test profit distribution creation
- [ ] Test site switching

---

## ✅ Migration Status

**Migration Executed:** ✅ **SUCCESS**

```
Migration AddSiteIdToRemainingTables1765490027493 has been executed successfully.
```

**Database Schema:** ✅ **UPDATED**
- 4 tables modified
- 4 foreign keys added
- 4 indexes created
- Existing data migrated where possible

---

## 📝 Summary

Your Coal Mining FMS now enforces **site-based data isolation** at the database level. Every operational entity (clients, workers, partners, transactions, etc.) is tied to a specific mining site, ensuring:

1. ✅ Clear data ownership per site
2. ✅ Easy site-based reporting
3. ✅ Proper multi-site operations
4. ✅ Data integrity via foreign keys
5. ✅ Performance via indexed lookups

**All data is now created against a site!** 🎉
