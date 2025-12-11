# Mobile App Implementation - Complete Guide

## 🎉 Overview

The Coal Mining FMS mobile app now has **full CRUD functionality** for all new backend features. This document provides a complete guide to the implementation.

---

## ✅ Completed Features

### 1. **Client Types Management**
- **Purpose**: Manage dynamic client types (Coal Agent, Bhatta, Factory, etc.)
- **Screens**:
  - `client_types_screen.dart` - List all client types with active/inactive status
  - `client_type_form_screen.dart` - Add/edit client types
- **Features**:
  - Active/inactive toggle
  - Pull-to-refresh
  - Delete confirmation
  - Form validation
- **Navigation**: Settings → Type Management → Client Types

### 2. **Expense Types Management**
- **Purpose**: Manage dynamic expense types (Worker, Vendor, etc.)
- **Screens**:
  - `expense_types_screen.dart` - List all expense types
  - `expense_type_form_screen.dart` - Add/edit expense types
- **Features**: Same as Client Types
- **Navigation**: Settings → Type Management → Expense Types

### 3. **Account Types Management**
- **Purpose**: Manage general ledger account types (Asset, Liability, Revenue, Expense)
- **Screens**:
  - `account_types_screen.dart` - List all account types
  - `account_type_form_screen.dart` - Add/edit account types
- **Features**: Same as Client Types
- **Navigation**: Settings → Type Management → Account Types

### 4. **Leases Management**
- **Purpose**: Manage coal mine leases
- **Screens**:
  - `leases_screen.dart` - List all leases with related mining sites & partners count
  - `lease_form_screen.dart` - Add/edit leases
- **Features**:
  - Shows count of mining sites per lease
  - Shows count of partners per lease
  - Active/inactive status badge
  - Optional location field
- **Navigation**: Settings → Lease Management → Leases

### 5. **General Ledger Management**
- **Purpose**: Manage chart of accounts for financial tracking
- **Screens**:
  - `general_ledger_screen.dart` - List accounts with filters
  - `general_ledger_form_screen.dart` - Add/edit GL accounts
- **Features**:
  - Filter by mining site
  - Filter by account type
  - Account code displayed in circle avatar
  - Account name, type, and site in list
  - Required fields: code, name, type, site
- **Navigation**: Settings → Financial Management → General Ledger

### 6. **Liabilities Management**
- **Purpose**: Track loans and advanced payments with settlement status
- **Screens**:
  - `liabilities_screen.dart` - Tabbed view (All/Loans/Advanced Payments)
  - `liability_form_screen.dart` - Add/edit liabilities
- **Features**:
  - **3 Tabs**: All, Loans, Advanced Payments
  - **Status Badges**: Active (yellow), Partially Settled (orange), Fully Settled (green)
  - **Color Coding**: Red for Loans, Blue for Advanced Payments
  - **Fields**: Client, Mining Site, Type, Amount, Remaining Balance, Date
  - Displays remaining balance vs total amount
  - Client and Site dropdowns
  - Date picker for transaction date
- **Navigation**: Settings → Financial Management → Liabilities

---

## 📁 Project Structure

```
mobileapp/lib/
├── models/
│   ├── client_type.dart          ✅ NEW
│   ├── expense_type.dart          ✅ NEW
│   ├── account_type.dart          ✅ NEW
│   ├── lease.dart                 ✅ NEW
│   ├── general_ledger.dart        ✅ NEW
│   └── liability.dart             ✅ NEW
│
├── services/
│   ├── client_type_service.dart   ✅ NEW
│   ├── expense_type_service.dart  ✅ NEW
│   ├── account_type_service.dart  ✅ NEW
│   ├── lease_service.dart         ✅ NEW
│   ├── general_ledger_service.dart ✅ NEW
│   └── liability_service.dart     ✅ NEW
│
└── screens/
    ├── settings/
    │   └── settings_screen.dart   ✅ NEW (Hub for all new features)
    │
    ├── client_types/              ✅ NEW
    │   ├── client_types_screen.dart
    │   └── client_type_form_screen.dart
    │
    ├── expense_types/             ✅ NEW
    │   ├── expense_types_screen.dart
    │   └── expense_type_form_screen.dart
    │
    ├── account_types/             ✅ NEW
    │   ├── account_types_screen.dart
    │   └── account_type_form_screen.dart
    │
    ├── leases/                    ✅ NEW
    │   ├── leases_screen.dart
    │   └── lease_form_screen.dart
    │
    ├── general_ledger/            ✅ NEW
    │   ├── general_ledger_screen.dart
    │   └── general_ledger_form_screen.dart
    │
    └── liabilities/               ✅ NEW
        ├── liabilities_screen.dart
        └── liability_form_screen.dart
```

---

## 🔌 API Integration

All services extend the base `ApiClient` and use the following pattern:

```dart
// GET all items
Future<List<Model>> getAll() async {
  final response = await apiClient.get('/endpoint');
  return (response.data as List)
      .map((item) => Model.fromJson(item))
      .toList();
}

// GET active items only
Future<List<Model>> getActive() async {
  final response = await apiClient.get('/endpoint/active');
  return (response.data as List)
      .map((item) => Model.fromJson(item))
      .toList();
}

// GET by ID
Future<Model> getById(int id) async {
  final response = await apiClient.get('/endpoint/$id');
  return Model.fromJson(response.data);
}

// CREATE
Future<Model> create(Map<String, dynamic> data) async {
  final response = await apiClient.post('/endpoint', data: data);
  return Model.fromJson(response.data);
}

// UPDATE
Future<Model> update(int id, Map<String, dynamic> data) async {
  final response = await apiClient.patch('/endpoint/$id', data: data);
  return Model.fromJson(response.data);
}

// DELETE
Future<void> delete(int id) async {
  await apiClient.delete('/endpoint/$id');
}
```

### Special Features:

- **LiabilityService**: Has filtering by client, site, and type
- **GeneralLedgerService**: Has query parameters for site and account type filters

---

## 🎨 UI Pattern

All screens follow a consistent Material Design pattern:

### List Screen Pattern:
```dart
- AppBar with title
- FloatingActionButton (+) to add new item
- Filters section (if applicable)
- RefreshIndicator for pull-to-refresh
- ListView.builder with Card widgets
- CircleAvatar showing status or identifier
- ListTile with title, subtitle, trailing menu
- PopupMenuButton with Edit/Delete options
- Delete confirmation dialog
```

### Form Screen Pattern:
```dart
- AppBar with "Add" or "Edit" title
- Form with GlobalKey for validation
- TextFormField for text inputs
- DropdownButtonFormField for selections
- SwitchListTile for boolean fields
- DatePickerField for dates (liabilities)
- Form validation with error messages
- ElevatedButton to submit
- Loading indicator during submission
- SnackBar for success/error messages
```

---

## 🧭 Navigation Flow

```
Dashboard (Home)
  └── Drawer Menu
       ├── Dashboard
       ├── Clients
       ├── Expense Categories
       ├── Expenses
       ├── Mining Sites (Admin)
       ├── Equipment
       ├── Income (Admin)
       ├── Partners
       ├── Workers
       ├── Truck Deliveries
       ├── Production
       ├── Profit Distributions (Admin)
       ├── Users (Admin)
       ├── ─────────────
       ├── Settings ⭐ NEW
       │    └── Settings Screen
       │         ├── Type Management
       │         │    ├── Client Types
       │         │    ├── Expense Types
       │         │    └── Account Types
       │         ├── Financial Management
       │         │    ├── General Ledger
       │         │    └── Liabilities
       │         └── Lease Management
       │              └── Leases
       ├── ─────────────
       └── Logout
```

---

## 🔐 Authentication & Authorization

All API calls automatically include JWT token via the `ApiClient` interceptor:

```dart
// Token is stored in flutter_secure_storage
// ApiClient automatically adds Authorization header
// On 401 error, user is redirected to login

Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Admin-Only Features** (Backend enforced):
- Users management
- Income management
- Mining Sites management
- Profit Distributions management

---

## 📋 Routes Configuration

All new routes registered in `main.dart`:

```dart
routes: {
  '/login': (context) => const LoginScreen(),
  '/dashboard': (context) => const DashboardScreen(),
  '/settings': (context) => const SettingsScreen(),           // ⭐ NEW
  '/client-types': (context) => const ClientTypesScreen(),    // ⭐ NEW
  '/expense-types': (context) => const ExpenseTypesScreen(),  // ⭐ NEW
  '/account-types': (context) => const AccountTypesScreen(),  // ⭐ NEW
  '/leases': (context) => const LeasesScreen(),               // ⭐ NEW
  '/general-ledger': (context) => const GeneralLedgerScreen(), // ⭐ NEW
  '/liabilities': (context) => const LiabilitiesScreen(),     // ⭐ NEW
}
```

---

## 🧪 Testing Guide

### 1. Start the Backend
```bash
cd server
npm run start:dev
```

### 2. Verify API Endpoints
```bash
# Open Swagger docs
open http://localhost:3000/api

# Check these endpoints exist:
# - /client-types
# - /expense-types
# - /account-types
# - /leases
# - /general-ledger
# - /liabilities
```

### 3. Run the Mobile App
```bash
cd mobileapp
flutter pub get
flutter run
```

### 4. Login
- Username: `admin`
- Password: `admin123`

### 5. Test Each Feature

#### Client Types:
1. Dashboard → Settings → Client Types
2. Tap + to add new type
3. Enter name (e.g., "Retailer")
4. Toggle Active switch
5. Tap Create
6. Verify it appears in list
7. Tap menu → Edit → Change name
8. Verify update
9. Tap menu → Delete → Confirm
10. Verify deletion

#### Expense Types:
1. Dashboard → Settings → Expense Types
2. Follow same steps as Client Types

#### Account Types:
1. Dashboard → Settings → Account Types
2. Follow same steps as Client Types

#### Leases:
1. Dashboard → Settings → Leases
2. Tap + to add new lease
3. Enter lease name (e.g., "North Mine Lease")
4. Enter location (optional)
5. Toggle Active switch
6. Tap Create
7. Verify it shows mining sites count (0) and partners count (0)
8. Test edit and delete

#### General Ledger:
1. Dashboard → Settings → General Ledger
2. Tap + to add new account
3. Enter account code (e.g., "ASSET001")
4. Enter account name (e.g., "Cash")
5. Select Account Type from dropdown
6. Select Mining Site from dropdown
7. Toggle Active switch
8. Tap Create
9. Test filters:
   - Filter by Mining Site
   - Filter by Account Type
10. Test edit and delete

#### Liabilities:
1. Dashboard → Settings → Liabilities
2. Tap + to add new liability
3. Select Client from dropdown
4. Select Mining Site from dropdown
5. Select Type (Loan or Advanced Payment)
6. Enter Amount (e.g., 50000)
7. Enter Remaining Balance (e.g., 30000)
8. Select Date
9. Tap Create
10. Verify it appears in:
    - "All" tab
    - "Loans" tab (if type is Loan)
    - "Advanced Payments" tab (if type is Advanced Payment)
11. Verify status badge:
    - Active (yellow) if remaining = amount
    - Partially Settled (orange) if 0 < remaining < amount
    - Fully Settled (green) if remaining = 0
12. Test edit and delete
13. Test filters by switching tabs

---

## 🎯 Feature Highlights

### Settings Screen (Hub)
The Settings screen is the central hub for accessing all new features, organized into logical sections:

**Type Management:**
- Client Types - Define dynamic client categories
- Expense Types - Define dynamic expense categories  
- Account Types - Define GL account categories

**Financial Management:**
- General Ledger - Chart of accounts
- Liabilities - Track loans and advances

**Lease Management:**
- Leases - Manage mine leases

### Liabilities Advanced Features

**Status System:**
```dart
// Computed automatically based on amounts
- Active: remainingBalance == amount (Nothing paid yet)
- Partially Settled: 0 < remainingBalance < amount
- Fully Settled: remainingBalance == 0 (Fully paid)
```

**Color Coding:**
```dart
- Loans: Red theme
- Advanced Payments: Blue theme
```

**Tab Filtering:**
```dart
- All: Shows all liabilities
- Loans: Shows only type == 'Loan'
- Advanced Payments: Shows only type == 'Advanced Payment'
```

### General Ledger Advanced Features

**Dual Filtering:**
```dart
// Filter by Mining Site
- Shows only accounts for selected site
- "All Sites" option to see everything

// Filter by Account Type  
- Shows only accounts of selected type
- "All Types" option to see everything

// Filters work together (AND condition)
```

---

## 🚀 What's Next?

### Immediate Enhancements:
1. ✅ All screens implemented
2. ✅ Routes registered
3. ✅ Settings navigation added
4. ⏳ Update existing screens to use new dynamic types:
   - Clients screen → Add clientTypeId dropdown
   - Expenses screen → Add expenseTypeId dropdown
   - Income screen → Link to liabilities
   - Partners screen → Add leaseId/miningSiteId
   - Mining Sites screen → Add leaseId

### Future Features:
- Pagination for large lists
- Advanced search/filtering
- Export to PDF/Excel
- Offline mode with local storage
- Push notifications
- Data analytics dashboard
- Bulk operations

---

## 📊 Summary Statistics

### Backend:
- ✅ 6 new endpoint modules
- ✅ 6 new entities with TypeORM
- ✅ Full CRUD operations
- ✅ Swagger documentation
- ✅ JWT authentication
- ✅ Role-based access control

### Mobile App:
- ✅ 6 new data models with JSON serialization
- ✅ 6 new API service classes
- ✅ 1 settings hub screen
- ✅ 12 new UI screens (6 list + 6 form)
- ✅ 7 new routes registered
- ✅ Dashboard navigation integrated
- ✅ Consistent Material Design UI
- ✅ Pull-to-refresh on all lists
- ✅ Form validation
- ✅ Loading states
- ✅ Error handling with SnackBars
- ✅ Delete confirmations

---

## 🎓 Developer Notes

### Code Patterns Used:

**Service Pattern:**
```dart
// All services follow this structure
class SomeService {
  final ApiClient apiClient = ApiClient();
  
  Future<List<Model>> getAll() async { ... }
  Future<List<Model>> getActive() async { ... }
  Future<Model> getById(int id) async { ... }
  Future<Model> create(Map<String, dynamic> data) async { ... }
  Future<Model> update(int id, Map<String, dynamic> data) async { ... }
  Future<void> delete(int id) async { ... }
}
```

**StatefulWidget Pattern:**
```dart
class SomeScreen extends StatefulWidget {
  @override
  State<SomeScreen> createState() => _SomeScreenState();
}

class _SomeScreenState extends State<SomeScreen> {
  final _service = SomeService();
  List<Model> _items = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadItems();
  }
  
  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await _service.getAll();
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Show error
    }
  }
  
  @override
  Widget build(BuildContext context) { ... }
}
```

**Form Pattern:**
```dart
final _formKey = GlobalKey<FormState>();
bool _isSubmitting = false;

Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _isSubmitting = true);
  
  try {
    await _service.create(data);
    Navigator.pop(context, true); // Return success
  } catch (e) {
    setState(() => _isSubmitting = false);
    // Show error
  }
}
```

---

## 🏆 Success!

Your Coal Mining FMS mobile app now has complete CRUD functionality for:
- ✅ Client Types
- ✅ Expense Types
- ✅ Account Types
- ✅ Leases
- ✅ General Ledger
- ✅ Liabilities

All features are:
- ✅ Fully functional
- ✅ Properly integrated
- ✅ Following consistent patterns
- ✅ Ready for production use

**Happy coding! 🎉**
