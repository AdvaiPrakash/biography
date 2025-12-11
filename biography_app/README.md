# Biography Business Manager

A comprehensive Flutter application for business management with elegant UI and user-friendly features.

## Features

### 1. Products Management
- ✅ Add/Edit/Delete Products
- ✅ Product Categories Management
- ✅ Stock Management
- ✅ Product Search
- ✅ Barcode Support
- ✅ Image Upload Support

### 2. Customer Management
- ✅ Add/Edit/Delete Customers
- ✅ Customer Search
- ✅ Contact Information Management

### 3. Invoice/Billing System
- ✅ Create Invoices
- ✅ Customer Selection
- ✅ Product Selection with Search
- ✅ Automatic Invoice Number Generation (INV-YYYY-XXXXXX)
- ✅ Stock Updates on Invoice Creation
- ✅ Invoice History

### 4. User Management (Admin Only)
- ✅ Create/Edit/Delete Users
- ✅ User Types: Admin & Staff
- ✅ Activity Logging
- ✅ Access Control

### 5. Dashboard
- ✅ Today's Sales
- ✅ Total Sales
- ✅ Product Count
- ✅ Customer Count
- ✅ Low Stock Alerts
- ✅ Stock Value Summary
- ✅ Recent Invoices

### 6. Profile & Authentication
- ✅ User Profile Display
- ✅ Login System
- ✅ Last Login Tracking
- ✅ Secure Logout

### 7. Activity Logging
- ✅ All user actions logged
- ✅ Admin can view all logs
- ✅ Timestamp tracking

## Setup Instructions

### Prerequisites
1. Flutter SDK (latest stable version)
2. Windows 10/11 with Developer Mode enabled

### Enable Developer Mode (Required for Windows)
1. Press `Win + I` to open Settings
2. Go to "Update & Security" → "For developers"
3. Enable "Developer Mode"
4. Restart your computer if prompted

### Installation
1. Clone or download the project
2. Navigate to the project directory:
   ```bash
   cd biography_app
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run -d windows
   ```

## Default Login Credentials
- **Email:** admin@biography.com
- **Password:** (any password - simplified for demo)

## Database
- Uses SQLite for local data storage
- Automatic database initialization
- Pre-populated with sample categories
- Default admin user created on first run

## App Structure
```
lib/
├── models/           # Data models
├── services/         # Database service
├── screens/          # UI screens
│   ├── products/     # Product management
│   ├── customers/    # Customer management
│   ├── invoices/     # Invoice/billing
│   └── users/        # User management
└── main.dart         # App entry point
```

## Key Technologies
- **Flutter** - Cross-platform UI framework
- **SQLite** - Local database
- **Material Design 3** - Modern UI components
- **Image Picker** - Product image selection
- **PDF Generation** - Invoice printing (ready for implementation)
- **Intl** - Date/number formatting

## Features Implemented
✅ Complete CRUD operations for all entities
✅ Search functionality
✅ Role-based access control
✅ Activity logging
✅ Stock management
✅ Invoice generation
✅ Dashboard analytics
✅ Responsive UI design
✅ Error handling
✅ Form validation

## Future Enhancements
- PDF invoice generation
- Barcode scanning
- Data export/import
- Multi-language support
- Cloud synchronization
- Advanced reporting

## Screenshots
The app features a clean, modern interface with:
- Blue color scheme
- Card-based layouts
- Intuitive navigation
- Responsive design
- Material Design 3 components

## Support
For any issues or questions, please refer to the Flutter documentation or create an issue in the project repository.