# 🖥️ ScanIn Admin Panel (Flutter for Web)

ផ្ទាំងគ្រប់គ្រងរដ្ឋបាល Web Dashboard បង្កើតឡើងដោយ **Flutter for Web** សម្រាប់ប្រព័ន្ធវត្តមានសិស្ស **ScanIn Attendance System**។

---

## ១. ហេតុអ្វីជ្រើសរើស Flutter for Web?
* **ចែករំលែក Code រួមគ្នា (Code Sharing):** ប្រើប្រាស់ Models (`ClassModel`, `AttendanceModel`, `UserModel`), Colors (`AppColors`), និង Services ដូចគ្នាទៅនឹង Mobile App ដោយពុំបាច់សរសេរឡើងវិញ។
* **ភាសា Dart តែមួយ (Single Language):** ងាយស្រួលថែទាំ មិនបាច់ប្តូរចុះឡើងរវាង HTML/JS/CSS និង Dart។
* **Responsive Web Design:** គាំទ្រអេក្រង់ Desktop/Laptop ជាមួយ Sidebar, Navigation, និង Data Tables ស្រស់ស្អាត។
* **ភ្ជាប់ Laravel REST API & MySQL:** ផ្ទៀងផ្ទាត់សិទ្ធិដោយ Sanctum Bearer Token ផ្ទាល់ (`admin@scanin.app`).

---

## ២. របៀបដំណើរការ (How to Run)

```bash
cd scan_in_admin
flutter run -d chrome
```

ឬដំណើរការលើ Port ជាក់លាក់៖
```bash
flutter run -d chrome --web-port=3000
```

---

## ៣. គណនី Admin សម្រាប់សាកល្បង (Admin Credentials)
* **Email:** `admin@scanin.app`
* **Password:** `password123`
* **API Server:** `http://127.0.0.1:8000/api` (ត្រូវដំណើរការ `php artisan serve` ក្នុង `scan_in_backend`)
