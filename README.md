# Qarazdaree - Complete Code Documentation 📱

## Project Overview
**Qarazdaree** is a Flutter loan management application that helps users track loans and payments for multiple people. It uses SQLite for local storage and Riverpod for state management.

---

## 📁 Database Layer

### `Dbhelper` Class
**Purpose:** Handles all SQLite database operations

**Key Functions:**

| Function | Purpose | What It Does |
|----------|---------|--------------|
| `initDB()` | Initialize database | Creates the database file and tables if they don't exist |
| `resueDB()` | Get database instance | Returns existing database connection or creates new one |
| `insertData(PersonModel)` | Save person | Stores a new person in database and returns their unique ID |
| `updatePerson(PersonModel)` | Update person | Updates an existing person's information (name, address, image) |
| `getAll()` | Load all persons | Retrieves every person from database as a list of maps |
| `readPerson(int id)` | Get single person | Finds one person by their ID |
| `deletePerson(int id)` | Remove person | Deletes a person and all their transactions (cascade delete) |
| `insertLoan(TransactionModel)` | Save transaction | Stores a new loan/transaction record |
| `getTranPerson(int personId)` | Get transactions | Retrieves all transactions for a specific person |
| `getDailyLoanAmounts()` | Daily summary | Gets total loan amounts for the last 7 days |

**Tables Created:**
1. **Person Table**: Stores `id`, `name`, `address`, `imagePath`
2. **Transactions Table**: Stores `id`, `personId`, `loan`, `paid`, `dateTime`, `note`

---

## 📦 Models

### `PersonModel` Class
**Purpose:** Blueprint for a person object

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `id` | int | Unique identifier (0 = temporary) |
| `name` | String | Person's full name |
| `address` | String? | Optional address |
| `imagePath` | String? | File path to profile photo |

**Methods:**
- `toMap()`: Converts Person to Map for database
- `fromMap()`: Creates Person from database map

### `TransactionModel` Class
**Purpose:** Blueprint for a transaction/loan record

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `id` | int | Unique transaction ID |
| `personId` | int | ID of the person this belongs to |
| `loan` | int | Amount given as loan |
| `paid` | int | Amount paid back |
| `dateTime` | DateTime | When the transaction occurred |
| `note` | String? | Optional note about transaction |

**Methods:**
- `toMap()`: Converts Transaction to Map for database
- `fromMap()`: Creates Transaction from database map

---

## 🎯 State Management (Notifiers)

### `Service` Notifier
**Purpose:** Manages the list of all persons in the app

**State:** `List<PersonModel>` - Complete list of all persons

**Key Functions:**

| Function | Purpose | Flow |
|----------|---------|------|
| `build()` | Initialize | Called when app starts → Loads all persons from DB into state |
| `insert(PersonModel)` | Add person | Gets temp person → Saves to DB → Gets real ID → Updates state with new person |
| `readAll()` | Load data | Fetches all persons from DB → Converts to models → Updates state |
| `updatePerson(PersonModel)` | Edit person | Updates person in DB → Updates person in state list |
| `deleteRow(int id)` | Remove person | Gets person's image path → Deletes image file → Deletes from DB → Removes from state |
| `deleteImageFile(String?)` | Cleanup | Deletes the physical image file from device storage |

**How It Works:**
1. App starts → `build()` runs → `readAll()` loads all persons
2. User adds person → `insert()` saves to DB → State updates → UI rebuilds
3. User deletes person → `deleteRow()` removes from DB and state → UI updates

---

### `TransactionNotifier` Notifier
**Purpose:** Manages transactions for a specific person

**State:** `List<TransactionModel>` - Transactions for current person

**Key Functions:**

| Function | Purpose | Flow |
|----------|---------|------|
| `build()` | Initialize | Starts with empty list |
| `insertTransactions(TransactionModel)` | Add transaction | Saves to DB → Updates state with new transaction |
| `getTransPerson(int personId)` | Load transactions | Fetches all transactions for a person → Updates state |
| `getTotalLoan()` | Calculate balance | Sums all loans → Sums all payments → Returns leftover amount |

**How It Works:**
1. User opens a person's page → `getTransPerson()` loads their transactions
2. User adds loan/payment → `insertTransactions()` saves to DB → State updates → UI shows new transaction
3. `getTotalLoan()` calculates: `(Total Loan - Total Paid) = Remaining Balance`

---

### `navigationProvider`
**Purpose:** Tracks which bottom navigation tab is active

**State:** `int` (0 = Home, 1 = Statistics)

**How It Works:**
- User taps Home → State becomes 0 → Shows Maininterface
- User taps Statistics → State becomes 1 → Shows ChartScreen

---

## 🖥️ UI Screens

### `MyApp` (Main App)
**Purpose:** The root widget that sets up the app

**Key Features:**
- Wraps app in `ProviderScope` for Riverpod
- Sets up custom AppBar with gradient background
- Shows bottom navigation with Home and Statistics tabs
- Floating Action Button to add new persons

**Navigation Items:**
| Index | Label | Icon | Page |
|-------|-------|------|------|
| 0 | Home | Person | Maininterface |
| 1 | Statistics | Donut | ChartScreen |

---

### `Maininterface`
**Purpose:** Shows the home screen with all persons

**UI Elements:**
- List of all persons with their:
  - Profile photo (or initials)
  - Name
  - Address
  - Tap to view details
  - Delete button

**Key Interactions:**

| Action | What Happens |
|--------|--------------|
| Tap person | Navigates to Person page with that person's ID |
| Tap profile photo | Opens image picker (gallery/camera) to change photo |
| Tap delete icon | Shows confirmation dialog, then deletes person |
| Tap + FAB | Opens form to add new person |

**Image Handling:**
- `_showImagePicker()`: Opens bottom sheet with Gallery/Camera/Remove options
- `_handleImagePick()`: Takes photo → Saves to app directory → Updates person
- `_handleRemoveImage()`: Deletes photo file → Updates person without image

---

### `Person` Page
**Purpose:** Shows detailed information for a single person

**UI Elements:**
1. **AppBar**: Displays person's name
2. **Profile Photo**: CircleAvatar with photo or initials
3. **Balance Card**: Shows total remaining loan amount
4. **Transaction Table**: Lists all loans/payments with:
   - Date
   - Loan amount (red)
   - Paid amount (green)
   - Leftover amount

**Key Features:**
- Uses `widget.id` to find person in the state list
- Loads transactions when page opens
- Floating Action Button to add new transactions

**Balance Calculation:**
```
Total Loan = Sum of all loan amounts
Total Paid = Sum of all paid amounts
Leftover = Total Loan - Total Paid
```

---

### `Fourm` (Add Person Form)
**Purpose:** Dialog to add a new person

**Fields:**
| Field | Required | Validation |
|-------|----------|------------|
| Name | Yes | Cannot be empty |
| Address | No | Optional |

**Flow:**
1. User fills name and optional address
2. Taps "Add" button
3. `submit()` creates PersonModel with temporary ID (0)
4. Calls `insert()` on Service notifier
5. Dialog closes → Person added to list

---

### `AddLoanPaid`
**Purpose:** Dialog to add a loan or payment for a person

**Fields:**
| Field | Required | Input Type |
|-------|----------|------------|
| Loan | No | Number only |
| Paid | No | Number only |

**Validation:**
- At least one field must have a value
- Both can't be empty

**Flow:**
1. User enters loan amount and/or paid amount
2. Taps "Add" button
3. `submit()` creates TransactionModel
4. Calls `insertTransactions()` on TransactionNotifier
5. Dialog closes → Transaction appears in table

---

### `ChartScreen` (Statistics)
**Purpose:** Placeholder for future statistics feature

**Status:** 🚧 Under Construction
- Currently shows "Coming Soon" message
- Will display charts and analytics in future

---

### `DeletionAlert`
**Purpose:** Confirmation dialog before deleting a person

**UI:**
- Warning icon
- "Delete Person" title
- Confirmation message
- Cancel and Delete buttons

**Flow:**
1. User taps delete on a person
2. Shows this dialog
3. User confirms → `deleteRow()` called
4. Person removed from database and state

---

## 🛠️ Utility Services

### `ImageService` Class
**Purpose:** Handles all image-related operations

**Functions:**

| Function | Purpose |
|----------|---------|
| `requestPermission()` | Checks and requests camera/storage permissions |
| `getImageDirectory()` | Gets the app's image folder path |
| `pickImage()` | Opens gallery or camera to pick a photo |
| `saveImage()` | Copies selected photo to app folder and returns path |
| `deleteImage()` | Deletes a photo file from storage |
| `getImageFile()` | Gets File object from image path |

**Image Storage:**
- Images saved in: `documents/profile_images/person_{id}.jpg`
- Max size: 400x400 pixels
- Quality: 80% compression

---

## 🔄 Complete Data Flow Examples

### Adding a New Person
```
1. User taps + button
2. Form opens
3. User enters "John", "123 St"
4. User taps Add
5. create PersonModel(id:0, name:"John", address:"123 St")
6. Service.insert() called
7. Dbhelper.insertData() saves to Person table
8. Database returns realID (e.g., 7)
9. Service creates new PersonModel(id:7, name:"John", address:"123 St")
10. Service updates state: state = state + newPerson
11. UI rebuilds automatically
12. John appears in the list ✅
```

### Adding a Transaction
```
1. User taps + on Person page
2. AddLoanPaid dialog opens
3. User enters loan: 100, paid: 50
4. User taps Add
5. create TransactionModel(id:0, personId:7, loan:100, paid:50, dateTime:now)
6. TransactionNotifier.insertTransactions() called
7. Dbhelper.insertLoan() saves to Transactions table
8. TransactionNotifier updates state: state = state + newTransaction
9. UI rebuilds automatically
10. Transaction appears in table ✅
11. Balance updates to 50 ✅
```

### Deleting a Person
```
1. User taps delete icon on a person
2. DeletionAlert dialog shows
3. User confirms delete
4. Service.deleteRow(id:7) called
5. Gets person's imagePath
6. Deletes image file (if exists)
7. Dbhelper.deletePerson(7) called
8. ON DELETE CASCADE removes all transactions
9. Service updates state: state = state - deletedPerson
10. UI rebuilds automatically
11. Person removed from list ✅
```

### Changing Profile Photo
```
1. User taps profile photo on person
2. Bottom sheet opens with options
3. User chooses "Gallery" or "Camera"
4. ImageService.pickImage() opens picker
5. User selects/takes a photo
6. ImageService.saveImage() saves to app folder
7. Returns file path: /documents/profile_images/person_7.jpg
8. Service.updatePerson() called with new imagePath
9. Person updated in database
10. Service updates state
11. UI rebuilds with new photo ✅
```

---

## 🗺️ Navigation Structure

```
MyApp (Root)
├── Home Tab (index 0)
│   └── Maininterface
│       └── On tap person → Person page
│           └── On tap + → AddLoanPaid dialog
│       └── On tap + FAB → Fourm dialog
│       └── On tap delete → DeletionAlert dialog
│       └── On tap profile → Image picker
│
└── Statistics Tab (index 1)
    └── ChartScreen (Coming Soon)
```

---

## 📊 State Management Summary

| Provider | State Type | Purpose |
|----------|------------|---------|
| `serviceProvider` | `List<PersonModel>` | Manages all persons globally |
| `transactionProvider` | `List<TransactionModel>` | Manages transactions for current person |
| `navigationProvider` | `int` | Manages current bottom tab |

**Key Rule:** State changes → UI rebuilds automatically 🎯

---

## 🔑 Key Terms Glossary

| Term | Meaning |
|------|---------|
| **Provider** | Holds state and notifies listeners when it changes |
| **Notifier** | Contains business logic and updates state |
| **State** | The current data (e.g., list of persons) |
| **Consumer** | Widget that watches state and rebuilds when it changes |
| **ref.watch()** | Listens to state changes → rebuilds widget |
| **ref.read()** | One-time access to state/notifier → no rebuild |
| **Cascade Delete** | When a person is deleted, their transactions auto-delete |
| **Real ID** | The actual database ID (not the temporary 0) |
| **Image Path** | File system path where image is stored |

---

## 🚀 Future Improvements

1. **Statistics Screen**: Add charts for loan analytics
2. **Edit Person**: Allow editing name and address
3. **Edit Transaction**: Allow editing loans/payments
4. **Search**: Add search functionality for persons
5. **Export Data**: Backup/export to CSV or JSON
6. **Dark Mode**: Add theme support
7. **Notifications**: Reminders for pending loans
8. **Currency**: Support for different currencies

---

## 🏗️ Project Structure

```
qarazdare/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── database/
│   │   └── dbhelper.dart           # SQLite operations
│   ├── models/
│   │   ├── model.dart              # PersonModel
│   │   └── transaction_model.dart  # TransactionModel
│   ├── providers/
│   │   ├── notifier.dart           # Service notifier (persons)
│   │   ├── transaction_notifier.dart # Transaction notifier
│   │   ├── image_service.dart      # Image handling
│   │   └── deletion_alert.dart     # Delete confirmation dialog
│   ├── screens/
│   │   ├── maininterface.dart      # Home screen
│   │   ├── person.dart             # Person details
│   │   ├── form.dart               # Add person form
│   │   ├── add_loan_paid.dart      # Add transaction form
│   │   └── statitics.dart          # Statistics screen
│   └── widgets/
│       └── (various widgets)
└── pubspec.yaml                     # Dependencies
```

---

**🎉 Congratulations! Your Qarazdaree app is well-structured with clear separation of concerns using Riverpod for state management and SQLite for data persistence.**
