# 🚀 ប្រព័ន្ធគ្រប់គ្រងវត្តមានសិស្សឆ្លាតវៃ (ScanIn Attendance System)

កម្មវិធីកត់ត្រាវត្តមានសិស្សស្វ័យប្រវត្តិតាមរយៈ **Dynamic QR Code** ដែលមានសុវត្ថិភាព និងសុក្រឹតភាពខ្ពស់ ភ្ជាប់ដោយផ្ទាល់ទៅកាន់ MySQL Database តាមរយៈ Laravel RESTful API។

---

## 📁 រចនាសម្ព័ន្ធគម្រោង (Project Architecture)

* **`scan_in/`** ៖ កម្មវិធីទូរស័ព្ទដៃ (Flutter Mobile App សម្រាប់ Android & iOS)
  * **សិស្ស (Student)៖** ស្កេន Dynamic QR Code, មើលស្ថិតិវត្តមាន, ពិនិត្យប្រវត្តិវត្តមាន, និងប្តូរពាក្យសម្ងាត់ផ្ទាល់ខ្លួន។
  * **គ្រូបង្រៀន (Lecturer)៖** ពិនិត្យថ្នាក់ដែលបានចាត់តាំង, បញ្ចាំង Fullscreen QR លើ Projector/ទូរស័ព្ទ, និងកែប្រែវត្តមានជាក់ស្តែងក្នុងថ្នាក់។
* **`scan_in_admin/`** ៖ ផ្ទាំងគ្រប់គ្រងរដ្ឋបាលលើកុំព្យូទ័រ (Flutter for Web)
  * **Admin ផ្តាច់មុខ៖** បង្កើត/កែប្រែ/លុបគណនីគ្រូ, បង្កើត/កែប្រែ/លុបគណនីសិស្ស, នាំចូលសិស្សជាក្រុមពី **Excel / CSV (Bulk Import)**, បង្កើតថ្នាក់រៀន ចាត់តាំងគ្រូ និងពិនិត្យរបាយការណ៍ទូទាំងសាលា។
* **`scan_in_backend/`** ៖ ម៉ាស៊ីនបម្រើការ API (Laravel 12 RESTful API + MySQL)
  * ផ្ទៀងផ្ទាត់សិទ្ធិដោយ Laravel Sanctum Bearer Token និង Strict Role Guard Middleware។

---

## 🔑 គណនីសម្រាប់ Login សាកល្បង (Test Credentials)

| តួនាទី (Role) | អ៊ីមែល (Email) | ពាក្យសម្ងាត់ (Password) | ឧបករណ៍ដែលត្រូវប្រើ | សម្គាល់ |
| :--- | :--- | :--- | :--- | :--- |
| **🎓 សិស្ស (Student)** | `student@scanin.app` | `12345678` | **Mobile App (`scan_in`)** | ជ្រើសរើស Role Toggle **"សិស្ស"** |
| **👤 គ្រូបង្រៀន (Lecturer)** | `dara@scanin.app` | `223232323` | **Mobile App & Web** | ជ្រើសរើស Role Toggle **"គ្រូ / បុគ្គលិក"** |
| **⚡ អ្នកគ្រប់គ្រង (Admin)** | `admin@scanin.app` | `password123` | **Web Admin (`scan_in_admin`)** | សម្រាប់ Web Admin ប៉ុណ្ណោះ (មិនអាចចូល Mobile បានទេ) |

---

## 🌐 ការកំណត់ Server IP សម្រាប់តេស្តគ្រប់ឧបករណ៍ (Server IP Setup)

នៅលើ Mobile App មានប្រអប់ **"កំណត់ Server IP"** ងាយស្រួលចុចប្តូរដោយមិនបាច់កែកូដ៖

### ១. តេស្តលើ Android Emulator (ម៉ាស៊ីននិម្មិតលើ PC)
* **ជ្រើសរើសប៊ូតុង៖** `Emulator (10.0.2.2)`
* **ហេតុផល៖** នៅក្នុង Android Emulator វាមិនស្គាល់ `localhost` ឬ `127.0.0.1` របស់ PC ឡើយ (វានឹងរុករកក្នុងទូរស័ព្ទនិម្មិតខ្លួនឯង)។ លេខកូដពិសេស `10.0.2.2` គឺជាច្រកភ្ជាប់មកកាន់កុំព្យូទ័រ host។

### ២. តេស្តលើទូរស័ព្ទដៃពិតប្រាកដ (Physical Phone / File APK)
1. **ភ្ជាប់ Wi-Fi តែមួយ៖** ទូរស័ព្ទដៃ និងកុំព្យូទ័រ (PC) ត្រូវតែភ្ជាប់បណ្តាញ Wi-Fi ដូចគ្នា (ឬបើក Mobile Hotspot ពីទូរស័ព្ទឱ្យ PC ភ្ជាប់)។
2. **បើក Laravel Server ឱ្យទទួលការតភ្ជាប់ពីខាងក្រៅ៖**
   ```bash
   cd scan_in_backend
   php artisan serve --host=0.0.0.0 --port=8000
   ```
   *(ការដាក់ `--host=0.0.0.0` គឺចាំបាច់បំផុត ដើម្បីកុំឱ្យ Laravel ចាក់សោទទួលតែម៉ាស៊ីនខ្លួនឯង)*។
3. **ពិនិត្យ IP របស់កុំព្យូទ័រ៖** បើក PowerShell ឬ CMD វាយ `ipconfig` រួចមើលត្រង់ **IPv4 Address** (ឧ. `192.168.42.165` ឬ `192.168.1.xxx`)។
4. **កំណត់លើទូរស័ព្ទ៖** ជ្រើសរើសប៊ូតុង **`Wi-Fi PC`** ឬវាយលេខ IPv4 នោះចូលក្នុងប្រអប់ រួចចុច **"រក្សាទុក"**។

### ៣. តេស្តលើ Windows Desktop ឬ Chrome Web
* **ជ្រើសរើសប៊ូតុង៖** `Localhost (127.0.0.1)`។

---

## 🛠️ របៀបបើកដំណើរការគម្រោង (How to Run the Project)

### ១. បើកដំណើរការ Backend API (Laravel & MySQL)
```bash
# ត្រូវប្រាកដថាបានបើក MySQL ក្នុង XAMPP / WampServer ជាមុនសិន
cd scan_in_backend
php artisan serve --host=0.0.0.0 --port=8000
```
> API Base URL: `http://localhost:8000/api`

### ២. បើកដំណើរការ Admin Web Portal (`scan_in_admin`)
```bash
cd scan_in_admin
flutter run -d chrome
```

### ៣. បើកដំណើរការ Mobile App (`scan_in`)
```bash
cd scan_in
# Run លើ Android Emulator ឬ Device ដែលបានដោតភ្ជាប់
flutter run
```

---

## 🗄️ ការគ្រប់គ្រងទិន្នន័យគំរូ Seeder (Production DB Guide)

* **ទីតាំង File Seeder៖** [`scan_in_backend/database/seeders/DatabaseSeeder.php`](file:///d:/Flutter_Project/Scan_In_App/scan_in_backend/database/seeders/DatabaseSeeder.php)
* **នៅពេលចង់លុបទិន្នន័យគំរូចោលទាំងអស់ពេល Launch ប្រើពិតប្រាកដ (Production)៖**
  1. ចូលទៅកាន់ `DatabaseSeeder.php` លុបផ្នែកបង្កើតគ្រូ និងសិស្សគំរូចេញ ដោយទុកតែគណនី Admin ម្នាក់គត់។
  2. រត់ Command: `php artisan migrate:fresh --seed`
* ⚠️ **ការព្រមានសំខាន់៖** ហាមលុបគណនី Admin (`admin@scanin.app`) ចោលជាដាច់ខាត ព្រោះបើគ្មាន Admin ទេ នោះនឹងគ្មានអ្នកណាអាចចូលទៅបង្កើតថ្នាក់ ឬបង្កើតគណនីគ្រូ/សិស្សបានឡើយ។ នៅពេលប្រើពិតប្រាកដ គ្រាន់តែប្តូរ Password របស់ Admin ឱ្យមានសុវត្ថិភាពខ្ពស់ជាការស្រេច។

---

## 📚 ឯកសារយោង និងកំណត់ត្រាបន្ថែម (Documentation & Tracking)

* 📘 **[NOTEBOOK.md](file:///d:/Flutter_Project/Scan_In_App/NOTEBOOK.md)** ៖ បញ្ជីតាមដានការងារលម្អិត **UI-to-DB Connection Checklist** (តាមដានគ្រប់អេក្រង់ទាំង ៣២ មុខងារ ថាតើមួយណាបានភ្ជាប់ Database រួច និងមួយណានៅសល់)។
* 📄 **[APP_OVERVIEW.txt](file:///d:/Flutter_Project/Scan_In_App/APP_OVERVIEW.txt)** ៖ ទិដ្ឋភាពទូទៅនៃប្រព័ន្ធ គោលបំណងចម្បង ការបែងចែកសិទ្ធិតាម Role និងបញ្ជី Endpoints ទាំងអស់។
