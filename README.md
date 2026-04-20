# 🛒 Smart Kirana Management System
**Flutter + Firebase Realtime Database**

## Features
- 📦 **Inventory Management** — Add, edit, delete products with category, price, qty, unit
- 🔍 **Search** — Filter products instantly in Inventory & Sales
- 🧾 **Billing** — Build cart, save bill, auto-deduct stock
- 📊 **Dashboard** — Today's sales, low stock alerts, recent bills
- 🔥 **Firebase Realtime DB** — All data syncs live across devices

---

## ⚙️ Setup Steps

### 1. Create Firebase Project
1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Create a new project (e.g., `kirana-shop`)
3. Enable **Realtime Database** → Start in **test mode**

### 2. Add your app to Firebase
Run in your project folder:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
This auto-generates `lib/firebase_options.dart` with correct credentials.

**OR** manually paste values from Firebase Console → Project Settings → Your App into `lib/firebase_options.dart`.

### 3. Android Setup
- Download `google-services.json` from Firebase Console
- Place it in `android/app/`

### 4. iOS Setup
- Download `GoogleService-Info.plist` from Firebase Console
- Add it to `ios/Runner/` via Xcode

### 5. Set Database Rules
In Firebase Console → Realtime Database → Rules, paste:
```json
{
  "rules": {
    "products": { ".read": true, ".write": true },
    "bills":    { ".read": true, ".write": true }
  }
}
```

### 6. Run the App
```bash
flutter pub get
flutter run
```

---

## 📁 Project Structure
```
lib/
├── main.dart                  # App entry + bottom nav
├── firebase_options.dart      # 🔥 YOUR FIREBASE CONFIG HERE
├── models/
│   ├── product.dart           # Product model
│   └── bill.dart              # Bill + BillItem model
├── services/
│   └── firebase_service.dart  # All Firebase CRUD operations
└── screens/
    ├── dashboard_screen.dart  # Stats + Low stock + Recent bills
    ├── inventory_screen.dart  # Product list + Search + Add/Edit
    ├── billing_screen.dart    # Cart builder + Save bill
    └── bills_screen.dart      # Sales history + Search
```

---

## 📦 Dependencies
```yaml
firebase_core: ^2.24.2
firebase_database: ^10.4.0
uuid: ^4.2.1
intl: ^0.18.1
```
