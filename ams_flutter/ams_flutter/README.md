# 📋 AMS – Attendance Master Scholar (Flutter)

A clean, full-featured attendance management app built in Flutter/Dart.  
Converted from the original React/TSX design — same screens, same logic, native mobile.

---

## ✨ Features

- **Dashboard** — Today's stats, 7-day bar chart trend, status breakdown
- **Students** — Add/delete students, search, auto-generated IDs
- **Mark Attendance** — Tap to cycle Present → Absent → Late → Leave, date picker, save
- **History** — Filter by date range, status, student name; grouped by date
- **Settings** — Dark mode toggle, factory reset, data overview

---

## 🛠 Tech Stack

| Layer | Tech |
|---|---|
| Framework | Flutter 3.x |
| Language | Dart |
| State | Provider (`ChangeNotifier`) |
| Storage | `shared_preferences` (local persistence) |
| Charts | `fl_chart` |
| Date formatting | `intl` |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0.0
- VS Code + Flutter extension (or Android Studio)

### Run locally

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/ams_flutter.git
cd ams_flutter

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run
```

### Build APK

```bash
flutter build apk --release
```

APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── student.dart             # Student model
│   └── attendance_record.dart  # AttendanceRecord model + Status enum
├── providers/
│   └── app_provider.dart        # Global state (ChangeNotifier)
├── screens/
│   ├── home_shell.dart          # Bottom nav shell
│   ├── dashboard_screen.dart    # Dashboard + chart
│   ├── students_screen.dart     # Students CRUD
│   ├── mark_attendance_screen.dart  # Mark attendance
│   ├── history_screen.dart      # History + filters
│   └── settings_screen.dart     # Settings
└── utils/
    └── theme.dart               # Themes, colors, status helpers
```

---

## 🔮 Planned / TODO

- [ ] Supabase integration (sync to cloud)
- [ ] Google OAuth login
- [ ] Export CSV to device storage / share
- [ ] Import students from CSV file
- [ ] Push notifications for daily attendance reminder
- [ ] Multi-class / multi-subject support

---

## 👤 Author

**Abhishek BH**  
Full-stack developer · Flutter / FastAPI / Supabase  
[GitHub](https://github.com/YOUR_USERNAME) · [Instagram](https://instagram.com/YOUR_HANDLE)

---

> Built with Flutter 💙
