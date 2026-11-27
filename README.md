# 🚀 ប្រព័ន្ធគ្រប់គ្រងវត្តមានសិស្សឆ្លាតវៃ (ScanIn Attendance System)

កម្មវិធីកត់ត្រាវត្តមានសិស្សស្វ័យប្រវត្តិតាមរយៈ **Dynamic QR Code**, **GPS Geofencing** និង **Face ID Check-In** ដែលមានសុវត្ថិភាព និងសុក្រឹតភាពខ្ពស់ ភ្ជាប់ដោយផ្ទាល់ទៅកាន់ MySQL Database តាមរយៈ Laravel RESTful API។

---

## 📁 រចនាសម្ព័ន្ធគម្រោង (Project Architecture)

* **`scan_in/`** ៖ កម្មវិធីទូរស័ព្ទដៃ (Flutter Mobile App សម្រាប់ Android & iOS)
  * **សិស្ស (Student) ៖** ស្កេន Dynamic QR Code ឬប្រើ **Face ID Check-In** (ផ្ទៀងផ្ទាត់ទីតាំង GPS ក្នុងបរិវេណសាលា + Single Device Binding), មើលកាលវិភាគ, ពិនិត្យប្រវត្តិវត្តមាន, Upload រូបថត Profile និងប្តូរពាក្យសម្ងាត់។
  * **គ្រូបង្រៀន (Lecturer) ៖** ពិនិត្យថ្នាក់ដែលបានចាត់តាំង, បញ្ចាំង Fullscreen QR Code, កែប្រែវត្តមានសិស្សដោយដៃ (`Present`, `Late`, `Absent`, `Reset`) និង Upload រូបថត Profile។
* **`scan_in_admin/`** ៖ ផ្ទាំងគ្រប់គ្រងរដ្ឋបាលលើកុំព្យូទ័រ (Flutter for Web)
  * **Master Admin (Rector) ៖** គ្រប់គ្រង Sub-Admin, គ្រូ, សិស្ស, ថ្នាក់រៀន, កំណត់ទីតាំង GPS សាលា, ទាញយក Template Excel (`.xlsx`) & Import សិស្សផ្ទាល់ (មានពិនិត្យឈ្មោះស្ទួន), បញ្ចាំង **Projector QR Mode (Live Auto-Refresh 3s)**, Export របាយការណ៍ **Excel / Print PDF** និងមើលស្ថិតិសិស្សទូទាំងសាលា។
  * **Sub-Admin (Academic Affairs) ៖** គ្រប់គ្រងគ្រូ, សិស្ស, ថ្នាក់រៀន, វត្តមាន និងរបាយការណ៍។
  * **Lecturer (Web) ៖** គ្រប់គ្រងថ្នាក់រៀនរបស់ខ្លួនឯង បញ្ចាំង Projector QR និងកែប្រែ/Export វត្តមានសិស្ស។
* **`scan_in_backend/`** ៖ ម៉ាស៊ីនបម្រើការ API (Laravel 12 RESTful API + MySQL)
  * ផ្ទៀងផ្ទាត់សិទ្ធិដោយ Laravel Sanctum Bearer Token និង Strict Role Guard Middleware។

---

## 🔐 គោលការណ៍គណនីប្រព័ន្ធ (Clean Production Architecture)

ប្រព័ន្ធនេះប្រើទម្រង់ **Clean Production Database** (គ្មានទិន្នន័យគំរូ Fake/Demo ក្នុង Seeder ឡើយ)៖

| តួនាទី (Role) | របៀបបង្កើតគណនី | ឧបករណ៍ដែលត្រូវប្រើ | សម្គាល់ |
| :--- | :--- | :--- | :--- |
| **👑 Master Admin** | បង្កើតតាម Terminal (`php artisan make:admin`) | **Web Admin (`scan_in_admin`)** | ជ្រើសរើសផ្ទាំង **"សាកលវិទ្យាធិការ"** (សម្រាប់ Web Admin ប៉ុណ្ណោះ) |
| **🛡️ Sub-Admin** | Master Admin បង្កើតក្នុង Web Admin | **Web Admin (`scan_in_admin`)** | ជ្រើសរើសផ្ទាំង **"គ្រូ / បុគ្គលិក"** |
| **👤 គ្រូបង្រៀន (Lecturer)** | Admin / Sub-Admin បង្កើតក្នុង Web Admin | **Mobile App & Web** | ជ្រើសរើស Role **"គ្រូ / បុគ្គលិក"** |
| **🎓 សិស្ស (Student)** | Admin បង្កើត ឬ Import Excel (`.xlsx`/`.csv`) | **Mobile App (`scan_in`)** | ជ្រើសរើស Role **"សិស្ស"** (មិនអាចចូល Web Admin បានទេ) |

---

## 🛠️ របៀបដំឡើងលើកុំព្យូទ័រថ្មី (New Machine Setup Guide)

នៅពេលទាញយក Code ពី GitHub មកដំឡើងលើកុំព្យូទ័រថ្មី (GitHub ផ្ទេរតែ Code មិនផ្ទេរ MySQL Data និង File `.env` ទេ) សូមអនុវត្តតាមជំហានខាងក្រោម៖

### ១. បង្កើត Database ក្នុង MySQL (phpMyAdmin)
1. បើក **XAMPP Control Panel** រួចចុច Start **Apache** និង **MySQL**។
2. ចូលទៅកាន់ `http://localhost/phpmyadmin` ➔ ចុច **`New`** ➔ បង្កើត Database ឈ្មោះ **`scan_in`** (Collation: `utf8mb4_unicode_ci`)។

### ២. កំណត់ File `.env` របស់ Laravel Backend
ចូលទៅក្នុងថត `scan_in_backend/` រួច Copy File `.env.example` ទៅជា `.env` (ឬបើក `.env` ដែលមានស្រាប់) ហើយកែត្រង់ផ្នែក Database ពី `sqlite` មក `mysql` ដូចខាងក្រោម៖
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=scan_in
DB_USERNAME=root
DB_PASSWORD=
```

### ៣. Run Command ដំឡើង Database និង Master Admin
បើក Terminal ក្នុង `scan_in_backend` រួចវាយ Command ទាំង ៥ ខាងក្រោមតាមលំដាប់៖
```bash
composer install
php artisan key:generate
php artisan config:clear
php artisan migrate
php artisan make:admin
php artisan storage:link
```

**តួនាទីនៃ Command នីមួយៗ ៖**
* `php artisan key:generate` ៖ បង្កើតសោរសម្ងាត់ (`APP_KEY`) ក្នុង `.env` សម្រាប់ Encrypt ទិន្នន័យសុវត្ថិភាព និង Token។
* `php artisan config:clear` ៖ លុប Cache ចាស់ៗដើម្បីឱ្យ Laravel អានការកំណត់ MySQL ថ្មីពី `.env` ភ្លាមៗ។
* `php artisan migrate` ៖ បង្កើត Tables ទាំងអស់ (`users`, `classes`, `attendances`, `campus_settings`, `personal_access_tokens`...) ចូលក្នុង MySQL `scan_in` ដោយស្វ័យប្រវត្តិ។
* `php artisan make:admin` ៖ បើក Form ក្នុង Terminal ដើម្បីបង្កើតគណនី **Master Admin** ដំបូងគេបង្អស់សម្រាប់ Login ចូល Web Admin។
* `php artisan storage:link` ៖ បង្កើតផ្លូវតភ្ជាប់ពី `public/storage` ទៅ `storage/app/public` ដើម្បីឱ្យរូបថត Profile (`avatars`) អាចបង្ហាញបានត្រឹមត្រូវ។

---

## ▶️ របៀបបើកដំណើរការប្រព័ន្ធ (Run All Apps)

### ១. បើកដំណើរការ Backend API (`scan_in_backend`)
```bash
cd scan_in_backend
php artisan serve --host=0.0.0.0 --port=8000
```
> API Base URL: `http://localhost:8000/api`

### ២. បើកដំណើរការ Admin Web Portal (`scan_in_admin`)
```bash
cd scan_in_admin
flutter pub get
flutter run -d chrome
```

### ៣. បើកដំណើរការ Mobile App (`scan_in`)
```bash
cd scan_in
flutter pub get
flutter run
```

---

## 🌐 ការកំណត់ Server IP សម្រាប់តេស្តគ្រប់ឧបករណ៍ (Server IP Setup)

នៅលើ Mobile App មានប្រអប់ **"កំណត់ Server IP"** ងាយស្រួលចុចប្តូរដោយមិនបាច់កែកូដ៖
* **Android Emulator ៖** ជ្រើសរើស `Emulator (10.0.2.2)`
* **ទូរស័ព្ទដៃពិត (Physical Phone / APK) ៖** ភ្ជាប់ Wi-Fi តែមួយជាមួយ PC, Run `php artisan serve --host=0.0.0.0 --port=8000`, រកមើល IPv4 តាម `ipconfig` រួចបញ្ចូលក្នុងប៊ូតុង **`Wi-Fi PC`**។
* **Windows Desktop ឬ Chrome Web ៖** ជ្រើសរើស `Localhost (127.0.0.1)`។

---

## 📚 ឯកសារយោងបន្ថែម (Documentation)

* 📘 **[NOTEBOOK.md](file:///C:/Flutter_Project/Scan_In_App/NOTEBOOK.md)** ៖ កំណត់ត្រាការងារលម្អិតគ្រប់ដំណាក់កាល (Tasks 1–22) និង FFC Audit History។
* 📄 **[APP_OVERVIEW.txt](file:///C:/Flutter_Project/Scan_In_App/APP_OVERVIEW.txt)** ៖ ទិដ្ឋភាពទូទៅនៃប្រព័ន្ធ គោលបំណងចម្បង ការបែងចែកសិទ្ធិតាម Role និងបញ្ជី Endpoints ទាំងអស់។
