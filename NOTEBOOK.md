# 📓 កំណត់ត្រាសង្ខេបគម្រោង (ScanIn Attendance System Notebook)

---

## 🌟 គោលបំណង និងចក្ខុវិស័យរបស់ម្ចាស់គម្រោង (Owner's Vision & Production Philosophy)

1. **ផ្លាស់ប្តូរទៅកាន់ប្រព័ន្ធផលិតកម្មពិតប្រាកដ (Transition to Real Clean Production)៖**
   * ប្រព័ន្ធត្រូវតែស្អាតស្អំ (Clean State) គ្មានគណនីតេស្ត ឬ Demo Seed Data រឹង (`dara@scanin.app`, `student@scanin.app`) នៅសេសសល់ក្នុង MySQL ឬ Seeder ឡើយ។
   * គ្រប់គណនី គ្រូ សិស្ស និងថ្នាក់រៀន គឺជាទិន្នន័យពិតប្រាកដ (Real Production Data) ដែលត្រូវបានបង្កើត និងគ្រប់គ្រងតាមលំដាប់លំដោយរដ្ឋបាលសាលា។

2. **រចនាសម្ព័ន្ធអ្នកគ្រប់គ្រង និងការបង្កើតគណនី (Admin Hierarchy & Provisioning)៖**
   * **មិនអនុញ្ញាតឱ្យមានការចុះឈ្មោះ Admin សេរីលើ Web ឡើយ** ដើម្បីធានាសុវត្ថិភាពអតិបរមា។
   * **Master Admin (អ្នកគ្រប់គ្រងកំពូល)៖** បង្កើតឡើងដោយផ្ទាល់តាមរយៈពាក្យបញ្ជា Terminal CLI `php artisan make:admin` (មានសុវត្ថិភាពខ្ពស់ ដោយវាយបញ្ចូល Name, Email និង Password លាក់ផ្កាយ)។
   * **Sub-Admin (បុគ្គលិកការិយាល័យសិក្សា)៖** Master Admin ជាអ្នកបង្កើត និងកំណត់សិទ្ធិ (Permissions) លើ Web Admin ដើម្បីជួយសម្រួលការងារចុះឈ្មោះសិស្ស បង្កើតថ្នាក់រៀន និងពិនិត្យរបាយការណ៍។
   * **គ្រូបង្រៀន (Lecturers)៖** បង្កើតដោយ Admin លើ Web Admin និងផ្តល់គណនីឱ្យគ្រូចូលប្រើលើ Laptop (សម្រាប់បញ្ចាំង QR Projector) ឬទូរស័ព្ទ។
   * **សិស្ស (Students)៖** Admin បង្កើតម្តងមួយៗ ឬ Import ជាក្រុមធំពី Excel/CSV តាមជំនាញ និងឆ្នាំសិក្សា។ សិស្សប្រើតែ Mobile App សម្រាប់បើកកាមេរ៉ាស្កេនកត់វត្តមាន។

---

## ១. ទិដ្ឋភាពទូទៅនៃកម្មវិធី (App Overview)
* **ឈ្មោះគម្រោង៖** ScanIn Attendance System
* **បច្ចេកវិទ្យា (Tech Stack)៖**
  * **Frontend (Mobile)៖** Flutter (Dart) — `scan_in` (សម្រាប់សិស្សស្កេនកាមេរ៉ា និងគ្រូប្រើចល័ត)
  * **Web Portal (Laptop / Desktop)៖** Flutter for Web (Dart) — `scan_in_admin` (Admin Panel & Lecturer Classroom Projector View)
  * **Backend (API)៖** Laravel 12 (PHP) — `scan_in_backend` (RESTful API + Sanctum + Multi-role Guard)
  * **Database៖** MySQL (Database Name: `scan_in`, Port: 3306)
* **តួនាទីអ្នកប្រើប្រាស់ និងការបែងចែកសិទ្ធិដាច់ខាត (Roles & Strict Access Control)៖**
  * **Admin (អ្នកគ្រប់គ្រងសាលា)៖** មានសិទ្ធិផ្តាច់មុខក្នុងការបង្កើតគណនីគ្រូ, បង្កើតគណនីសិស្ស, Import សិស្សពី Excel/CSV, បង្កើតថ្នាក់រៀន (ឆ្នាំសិក្សា, ឆមាស, កូដ, ឈ្មោះ, បន្ទប់, ម៉ោង) និងចាត់តាំងគ្រូបង្រៀន, មើល Dashboard និងរបាយការណ៍សរុបទូទាំងសាកលវិទ្យាល័យ។ **(គ្រូ និងសិស្ស មិនអាចចូលជា Admin បានដាច់ខាត)**។
  * **គ្រូ (Lecturer - Laptop Web & Mobile)៖** ទទួលបានគណនីពីសាលា, ពិនិត្យតែថ្នាក់ដែលខ្លួនត្រូវបានចាត់តាំង, បើក Projector Fullscreen QR Code លើ Laptop ក្នុងថ្នាក់រៀន, តាមដានវត្តមានសិស្សស្កេនផ្ទាល់, កែប្រែ Status វត្តមានជាក់ស្តែង (មក, យឺត, អវត្តមាន, ច្បាប់)។ **(គ្មានសិទ្ធិបង្កើតគណនី ឬកែប្រែកាលវិភាគមេរបស់ Admin ឡើយ)**។
  * **សិស្ស (Student - Mobile App Only)៖** ទទួលបានគណនីពីសាលា (Email/Password), ចូល Mobile App, បើក Camera ទូរស័ព្ទស្កេន QR Code កត់វត្តមាន, មើលស្ថិតិ Dashboard (មក, យឺត, អវត្តមាន), តាមដានប្រវត្តិវត្តមានផ្ទាល់ខ្លួន, ប្តូរពាក្យសម្ងាត់ផ្ទាល់ខ្លួន។ **(មិនអនុញ្ញាតឱ្យចូលប្រើលើ Web ឡើយ)**។
   ចំណុចនេះខ្ញុំចង់ប្រើបែបនេះវិញយ៉ាងម៉េចដែរ ប្រើ CSV parser ពិតប្រាកដ ឬពិនិត្យ header ជំនួស
---

## ២. ដំណើរការ Code (Code Flow)

```
[Flutter UI (Web/Mobile)] ---> [Services] ---> [ApiConfig] ---> [Laravel API Routes] ---> [Controllers] ---> [MySQL DB]
```

### ក. Flow ចូលប្រើប្រាស់ និងផ្ទៀងផ្ទាត់តួនាទី (Role-Guarded Authentication Flow)
1. User វាយបញ្ចូល Email & Password (ផ្ទាំង Web Login ស្គាល់ Role ដោយស្វ័យប្រវត្តិ)
2. ហៅ `AuthService.login(email, password)` ផ្ញើទៅ `POST /api/login`
3. Laravel ផ្ទៀងផ្ទាត់ Hash Password -> បង្កើត **Sanctum Bearer Token**
4. ប្រព័ន្ធផ្ទៀងផ្ទាត់ Role Guard យ៉ាងតឹងរ៉ឹង៖ 
   * ប្រសិនបើគណនីជា `student` -> បដិសេធមិនឱ្យចូល Web ឡើយ (តម្រូវឱ្យប្រើ Mobile App សម្រាប់កាមេរ៉ាស្កេន)។
   * ប្រសិនបើជា `lecturer` -> បញ្ជូនទៅកាន់ Lecturer Classroom View លើ Laptop (ថ្នាក់បង្រៀនរបស់ខ្ញុំ និង Projector Fullscreen Mode)។
   * ប្រសិនបើជា `admin` -> បញ្ជូនទៅកាន់ Admin Dashboard ទូទាំងសាលា។

### ខ. Flow Admin បង្កើតគណនី និងកាលវិភាគ (Admin Provisioning Flow)
1. **បង្កើតគណនីគ្រូ៖** Admin ចូលផ្ទាំង `AdminLecturersScreen` -> `POST /api/lecturers` -> ប្រគល់ Email/Pass ជូនគ្រូ។
2. **បង្កើតគណនីសិស្ស៖** Admin ចូលផ្ទាំង `AdminStudentsScreen` -> `POST /api/students` (ឬ Import CSV) -> ប្រគល់ Email/Pass ជូនសិស្ស។
3. **បង្កើតថ្នាក់រៀន៖** Admin ចូលផ្ទាំង `AdminClassesScreen` -> `POST /api/classes` -> ចាត់តាំងគ្រូទទួលបន្ទុកបង្រៀន។

### គ. Flow គ្រូបញ្ចាំង QR លើ Laptop Projector (Lecturer Web Flow)
1. គ្រូបើក Laptop ក្នុងថ្នាក់រៀន ភ្ជាប់ខ្សែ HDMI ទៅកាន់ Projector
2. ចូល Lecturer Classroom Portal -> ចូលទៅកាន់ថ្នាក់បង្រៀនរបស់ខ្លួន -> ចុច "បញ្ចាំង QR (Project QR)"
3. ផ្ទាំង `_ProjectorDialog` បង្ហាញ QR Code ពេញលេញទំហំធំ កម្រិត Contrast ខ្ពស់ ជាមួយ Countdown ៤ នាទី
4. ហៅ `ClassService.toggleQr()` -> `POST /api/classes/{id}/toggle-qr` (Update `is_qr_active` = true & `qr_token`)
5. គ្រូអាចចុច Pause, Resume ឬ Regenerate Token បានគ្រប់ពេលវេលា។

### ឃ. Flow សិស្សស្កេនកត់វត្តមាន (Student Scan Flow)
1. សិស្សបើក Camera ក្នុងទូរស័ព្ទដៃស្កេន QR Code ដែលគ្រូបញ្ចាំងលើ Projector
2. ហៅ `AttendanceService.scanAttendance()` -> `POST /api/attendances/scan`
3. Laravel ពិនិត្យ Token និងស្ថានភាព QR -> បើត្រឹមត្រូវ បង្កើត Record ចូលតារាង `attendances` (Status: `present`)
4. ទិន្នន័យវត្តមានថ្មីលោតបង្ហាញលើ Laptop របស់គ្រូ និងផ្ទាំង Admin ភ្លាមៗ (Real-time Sync)។

---

## ៣. រចនាសម្ព័ន្ធ Database (Database Flow & Schema)

### Diagram ទំនាក់ទំនងតារាង (ER Diagram)
```
[ users ] (1) <---ចាត់តាំងបង្រៀន---> (N) [ classes ]
   |                                          |
  (1)                                        (1)
   |                                          |
  កត់វត្តមាន                                មានវត្តមាន
   |                                          |
  (N)                                        (N)
   +------------------> [ attendances ] <-----+
```

### តារាងសំខាន់ៗ (Tables)
1. **`users` (គណនីអ្នកប្រើប្រាស់ដែលបង្កើតដោយ Admin ឬ CLI)៖**
   * `id`, `name` (ឈ្មោះជាអក្សរខ្មែរ), `latin_name` (ឈ្មោះជាអក្សរឡាតាំង), `email`, `password`, `role` (`lecturer` / `student` / `admin`), `student_code`, `gender` (ភេទ), `date_of_birth` (ថ្ងៃខែឆ្នាំកំណើត), `staff_id`, `department`, `generation` (ជំនាន់), `intake_year` (ចាប់ពីឆ្នាំ), `year_level` (ឆ្នាំទី ១–៤), `status` (`active` / `graduated` / `inactive`), `phone`, `avatar_url`
2. **`classes` (ថ្នាក់រៀន/មុខវិជ្ជា)៖**
   * `id`, `user_id` (ID គ្រូបង្រៀនដែល Admin បានចាត់តាំង), `subject_name`, `subject_code`, `department` (ដេប៉ាតឺម៉ង់), `generation` (ជំនាន់), `year_level` (ឆ្នាំទី ១–៤), `room`, `day_of_week`, `time`, `semester`, `academic_year`, `student_count`, `completed_sessions`, `total_sessions` (Default 15 - កែសម្រួលបាន 1–60), `is_qr_active`, `qr_token`
3. **`attendances` (ទិន្នន័យកត់វត្តមាន)៖**
   * `id`, `class_id` (ID ថ្នាក់), `user_id` (ID សិស្ស), `status` (`present` / `late` / `absent`), `date`, `scanned_at`, `note`

---

## ៤. តារាងត្រួតពិនិត្យលម្អិត៖ ការភ្ជាប់ UI ទៅកាន់ Database (UI TO DB AUDIT CHECKLIST)

### ក. កម្មវិធីទូរស័ព្ទដៃ (Mobile App — `scan_in`)

| ល.រ | ផ្ទាំងអេក្រង់ / មុខងារ (UI Component) | ទីតាំង File | ស្ថានភាព UI to DB | ការពិពណ៌នា និងស្ថានភាពបច្ចុប្បន្ន |
|:---:|---|---|:---:|---|
| 1 | **Login & ផ្ទៀងផ្ទាត់ Role** | `lib/screens/login_screen.dart` | ✅ **រួចរាល់** | ភ្ជាប់ `POST /api/login`, ទទួល Sanctum Bearer Token និងទិន្នន័យ User ផ្ទាល់ពី DB |
| 2 | **កំណត់ Server IP Dialog** | `lib/screens/login_screen.dart` | ✅ **រួចរាល់** | ប្តូរ IP ម៉ាស៊ីន Server (Laravel) ផ្ទាល់ទៅកាន់ `ApiConfig` |
| 3 | **ទំព័រដើមសិស្ស (Dashboard)** | `lib/screens/student/student_dashboard_screen.dart` | ✅ **រួចរាល់** | គណនាស្ថិតិវត្តមានជាក់ស្តែង (មក, យឺត, អវត្តមាន) និងកាលវិភាគថ្នាក់រៀនពី DB |
| 4 | **កាមេរ៉ាស្កេន QR កត់វត្តមាន** | `lib/screens/student/student_home_screen.dart` | ✅ **រួចរាល់** | ស្កេនកាមេរ៉ា ឬបញ្ចូល Token ផ្ញើទៅ `POST /api/attendances/scan` កត់ចូល DB |
| 5 | **ប្រវត្តិវត្តមានសិស្ស (History)** | `lib/screens/student/student_history_screen.dart` | ✅ **រួចរាល់** | ទាញយកប្រវត្តិវត្តមានផ្ទាល់ខ្លួនតាម `GET /api/student/attendances` ពី DB |
| 6 | **សិស្សប្តូរពាក្យសម្ងាត់** | `lib/screens/student/student_profile_screen.dart` | ✅ **រួចរាល់** | ប្តូរ Password តាម `POST /api/user/change-password` រក្សាទុកចូល MySQL DB |
| 7 | **សិស្ស Upload Avatar & Edit Info** | `lib/screens/student/student_profile_screen.dart` | ⏳ **នៅ** | បច្ចុប្បន្នបង្ហាញត្រឹម SnackBar មិនទាន់មាន API Upload រូបភាព និង Update Profile |
| 8 | **ទំព័រដើមគ្រូ & ថ្នាក់បង្រៀន** | `lib/screens/lecturer/lecturer_dashboard_screen.dart` | ✅ **រួចរាល់** | ទាញយកថ្នាក់ដែលខ្លួនទទួលបន្ទុកបង្រៀនតាម `GET /api/classes` ពី DB |
| 9 | **គ្រូបើក/បិទ Dynamic QR** | `lib/screens/lecturer/lecturer_home_screen.dart` | ✅ **រួចរាល់** | បើក/បិទ និង Update Token តាម `POST /api/classes/{id}/toggle-qr` ចូល DB |
| 10 | **គ្រូបញ្ចាំង QR លើទូរស័ព្ទ** | `lib/screens/lecturer/show_qr_screen.dart` | ✅ **រួចរាល់** | Fullscreen QR, Pause/Resume ធ្វើសមកាលកម្មទៅ `POST /api/classes/{id}/toggle-qr` |
| 11 | **បញ្ជីសិស្សស្កេន Live ក្នុង ShowQR** | `lib/screens/lecturer/show_qr_screen.dart` | ✅ **រួចរាល់** | ទាញយកទិន្នន័យនិស្សិតស្កេនពិតៗពី DB (`GET /api/classes/{id}/students`) Auto-refresh រៀងរាល់ ៥ វិនាទី + Pull-to-Refresh |
| 12 | **បញ្ជីវត្តមានតាមថ្នាក់របស់គ្រូ** | `lib/screens/lecturer/attendance_list_screen.dart` | ✅ **រួចរាល់** | ទាញយកវត្តមានតាមថ្នាក់នីមួយៗតាម `GET /api/classes/{id}/attendances` ពី DB (គ្មាន MockData fallback) |
| 13 | **គ្រូកែប្រែវត្តមាន & Note លើទូរស័ព្ទ**| `lib/screens/lecturer/attendance_list_screen.dart` | ✅ **រួចរាល់** | កែប្រែ Status (មក, យឺត, អវត្តមាន) ព្រមទាំង Note តាម `PUT /api/attendances/{id}` ចូល DB (គាំទ្រ Dark Mode ពេញលេញ) |
| 14 | **ព័ត៌មានលម្អិតថ្នាក់ (សិស្សក្នុងថ្នាក់)** | `lib/screens/lecturer/class_detail_screen.dart` | ✅ **រួចរាល់** | ព័ត៌មានថ្នាក់ & បញ្ជីឈ្មោះនិស្សិតពិតតាម ដេប៉ាតឺម៉ង់ + ឆ្នាំទី + ជំនាន់ ពី `GET /api/classes/{id}/students` |
| 15 | **គ្រូប្តូរពាក្យសម្ងាត់** | `lib/screens/lecturer/lecturer_profile_screen.dart` | ✅ **រួចរាល់** | ប្តូរ Password តាម `POST /api/user/change-password` រក្សាទុកចូល MySQL DB |
| 16 | **គ្រូ Upload Avatar & Edit Info** | `lib/screens/lecturer/lecturer_profile_screen.dart` | ⏳ **នៅ** | មិនទាន់មាន API Upload រូបភាព Avatar និងកែប្រែព័ត៌មាន Profile ផ្ទាល់ខ្លួន |

---

### ខ. ផ្ទាំងគ្រប់គ្រងលើកុំព្យូទ័រ (Web Portal — `scan_in_admin`)

| ល.រ | ផ្ទាំងអេក្រង់ / មុខងារ (UI Component) | ទីតាំង File | ស្ថានភាព UI to DB | ការពិពណ៌នា និងស្ថានភាពបច្ចុប្បន្ន |
|:---:|---|---|:---:|---|
| 17 | **Smart Web Login & Role Routing** | `lib/screens/admin_login_screen.dart` | ✅ **រួចរាល់** | ផ្ញើទៅ `POST /api/login`, ស្គាល់ Role ស្វ័យប្រវត្តិតាម DB (Admin vs គ្រូ), បិទសិស្សមិនឱ្យចូល Web |
| 18 | **Admin Dashboard ស្ថិតិទូទាំងសាលា** | `lib/screens/admin_dashboard_screen.dart` | ✅ **រួចរាល់** | គណនាចំនួនថ្នាក់រៀន, QR កំពុងបើក, និងចំនួនវត្តមានសរុបចេញពី MySQL DB |
| 19 | **Admin មើលបញ្ជីគ្រូបង្រៀន** | `lib/screens/admin_lecturers_screen.dart` | ✅ **រួចរាល់** | ទាញយកបញ្ជីសាស្រ្តាចារ្យទាំងអស់តាម `GET /api/lecturers` ពី DB |
| 20 | **Admin បង្កើតគណនីគ្រូថ្មី** | `lib/screens/admin_lecturers_screen.dart` | ✅ **រួចរាល់** | បង្កើតគ្រូ (ឈ្មោះ, Email, Pass, StaffId, Dept, Phone) តាម `POST /api/lecturers` ចូល DB |
| 21 | **Admin កែប្រែ / លុបគណនីគ្រូ** | `lib/screens/admin_lecturers_screen.dart` | ✅ **រួចរាល់** | មានប៊ូតុង Actions (Edit & Delete) កែសម្រួលព័ត៌មាន/Password និងលុបគណនីគ្រូតាម `PUT/DELETE /api/lecturers/{id}` ចូល DB |
| 22 | **Admin មើលបញ្ជីសិស្សទាំងអស់** | `lib/screens/admin_students_screen.dart` | ✅ **រួចរាល់** | ទាញយកបញ្ជីសិស្សទូទាំងសាលាតាម `GET /api/students` ពី DB |
| 23 | **Admin បង្កើតគណនីសិស្សថ្មី** | `lib/screens/admin_students_screen.dart` | ✅ **រួចរាល់** | បង្កើតសិស្ស (ឈ្មោះ, StudentCode, ភេទ, ថ្ងៃកំណើត, Email, Pass, Dept, Phone) តាម `POST /api/students` ចូល DB |
| 24 | **Admin កែប្រែ / លុបគណនីសិស្ស** | `lib/screens/admin_students_screen.dart` | ✅ **រួចរាល់** | មានប៊ូតុង Actions (Edit & Delete) កែសម្រួលព័ត៌មាន/Password និងលុបគណនីសិស្សព្រមទាំង Attendance ពាក់ព័ន្ធតាម `PUT/DELETE /api/students/{id}` ចូល DB |
| 24.1 | **Admin Import សិស្សពី Excel/CSV** | `lib/screens/admin_students_screen.dart` | ✅ **រួចរាល់** | Import សិស្សជាក្រុមពី Excel/CSV, បង្កើតគណនីស្វ័យប្រវត្តិតាមជួរ (ឈ្មោះ, អត្តលេខ, ភេទ, ថ្ងៃកំណើត, អ៊ីមែល, ដេប៉ាតឺម៉ង់, ទូរស័ព្ទ) តាម `POST /api/students/import` ចូល DB |
| 25 | **មើលបញ្ជីថ្នាក់រៀន & ចាត់តាំងគ្រូ** | `lib/screens/admin_classes_screen.dart` | ✅ **រួចរាល់** | ទាញយកថ្នាក់រៀនទាំងអស់ (Admin) ឬថ្នាក់ផ្ទាល់ខ្លួន (គ្រូ) តាម `GET /api/classes` ពី DB |
| 25.1 | **មើលបញ្ជីសិស្សក្នុងថ្នាក់ (Class Roster)** | `lib/screens/admin_classes_screen.dart` | ✅ **រួចរាល់** | ប៊ូតុង `[បញ្ជីសិស្ស]` បើក Popup បង្ហាញបញ្ជីឈ្មោះសិស្សពិតក្នុងថ្នាក់តាម DB (ឈ្មោះខ្មែរ/ឡាតាំង, អត្តលេខ, ភេទ, ទូរស័ព្ទ, វត្តមានថ្ងៃនេះ) តាម `GET /api/classes/{id}/students` |
| 26 | **Admin បង្កើតថ្នាក់រៀនកណ្តាល** | `lib/screens/admin_classes_screen.dart` | ✅ **រួចរាល់** | បង្កើតថ្នាក់ (ឆ្នាំ, ឆមាស, កូដ, ឈ្មោះ, បន្ទប់, ម៉ោង, គ្រូ) តាម `POST /api/classes` ចូល DB |
| 27 | **Admin កែប្រែ / លុបថ្នាក់រៀន** | `lib/screens/admin_classes_screen.dart` | ✅ **រួចរាល់** | មានប៊ូតុង Actions (Edit & Delete) កែប្រែព័ត៌មាន និងលុបថ្នាក់រៀនព្រមទាំង Attendance ពាក់ព័ន្ធតាម `PUT/DELETE /api/classes/{id}` ចូល DB |
| 28 | **គ្រូបញ្ចាំង Dynamic QR Projector** | `lib/screens/admin_classes_screen.dart` | ✅ **រួចរាល់** | Projector Fullscreen លើ Laptop, Toggle QR តាម `POST /api/classes/{id}/toggle-qr` ចូល DB |
| 29 | **ពិនិត្យវត្តមានសិស្សតាមថ្នាក់លើ Web**| `lib/screens/admin_attendances_screen.dart` | ✅ **រួចរាល់** | ទាញយកវត្តមានតាមថ្នាក់ដែលជ្រើសរើសតាម `GET /api/classes/{id}/attendances` ពី DB |
| 30 | **កែប្រែវត្តមាន & Note លើ Web** | `lib/screens/admin_attendances_screen.dart` | ✅ **រួចរាល់** | ប៊ូតុង "កែប្រែ" ប្តូរ Status និង Quick Note តាម `PUT /api/attendances/{id}` ចូល DB ភ្លាមៗ |
| 31 | **ស្ថិតិនិស្សិត & ប្រវត្តិតាមឆ្នាំ (Admin Only)** | `lib/screens/admin_student_stats_screen.dart` | ✅ **រួចរាល់** | ម៉ឺនុយរងក្រោម `របាយការណ៍` សរុបនិស្សិតអចិន្ត្រៃយ៍ (Active/Graduated/Inactive) តាម ឆ្នាំចូលរៀន × គ្រប់ជំនាញ + CSV Copy |
| 32 | **ប្តូរស្ថានភាព & ដំឡើងឆ្នាំសិក្សាជាក្រុម** | `lib/screens/admin_students_screen.dart` | ✅ **រួចរាល់** | ប្តូរស្ថានភាព (`Active/Graduated/Inactive`) តាម `POST /api/students/bulk-status` និងដំឡើងឆ្នាំតាម `POST /api/students/promote` |
| 33 | **Export របាយការណ៍វត្តមាន (CSV / Excel)**| `lib/screens/admin_attendances_screen.dart` | ✅ **រួចរាល់** | ប៊ូតុង `[Export CSV]` ចម្លងទិន្នន័យវត្តមានសិស្សតាមថ្នាក់ជា CSV សម្រាប់យកទៅ Paste ចូល Excel ភ្លាមៗ |
| 34 | **បញ្ជីឈ្មោះសិស្សក្នុងថ្នាក់ (Enrolled Students Roster)** | `lib/screens/admin_classes_screen.dart` | ✅ **រួចរាល់** | ប៊ូតុង `[បញ្ជីសិស្ស]` បង្ហាញ Modal បញ្ជីឈ្មោះសិស្សតាមថ្នាក់ពិតពី DB (`GET /api/classes/{id}/students`) ជាមួយ Badge វត្តមានថ្ងៃនេះ |
| 35 | **Batch Import សិស្ស & Smart Normalization** | `lib/screens/admin_students_screen.dart` | ✅ **រួចរាល់** | ផ្ទាំង Import សិស្សមានជម្រើសរួម (ជំនាន់, ឆ្នាំចូលរៀន, ឆ្នាំទី, ដេប៉ាតឺម៉ង់), Auto-map ឈ្មោះជំនាញពី English ទៅខ្មែរ, និង Scrollbar អូស Mouse សកម្មភាព |
| 36 | **ដេប៉ាតឺម៉ង់កំណត់ដោយដៃ & Sync គ្រប់អេក្រង់** | `lib/services/class_service.dart` | ✅ **រួចរាល់** | ប្តូរទៅជា `EditableComboField` លើផ្ទាំងបង្កើត/កែប្រែគ្រូ សិស្ស និងថ្នាក់រៀន, បង្កើត API `GET /api/departments` Sync រាល់ជំនាញ/ដេប៉ាតឺម៉ង់ថ្មីៗទូទាំងប្រព័ន្ធ |
| 37 | **Artisan Command បង្កើត Master Admin** | `app/Console/Commands/MakeAdmin.php` | ✅ **រួចរាល់** | ពាក្យបញ្ជា CLI `php artisan make:admin` បង្កើត Admin មេដំបូងដោយសុវត្ថិភាព ផ្ទៀងផ្ទាត់ Email និងលាក់ Password |

---

## ៥. សេចក្តីសង្ខេបកិច្ចការដែលបានសម្រេចថ្ងៃនេះ (Completed Today — 13/11/2026)

1. **បង្កើត Artisan CLI Command `php artisan make:admin` សម្រាប់បង្កើត Master Admin៖**
   * បង្កើត [MakeAdmin.php](file:///d:/Flutter_Project/Scan_In_App/scan_in_backend/app/Console/Commands/MakeAdmin.php) ជាភាសាអង់គ្លេសស្អាត មិនបែក Font លើ Windows PowerShell/CMD។
   * មុខងារ៖ សួរឈ្មោះ, ពិនិត្យ Email Format & Duplicate, សួរ Password ដោយលាក់ផ្កាយ (`secret()`), ផ្ទៀងផ្ទាត់ Confirm Password, និងបង្កើតចូល MySQL តួនាទី `role = 'admin'`។
   * **លទ្ធផលជាក់ស្តែង៖** ម្ចាស់គម្រោងបាន Run បង្កើតគណនី Master Admin ដំបូងដោយជោគជ័យ ១០០%៖ `masteradmin@scanin.edu.kh` (ឈ្មោះ `NEANG BUNTHANDY`, Role: `admin`)។

2. **ដេប៉ាតឺម៉ង់ / មហាវិទ្យាល័យ វាយបន្ថែមដោយដៃ និង Sync ស្វ័យប្រវត្តិគ្រប់អេក្រង់ (Global Department Sync)៖**
   * បង្កើត Endpoint `GET /api/departments` ក្នុង [api.php](file:///d:/Flutter_Project/Scan_In_App/scan_in_backend/routes/api.php) រួមបញ្ចូលគ្នាឆ្លាតវៃរវាង Preset ដេប៉ាតឺម៉ង់ + ជំនាញទាំងអស់ដែលមានក្នុង DB (`users` & `classes`)។
   * បំពាក់ `EditableComboField` លើផ្ទាំង **បង្កើត/កែប្រែគ្រូបង្រៀន (`admin_lecturers_screen.dart`)**, **បង្កើត/កែប្រែសិស្ស (`admin_students_screen.dart`)**, និង **បង្កើត/កែប្រែថ្នាក់រៀន (`admin_classes_screen.dart`)**។
   * ពេល Admin វាយឈ្មោះដេប៉ាតឺម៉ង់ថ្មីណាមួយ ប្រព័ន្ធនឹងហៅ `ClassService.registerCustomDepartment()` រួច Sync លេចចេញក្នុង Dropdown Filter និងផ្ទាំងផ្សេងៗទូទាំងប្រព័ន្ធភ្លាមៗ។

3. **បំពាក់ Mouse Drag Scrolling & Visible Scrollbars លើតារាង DataTables ទាំងអស់៖**
   * ដាក់ `ScrollConfiguration` គាំទ្រ `PointerDeviceKind.mouse` និង `Scrollbar` អមដោយ `_horizontalScrollCtrl` លើតារាងសិស្ស, ថ្នាក់រៀន, និងគ្រូបង្រៀន។
   * អ្នកប្រើប្រាស់អាចយក Mouse ចុចអូសទៅស្តាំ (Horizontal Drag) មើលជួរឈរ "សកម្មភាព (Actions)" បានយ៉ាងរលូនលើ Desktop Web។

4. **ស្តារ និងជួសជុល Package Vendor ក្រោយដាច់ភ្លើង (NTFS Healing & Recovery)៖**
   * ជួសជុលឯកសារខូច 0-byte ក្នុង `vendor/nikic/php-parser` ពី Mirror Backup ស្អាតស្អំ ១០០%។
   * ធ្វើតេស្ត `php artisan test` ឆ្លងកាត់ទាំង **18 passed (141 assertions)**, `flutter analyze` ទាំង Mobile និង Web **No issues found**។

5. **បញ្ជីឈ្មោះសិស្សក្នុងថ្នាក់ (Class Roster) & Export វត្តមានជា CSV៖**
   * បន្ថែមប៊ូតុង `[បញ្ជីសិស្ស]` ក្នុងតារាងថ្នាក់រៀន `admin_classes_screen.dart` បង្ហាញ Popup ឈ្មោះខ្មែរ/ឡាតាំង, អត្តលេខ, ភេទ, លេខទូរស័ព្ទ និងវត្តមានថ្ងៃនេះ។
   * បន្ថែមប៊ូតុង `[Export CSV]` លើ `admin_attendances_screen.dart` សម្រាប់ទាញយកវត្តមានទៅបើកក្នុង Microsoft Excel ភ្លាមៗ។

---

## ៦. ស្ថានភាពត្រួតពិនិត្យសុខភាពកូដ & ឯកសារ (Code & Folder Health Check — 13/11/2026)

* **Git Status:** Clean working tree, On branch `main`.
* **Stray/Unused Files:** គ្មានឯកសារខូច, គ្មានឯកសារលើស, គ្មាន temp file ឥតប្រយោជន៍ឡើយ (បានជួសជុល 0-byte vendor files រួចរាល់)។
* **Laravel API Backend (`scan_in_backend`):** `php artisan test` ទទួលបាន **19 passed (145 assertions)** ដំណើរការលឿនរលូន (Duration: 1.82s)។
* **Web Admin Portal (`scan_in_admin`):** `flutter analyze` ទទួលបាន **No issues found!** (0 errors, 0 warnings)។
* **Mobile App (`scan_in`):** `flutter analyze` ទទួលបាន **No issues found!** (0 errors, 0 warnings)។
* **Database (MySQL):** Database `scan_in` ដំណើរការល្អធម្មតាលើ port 3306។
* **Offline Mirror Backup:** ធ្វើសមកាលកម្មទៅកាន់ `C:\Users\Jitsu Window\Scan_In_App_Backup\` រួចរាល់។

---

## 🚀 ៧. ផែនការងារជាក់លាក់ និងស្ថានភាពបច្ចុប្បន្ន (Production Roadmap)

### ✅ ជំហានទី ១ (Step 1 — រួចរាល់) ៖ បង្កើត Artisan CLI Command `php artisan make:admin`
* បានបង្កើតគណនី Master Admin ដំបូងដោយជោគជ័យ៖ `masteradmin@scanin.edu.kh` (`NEANG BUNTHANDY`)។

### ✅ ជំហានទី ២ (Step 2 — រួចរាល់) ៖ បន្ថែមប៊ូតុង "ប្តូរ Password" លើ Web Admin និងកែសម្រួល AuthApiTest
1. **Web Admin — បន្ថែមប៊ូតុង និង Dialog "ប្តូរពាក្យសម្ងាត់ (Change Password)"៖**
   * **ទីតាំង៖** ក្នុង [admin_scaffold.dart](file:///d:/Flutter_Project/Scan_In_App/scan_in_admin/lib/screens/admin_scaffold.dart) នៅជាប់ប៊ូតុង Sign Out (ទាំង Compact និង Expanded Sidebar) ជាមួយ icon សោពណ៌ទឹកក្រូច `Icons.key_rounded`។
   * **ផ្ទាំង Dialog៖** បញ្ចូល Current Password, New Password, Confirm New Password ជាមួយប៊ូតុង Show/Hide Password និង Form Validation ត្រឹមត្រូវ។
   * **API Connection៖** ហៅ `AuthService.changePassword(currentPassword, newPassword)` ភ្ជាប់ទៅ `POST /api/user/change-password`។
2. **Backend — កែសម្រួល [AuthApiTest.php](file:///d:/Flutter_Project/Scan_In_App/scan_in_backend/tests/Feature/AuthApiTest.php) ឱ្យប្រើ Factory & Transactions៖**
   * បន្ថែម `use DatabaseTransactions;` និងប្តូរពី email រឹង `dara@scanin.app` / `student@scanin.app` មកជា Dynamic User ក្នុង Transactions។
   * បន្ថែមតេស្ត `test_user_can_change_password_successfully` ផ្ទៀងផ្ទាត់ការប្តូរពាក្យសម្ងាត់តាម API។
   * លទ្ធផលតេស្ត៖ **19 passed (145 assertions)** ឆ្លងកាត់ ១០០% ដោយមិនពឹងផ្អែកលើ Demo Seeder ទៀតឡើយ។

---

### ✅ ជំហានទី ៣ (Step 3 — រួចរាល់) ៖ សម្អាត Demo Seed Data ទៅកាន់ Clean Production DB
1. **ដកទិន្នន័យគំរូចេញពី Seeder៖** ដកគណនីគ្រូ `dara@scanin.app`, សិស្ស `student@scanin.app`, និង Admin `admin@scanin.app` ព្រមទាំងថ្នាក់រៀនគំរូចេញពី [DatabaseSeeder.php](file:///d:/Flutter_Project/Scan_In_App/scan_in_backend/database/seeders/DatabaseSeeder.php)។
2. **សម្អាត Demo Records ក្នុង MySQL៖** សម្អាត Record ចាស់ៗចេញពីតារាង `users`, `classes`, និង `attendances` ក្នុង MySQL រួចរាល់។
   * ស្ថានភាព Database បច្ចុប្បន្ន៖ មានតែគណនី Master Admin ពិតប្រាកដ **`masteradmin@scanin.edu.kh` (`NEANG BUNTHANDY`)** មួយគត់។ គ្មានទិន្នន័យ Demo ឡើយ។
   * `php artisan test` ដំណើរការ **19 passed (145 assertions)** ពេញលេញ ១០០%។

---

### 🏛️ ច្បាប់ស្ថាបត្យកម្មកាលវិភាគ និងវត្តមាន (Session & Attendance Architecture Rules)
1. **គោលការណ៍ ១ QR = ១ Session គត់ (Strictly Single-Session Attendance)៖**
   * គ្មានការច្របាច់ ២ Session ចូលគ្នាក្នុង QR តែមួយឡើយ (ទោះបីជាមុខវិជ្ជាខ្លះរៀន ២ Session ក្នុងថ្ងៃតែមួយក៏ដោយ)។
   * **រចនាសម្ព័ន្ធ Session សាកលវិទ្យាល័យ (៦ Sessions ស្តង់ដារ មួយ Session = ៩០ នាទី)៖**
     * 🌅 **Session 1 ៖** `07:00 - 08:30` (Default ម៉ោងពេលបង្កើតថ្នាក់)
     * 🌅 **Session 2 ៖** `08:50 - 10:20` *(សម្រាក ២០ នាទី ពី Session 1)*
     * 🌅 **Session 3 ៖** `10:30 - 12:00` *(សម្រាក ១០ នាទី ពី Session 2)*
     * ☕ *(ចន្លោះម៉ោង ១២:០០ - ១៣:០០ សម្រាកបាយថ្ងៃត្រង់)*
     * ☀️ **Session 4 ៖** `13:00 - 14:30` *(ម៉ោង ១:០០ ដល់ ២:៣០)*
     * ☀️ **Session 5 ៖** `14:40 - 16:10` *(ម៉ោង ២:៤០ ដល់ ៤:១០ - សម្រាក ១០ នាទី)*
     * ☀️ **Session 6 ៖** `16:20 - 17:50` *(ម៉ោង ៤:២០ ដល់ ៥:៥០ - សម្រាក ១០ នាទី)*
2. **ត្រៀមសម្រាប់ Face ID & GPS Geofencing (ទីតាំងក្នុងបរិវេណសាលា)៖**
   * នៅពេលបន្ថែម **Face ID** និង **GPS Detection** សិស្សត្រូវតែស្ថិតនៅក្នុងបន្ទប់រៀនជាក់ស្តែង និងស្កេនផ្ទៃមុខពិតប្រាកដក្នុង Session នីមួយៗ ទើបប្រព័ន្ធអនុញ្ញាតឱ្យកត់វត្តមានបាន (ការពារដាច់ខាតការស្កេនជំនួស ឬការរត់ចេញពីថ្នាក់)។

---

### ✅ ជំហានទី ៤ (Step 4 — រួចរាល់ ១០០%) ៖ ប្រព័ន្ធកាលវិភាគ Single Session, Sub-Admin និងការដោះស្រាយ Bug ចំនួនថ្នាក់គ្រូ
1. **ចំណុច ៤.១ (Single Session Timetable & Quick Chips) ៖**
   - បានកែសម្រួលផ្ទាំងបង្កើត និងកែសម្រួលថ្នាក់រៀនលើ Web Admin ដោយដាក់ Default `07:00 - 08:30`។
   - បានបន្ថែមប៊ូតុង Quick Single Session Chips ចំនួន ៦ ស្តង់ដារ (S1 ដល់ S6 មួយ session = ៩០ នាទី) ស្របតាមច្បាប់ ១ QR = ១ Session។
2. **ចំណុច ៤.២ (Sub-Admin Management - ការិយាល័យសិក្សា) ៖**
   - **Backend API (`/api/sub-admins`) ៖** បង្កើត CRUD API សម្រាប់គ្រប់គ្រង Sub-Admin ដោយការពារសិទ្ធិផ្តាច់មុខជូនតែ Master Admin (`isMasterAdmin()`)។ Sub-Admin មិនអាចមើលឃើញ ឬលុប Master Admin បានឡើយ។
   - **Web Admin UI ៖** បង្កើតអេក្រង់ `AdminSubAdminsScreen`, Service `SubAdminService`, ចុះឈ្មោះ Route `/sub-admins` និងបន្ថែមម៉ឺនុយ «គ្រប់គ្រង Sub-Admin» លើ Sidebar ដែលបង្ហាញជូនតែ Master Admin។
   - បានបំពាក់ Role Badges យ៉ាងស្រស់ស្អាត៖ Master Admin (ខៀវចាស់), Sub-Admin (បៃតង Mint), Lecturer (ផ្ទៃមេឃ Sky)។
3. **ចំណុច ៤.៣ (ដោះស្រាយ Bug ចំនួនថ្នាក់គ្រូបង្រៀនបង្ហាញ ០ ថ្នាក់) ៖**
   - **មូលហេតុបច្ចេកទេស៖** ក្នុង `scan_in_backend/routes/api.php` ត្រង់ route `/api/lecturers` កូដ Eloquent query ចាស់បានហៅ `->withCount('classes')` នៅពីមុខ `->select(...)` ធ្វើឱ្យ Laravel កាត់ចោល subquery នៃ `classes_count` ចេញពី JSON។
   - **ដំណោះស្រាយ៖** បានប្តូរទីតាំងដាក់ `->select(...)` មកនៅពីមុខ `->withCount('classes')` វិញ និងបានកំណត់ Auto Cache Invalidation (`_cachedLecturers = null;`) រាល់ពេល Admin បង្កើត, កែប្រែ ឬលុបថ្នាក់រៀន។ ចំនួនថ្នាក់គ្រូ `អូន វឌ្ឍនៈ` បានបង្ហាញ «១ ថ្នាក់» ត្រឹមត្រូវ ១០០%។

---

### 🛡️ ជំហានទី ៥ (Step 5 — រួចរាល់ ១០០%) ៖ ផ្លាស់ប្តូរទៅកាន់ Drive C: (SSD) & បន្ថែមកាលបរិច្ឆេទ Session (class_date)
1. **ការសង្គ្រោះ និងផ្លាស់ប្តូរ Workspace ទៅកាន់ NVMe SSD (Drive C:) ៖**
   - ពិនិត្យឃើញ Hard Disk ចាស់ Drive D: (Seagate ST3500410SV) មានបញ្ហាផ្នែករឹង Bad Sectors ធ្ងន់ធ្ងរ (Windows Event ID: 154 - Disk Hardware Error & BSOD)។
   - បានផ្លាស់ប្តូរ Workspace ទាំងស្រុងមកកាន់ `C:\Flutter_Project\Scan_In_App` លើ **NVMe SSD (XPG SPECTRIX S20G)** ដែលមានសុខភាពល្អ ១០០% និងល្បឿនលឿនជាងមុន ៥ ទៅ ១០ ដង។
   - `flutter analyze` លើ Mobile និង Web Admin ដើរលឿនត្រឹមតែ **២.០ វិនាទី** (0 issues) ហើយ Backend Unit & Feature Tests ដើរត្រឹមតែ **២.៨ វិនាទី**។
2. **បន្ថែម «កាលបរិច្ឆេទ Session (class_date)» ក្នុងប្រព័ន្ធ ដូចទម្រង់ NUBB ៖**
   - **Database Migration ៖** បន្ថែម Column `class_date` (nullable `date` with index) លើ table `classes`។
   - **Backend API & Eloquent ៖** Update `ClassModel.php` និង `ClassController.php` ឱ្យទទួល `class_date`, serialise ទៅ JSON, និងគាំទ្រ Date Filtering (`?date=YYYY-MM-DD`)។
   - **Web Admin UI ៖** បន្ថែម Date Picker ក្នុង Dialog បង្កើត និងកែប្រែថ្នាក់រៀន (រើសថ្ងៃណា ប្រព័ន្ធស្គាល់ថ្ងៃច័ន្ទ ដល់ អាទិត្យ ស្វ័យប្រវត្តិ) និងរៀបចំជួរឈរ «កាលវិភាគ» ក្នុងតារាងឱ្យបង្ហាញទាំងកាលបរិច្ឆេទ (ឧ. `2026-11-14 (សៅរ៍)`) និងម៉ោង Session (`07:00 - 08:30`)។
   - **តេស្ត Backend ៖** បន្ថែម Test `test_admin_can_create_class_with_class_date_and_filter_by_date` ឆ្លងកាត់ជោគជ័យ ១០០% (**26 passed, 175 assertions**).
   - **Git & Backup ៖** Commit `73b45c5` រួចរាល់លើ GitHub និង Robocopy Mirror ទៅកាន់ `C:\Users\Jitsu Window\Scan_In_App_Backup\`។

---

## 📅 ផែនការការងារជាក់ស្តែងសម្រាប់ថ្ងៃនេះ (Today's Execution Plan — ១៨ វិច្ឆិកា ២០២៦)

### 🔍 ចំណុចអធិការកិច្ច Mock Data & មុខងារដែលបានរកឃើញ (Audit Findings)៖
1. **Mock Data លើ Web Lecturer & Mobile Dashboard ៖**
   - ជាប់កាលបរិច្ឆេទរឹង `ថ្ងៃព្រហស្បតិ៍ 15 តុលា 2026` ក្នុង `lecturer_dashboard_screen.dart` (បន្ទាត់ 94) និង `student_dashboard_screen.dart` (បន្ទាត់ 79)។
   - ជាប់ Mock Percentage `94%` ក្នុង `lecturer_dashboard_screen.dart` (បន្ទាត់ 263) និង `សកម្មភាព ៩៤%` ក្នុង `lecturer_profile_screen.dart` (បន្ទាត់ 546)។
2. **Mock Data លើ Student Profile Screen (`student_profile_screen.dart`) ៖**
   - ជាប់ទិន្នន័យរឹងក្នុងកាត «ស្ថិតិវត្តមានសរុប (ឆមាសនេះ)»៖ `18 វត្តមាន`, `2 យឺត`, `1 អវត្តមាន`, និង `អត្រាវត្តមាន ៩០%` (បន្ទាត់ 533-568) បើទោះបីសិស្សទើបបង្កើតថ្មីមិនទាន់បានស្កេនម្តងណាក៏ដោយ។
3. **Mock Data ក្នុង Form បិទភ្ជាប់ (Paste) របស់ Web Admin Students (`admin_students_screen.dart`) ៖**
   - ប៊ូតុង «ចម្លងទម្រង់គំរូពេញលេញ» បង្កប់ឈ្មោះក្លែងក្លាយ `STU101 សុខ ចាន់ដារ៉ា`, `STU102 គង់ ស្រីមុំ`, `STU103 ហេង វិបុល` ចូលទៅក្នុងប្រអប់ Paste ធ្វើឱ្យច្រឡំថាជាទិន្នន័យពិត -> **ត្រូវលុបឈ្មោះក្លែងក្លាយចោលជាបន្ទាន់** ដោយទុកតែទម្រង់ Header ស្អាត ឬទម្រង់ពិតប្រាកដ។
4. **ស្ថានភាពមុខងារ Add Profile Avatar (Camera / Gallery) ៖**
   - បច្ចុប្បន្នជា UI Placeholder បណ្តោះអាសន្ន (បង្ហាញ SnackBar) ពីព្រោះមិនទាន់បានដំឡើង package `image_picker` លើ Mobile App និងមិនទាន់បានសរសេរ API Endpoint `POST /api/profile/avatar` លើ Backend។
5. **ទិន្នន័យនិស្សិតពិតប្រាកដ (Real Students Data - IT Gen 20) ៖**
   - ទទួលបានតារាងនិស្សិតពិតប្រាកដចំនួន ២១ នាក់ពីសាកលវិទ្យាល័យ និងសម្រេចយក ៥ នាក់ដំបូងសម្រាប់ Pilot Testing៖
     1. `IT20-001` - **កាទិក វីរ៉ាច** (KATHIK VIRAJ) - ប្រុស - 06/06/2005
     2. `IT20-002` - **គឹម សីហា** (KIM SEYHA) - ប្រុស - 20/03/2005
     3. `IT20-003` - **ឃន រតនសត្យា** (KHORN RATHANAKSATYA) - ប្រុស - 27/08/2005
     4. `IT20-004` - **ឆែម ម៉ីហា** (CHHEM MEYHA) - ស្រី - 11/06/2006
     5. `IT20-005` - **ដាំ អាយុសុធី** (DAM ARYUSOTHY) - ស្រី - 24/10/2005

---

### 🚀 វឌ្ឍនភាពការងារជាក់ស្តែងថ្ងៃនេះ (Today's Execution Progress — ១៨ វិច្ឆិកា ២០២៦)៖

1. **កិច្ចការទី ១ (Task 1 — រួចរាល់ ១០០% ✅) ៖ បោសសម្អាត Mock Data និង Fake Paste Data**
   - លុបគំរូឈ្មោះសិស្សក្លែងក្លាយ (`STU101... STU103`) ចេញពី `admin_students_screen.dart`។
   - បង្កើត `AppDateTime` Helper លើ Mobile និង Web Admin ជំនួសថ្ងៃទីរឹង `15 តុលា 2026` ដោយ Real-time Date `DateTime.now()` គ្រប់ទីកន្លែង។
   - គណនាស្ថិតិវត្តមានលើ Profile សិស្ស និងគ្រូ ឱ្យទាញ Dynamic ពិតៗពី Database (សិស្សថ្មីបង្ហាញ 0/0/0/0%)។

2. **កិច្ចការទី ២ (Task 2 — រួចរាល់ ១០០% ✅) ៖ អភិវឌ្ឍ WeekDayStrip (ជម្រើសទី ២) លើ Mobile App**
   - បង្កើត Widget [week_day_strip.dart](file:///C:/Flutter_Project/Scan_In_App/scan_in/lib/widgets/week_day_strip.dart) បែប Modern Dark Mode រមូរបាន ១៤ ថ្ងៃ (២ សប្តាហ៍)។
   - បំពាក់លើ [StudentDashboardScreen](file:///C:/Flutter_Project/Scan_In_App/scan_in/lib/screens/student/student_dashboard_screen.dart) និង [LecturerDashboardScreen](file:///C:/Flutter_Project/Scan_In_App/scan_in/lib/screens/lecturer/lecturer_dashboard_screen.dart)។
   - មាន Dot Indicator សម្គាល់ថ្ងៃណាមានម៉ោងរៀន, ប៊ូតុង «ថ្ងៃនេះ» ត្រឡប់មកថ្ងៃបច្ចុប្បន្នភ្លាមៗ, ប៊ូតុងប្តូររវាង «មើលតាមថ្ងៃ» និង «មើលទាំងអស់»។
   - បង្ហាញកាលបរិច្ឆេទ Session ជាក់លាក់លើកាតថ្នាក់ (ឧ. `📅 សៅរ៍ ទី២១ វិច្ឆិកា 2026 • 07:00 - 08:30`)។
   - Empty State ឆ្លាតវៃជាមួយប៊ូតុងផ្លូវកាត់ «មើលថ្នាក់រៀនបន្ទាប់ ➔» រំលងទៅថ្ងៃបន្ទាប់ដែលមានម៉ោងរៀនភ្លាមៗ។

3. **កិច្ចការទី ៣ (Task 3 — រួចរាល់ ១០០% ✅) ៖ ចុះឈ្មោះនិស្សិតពិត ៥ នាក់ដំបូង & ដោះស្រាយ Generation Resilient Matching**
   - និស្សិតពិត ៥ នាក់ត្រូវបានចុះឈ្មោះក្នុង DB៖ `IT20-001` ដល់ `IT20-005` (IT Gen 20)។
   - ដោះស្រាយបញ្ហាលេខខ្មែរ vs អារ៉ាប់ (`ជំនាន់ទី 20` vs `ជំនាន់ទី ២០`) តាមរយៈ `ClassModel::extractGenNumber` និង `ClassModel::matchesGeneration` ធ្វើឱ្យគ្រប់ទម្រង់ជំនាន់ត្រូវគ្នា ១០០% ដោយគ្មានភាពរអាក់រអួល។

4. **កិច្ចការទី ៤ (Task 4 — រួចរាល់ ១០០% ✅) ៖ តេស្ត End-to-End Live QR Scan**
   - គ្រូបើក QR Class 88 -> សិស្ស `IT20-001` (កាទិក វីរ៉ាច) ស្កេនជោគជ័យ -> Record វត្តមាន `present` ចូល MySQL DB ត្រឹមត្រូវ។
   - ស្ថិតិវត្តមានរបស់សិស្សឆ្លុះបញ្ចាំង Dynamic ភ្លាមៗ (1 វត្តមាន / 100%)។

5. **កិច្ចការទី ៥ (Task 5 — រួចរាល់ ១០០% ✅) ៖ ញែកសិទ្ធិ Web Login ដាច់ស្រឡះ (Rector vs Staff/Lecturer) & UI Clean**
   - ផ្ទាំង «សាកលវិទ្យាធិការ» ផ្តាច់មុខសម្រាប់តែ Admin កំពូល CLI តែមួយគត់ (`role === 'admin'`)។ បុគ្គលិក Sub-Admin និងគ្រូ ត្រូវបានទប់ស្កាត់ជាមួយសារជូនដំណឹងជាភាសាខ្មែរច្បាស់លាស់។
   - ផ្ទាំង «គ្រូ / បុគ្គលិក» សម្រាប់តែ Sub-Admin (`sub_admin`) និង គ្រូបង្រៀន (`lecturer`)។ បើ Sub-Admin ចូល នឹងនាំផ្លូវទៅកាន់ Admin Dashboard រីឯគ្រូនាំផ្លូវទៅកាន់ Projector Workspace។
   - លុបអក្សរអង់គ្លេស subtitle និងការព្រមានបាតក្រោមទាំងអស់ ប្តូរមកជាភាសាខ្មែរសុទ្ធ (`ពាក្យតែ KH`) ការពារ Text Overflow ១០០%។
   - បន្ថែមប៊ូតុងបើក/បិទពាក្យសម្ងាត់ (Eye Toggle) និងសម្អាត Form ឱ្យនៅទទេលំនាំដើម។

6. **កិច្ចការទី ៦ (Task 6 — រួចរាល់ ១០០% ✅) ៖ សិទ្ធិពេញលេញសម្រាប់ Sub-Admin គ្រប់គ្រង និងបង្កើតគណនីគ្រូ**
   - កែសម្រួលលក្ខខណ្ឌសិទ្ធិលើ `AdminLecturersScreen`, `AdminStudentsScreen`, និង `AdminClassesScreen` មកប្រើ `_currentUser?.isAdmin == true` (អនុញ្ញាតទាំង Master Admin និង Sub-Admin)។
   - ឥឡូវ Sub-Admin អាចមើលបញ្ជីគ្រូ, បង្កើតគ្រូថ្មី (`POST /api/lecturers`), កែប្រែ, និងលុបបានពេញលេញ ព្រមទាំងគ្រប់គ្រងសិស្ស និងថ្នាក់រៀន។
   - រក្សាសុវត្ថិភាព Master Admin៖ Sub-Admin មិនអាចមើល ឬកែប្រែបញ្ជី Sub-Admin ផ្សេងទៀតឡើយ (`isMasterAdmin == true` ផ្តាច់មុខ)។
   - សរសេរ Feature Test `test_sub_admin_can_create_and_manage_lecturers` ក្នុង `SubAdminTest.php` ដំណើរការជោគជ័យ ១០០%។

7. **កិច្ចការទី ៧ (Task 7 — រួចរាល់ ១០០% ✅) ៖ យន្តការស្កេនលើស ១៥ នាទី រាប់ថាមក «យឺត» (Auto-Late QR Scan)**
   - ក្នុង `AttendanceController::scan` ប្រព័ន្ធស្រង់ម៉ោងចាប់ផ្តើមរបស់ថ្នាក់រៀន (ឧ. `07:00`)។
   - ប្រសិនបើសិស្សស្កេនលើស ១៥ នាទីបន្ទាប់ពីម៉ោងចាប់ផ្តើម (`> 07:15`) ប្រព័ន្ធកត់ត្រាស្វ័យប្រវត្តិនូវ status `late` (មកយឺត) ព្រមទាំង note បញ្ជាក់ម៉ោងជាក់ស្តែង (ឧ. `ស្កេនយឺត (ម៉ោង 07:25 លើស ១៥ នាទី)`)។
   - បើស្កេនទាន់ពេលក្នុងរង្វង់ ១៥ នាទី កត់ត្រាថា `present` (មករៀន)។

8. **កិច្ចការទី ៨ (Task 8 — រួចរាល់ ១០០% ✅) ៖ គ្រូ និង Admin អាចកែប្រែវត្តមានសិស្សដោយផ្ទាល់ (Direct Attendance Override)**
   - បង្កើត API `POST /api/attendances/manual` គាំទ្រ ៤ ស្ថានភាព៖
     1. `present` (មករៀន)
     2. `late` (មកយឺត)
     3. `absent` (អវត្តមាន)
     4. `reset` (លុបកំណត់ត្រាដើម្បីឱ្យសិស្សត្រឡប់ទៅសភាពដើម "មិនទាន់ស្កេន" ឬអាចស្កេនម្តងទៀត)
   - អនុញ្ញាតសម្រាប់តែគ្រូប្រចាំថ្នាក់នោះ ឬ Academic Admin (Admin/Sub-Admin)។ គ្រូដទៃមិនអាចកែប្រែបានឡើយ។
   - បំពាក់លើ Laptop Web Admin (`admin_classes_screen.dart`)៖ ក្នុងផ្ទាំងបញ្ជីឈ្មោះសិស្ស គ្រូអាចចុចលើស្លាកវត្តមានដើម្បីបើក Dialog ប្តូរស្ថានភាពភ្លាមៗ។
   - បំពាក់លើ Mobile App (`class_detail_screen.dart`)៖ ស្លាកវត្តមានសិស្សនីមួយៗអាចចុចបាន (Interactive Chip) ដើម្បីបើក Modal Bottom Sheet ប្តូរស្ថានភាពភ្លាមៗ។

9. **កិច្ចការទី ៩ (Task 9 — រួចរាល់ ១០០% ✅) ៖ បង្កើតអ៊ីមែលនិស្សិតស្វ័យប្រវត្តិ (@scanin.app) តាមទម្រង់សាមញ្ញ (Beginner-Friendly)**
   - ប្តូរពី `@student.scanin.app` មកជា `@scanin.app` គ្រប់ទីកន្លែង។
   - សរសេរកូដជំនួយ `generateStudentEmail` បែប Basic/Beginner ដោយប្រើ String Methods ធម្មតា (`toLowerCase()`, `replaceAll(' ', '.')`) មិនប្រើ Regex ស្មុគស្មាញ៖
     - ប្រសិនបើមានឈ្មោះឡាតាំង៖ បង្កើតទម្រង់ `ត្រកូល.នាមខ្លួន@scanin.app` (ឧ. `KATHIK VIRAJ` -> `kathik.viraj@scanin.app`)។
     - ប្រសិនបើគ្មានឈ្មោះឡាតាំង៖ បង្កើតតាមអត្តលេខ `code@scanin.app` (ឧ. `IT20-001` -> `it20001@scanin.app`)។
   - លើ Web Admin (`admin_students_screen.dart`)៖
     - ក្នុង Dialog បង្កើតសិស្សទោល៖ ពេលវាយបញ្ចូលឈ្មោះឡាតាំង ប្រព័ន្ធបំពេញ Email ដោយស្វ័យប្រវត្តិតាម Real-time។
     - ក្នុងផ្ទាំង Paste CSV/Excel៖ បើទុក Email នៅទទេ ឬគ្មានសញ្ញា `@` ប្រព័ន្ធបង្កើតអ៊ីមែលឱ្យស្វ័យប្រវត្តិតាមរូបមន្តខាងលើ។
     - កែប្រែគំរូ Header CSV និង Textbox Hint ទៅជា `kathik.viraj@scanin.app`។
   - លើ Backend Laravel (`routes/api.php`)៖ ធ្វើបច្ចុប្បន្នភាព Fallback Email ឱ្យត្រូវគ្នា ១០០%។
   - បានធ្វើបច្ចុប្បន្នភាពគណនីសិស្សពិតទាំង ៥ នាក់ក្នុង MySQL Database ទៅជា `@scanin.app` ត្រឹមត្រូវស្របគ្នាទាំងអស់។

10. **កិច្ចការទី ១០ (Task 10 — រួចរាល់ ១០០% ✅) ៖ ច្របាច់បញ្ចូលគ្នានូវថ្នាក់រៀនជាក្រុមតាមកូដមុខវិជ្ជា (Group Classes by Subject Code - Option 1)**
   - ដោះស្រាយបញ្ហាថ្នាក់រៀនមុខវិជ្ជាតែមួយ តែខុសកាលបរិច្ឆេទថ្ងៃបង្រៀន (ឧ. `IT001 - Data Mining With Python` ៣ ថ្ងៃ ឬ `HMA-Y4` ២ ថ្ងៃ) បង្ហាញជាន់គ្នា ៣ ជួរដេក និង Dashboard រាប់លេខ ៣៖
   - **លើ Dashboard (`admin_dashboard_screen.dart`)៖**
     - កាតស្ថិតិ «ថ្នាក់រៀនសរុប» រាប់តែ Unique Course Code ➔ បង្ហាញលេខ **១** យ៉ាងត្រឹមត្រូវ។
     - តារាងទិដ្ឋភាពទូទៅនៃថ្នាក់រៀន បង្ហាញត្រឹម ១ ជួរដេក និងបញ្ជាក់កាលវិភាគ `សៅរ៍ (07:00 - 08:30) • 3 ថ្ងៃ`។
   - **លើតារាងគ្រប់គ្រងថ្នាក់រៀន (`admin_classes_screen.dart`)៖**
     - ច្របាច់កាលបរិច្ឆេទទាំងអស់ឱ្យមកនៅត្រឹម **១ ជួរដេកតែមួយគត់ (1 Row)** ស្អាតបាត។
     - បន្ថែម Badge ឆ្លាតវៃ `🗓️ N កាលបរិច្ឆេទ (ចុចមើល)`៖ ចុចលើវាបង្ហាញ Dialog បញ្ជីថ្ងៃរៀននីមួយៗ (ឧ. `21/11`, `28/11`, `05/12`) ជាមួយប៊ូតុងបញ្ចាំង QR និងវត្តមានផ្ទាល់ខ្លួន។
     - ប៊ូតុង «បញ្ចាំង QR»៖ បើក Session ដែលកំពុង Active ឬបើក Dialog ឱ្យរើសកាលបរិច្ឆេទជាក់លាក់។
     - ប៊ូតុង «លុប»៖ មានជម្រើសឱ្យលុបមុខវិជ្ជានេះទាំងមូល ឬជ្រើសរើសលុបតែ ១ កាលបរិច្ឆេទ។
     - ដោះស្រាយបញ្ហា `BOTTOM OVERFLOWED BY 12 PIXELS` ដោយកំណត់ `dataRowMinHeight: 68` និង `dataRowMaxHeight: 78`។
   - **លើផ្ទាំងវត្តមាន (`admin_attendances_screen.dart`)៖**
     - Dropdown បង្ហាញកាលបរិច្ឆេទថ្ងៃរៀនជាប់ជាមួយឈ្មោះមុខវិជ្ជា (ឧ. `IT001 - Data Mining With Python (2026-11-21)`) ជួយឱ្យងាយស្រួលរើសសប្តាហ៍។

11. **កិច្ចការទី ១១ (Task 11 — រួចរាល់ ១០០% ✅) ៖ មុខងារ Auto-Fill Default ឆ្លាតវៃពេលវាយកូដមុខវិជ្ជា (Smart Subject Auto-Fill)**
   - ក្នុងផ្ទាំង «បង្កើតថ្នាក់រៀន និងចាត់តាំងគ្រូ» (`admin_classes_screen.dart`)៖
     - ប្រអប់កូដមុខវិជ្ជា និងឈ្មោះមុខវិជ្ជា ត្រូវបានបំពាក់ `EditableComboField` (អាចទាំងវាយបញ្ចូលដោយដៃ ឬចុចរើសពីបញ្ជីកូដចាស់ៗ `HMA-Y4`, `DM-Y4`, `IT001`...)។
     - ពេល Admin វាយបញ្ចូលកូដ (ឧ. `HMA-Y4`) ឬឈ្មោះមុខវិជ្ជា ប្រព័ន្ធនឹងស្វែងរក និងទាញយកទិន្នន័យពី Database មកបំពេញ Default ជូនភ្លាមៗ៖
       * ឈ្មោះមុខវិជ្ជា (`Hybrid Mobile App`)
       * ដេប៉ាតឺម៉ង់ (`ព័ត៌មានវិទ្យា (IT)`)
       * ជំនាន់ (`ជំនាន់ទី 20 (Gen 20)`)
       * គ្រូបង្រៀន (`អូន វឌ្ឍនៈ`)
       * ឆ្នាំទី (`ឆ្នាំទី ៤`)
       * បន្ទប់ (`112`)
       * ថ្ងៃរៀន (`សៅរ៍ (Sat)`)
       * ម៉ោងរៀន (`07:00 - 08:30`)
       * ឆមាស & ឆ្នាំសិក្សា (`ឆមាសទី ១ • 2026-2027`)
       * សប្តាហ៍សរុប (`15`)
       * កាលបរិច្ឆេទបង្រៀនបន្ទាប់ (`Next Session Date = Latest Date + 7 ថ្ងៃ` ស្វ័យប្រវត្តិ)
     - រាល់ទិន្នន័យដែល Auto-fill មកទាំងអស់ គឺគ្រាន់តែជា Default ប៉ុណ្ណោះ ដោយ Admin នៅតែអាចចុចកែប្រែថ្ងៃ ខែ បន្ទប់ ឬទិន្នន័យផ្សេងៗបានតាមចិត្ត ១០០%។
     - បង្ហាញសារជូនដំណឹងពណ៌បៃតងស្អាត `✨ ទាញយកទិន្នន័យគំរូរួចរាល់!` នៅខាងក្រោមប្រអប់កូដ។

12. **កិច្ចការទី ១២ (Task 12 — រួចរាល់ ១០០% ✅) ៖ ដោះស្រាយ RenderFlex Overflows លើ Sidebar ពេលទាញបង្រួមអេក្រង់ (Responsive Sidebar)**
   - ដោះស្រាយបញ្ហា Console Log លោត Error `RenderFlex overflowed by 86/36/20/16 pixels on the right` ពេលអ្នកប្រើប្រាស់ពង្រីក/បង្រួមកញ្ចក់ Browser កាត់បន្ទាត់ 900px។
   - ដកចេញ `AnimatedContainer` រយៈពេល 150ms ដែលបង្កើនការគៀបសង្កត់កូន Widget ក្នុងពេលផ្លាស់ប្តូរទំហំ។
   - ប្រើប្រាស់ `FittedBox(fit: BoxFit.scaleDown)` លើ Header Logo និង Footer នៃ Sidebar ធ្វើឱ្យ Sidebar បង្រួម និងពង្រីកភ្លាមៗដោយគ្មាន Exception សូម្បីតែ ១ pixel។

13. **កិច្ចការទី ១៣ (Task 13 — រួចរាល់ ១០០% ✅) ៖ ដោះស្រាយ Flutter Web Container Assertion Error**
   - **បញ្ហា៖** អេក្រង់ក្រហម `Assertion failed: decoration != null || clipBehavior == Clip.none is not true` ក្នុង `admin_scaffold.dart`។
   - **មូលហេតុបច្ចេកទេស៖** នៅក្នុង Flutter Web `Container` constructor មាន check `assert(decoration != null || clipBehavior == Clip.none)`។ ការដាក់ `color` ផ្ទាល់ជាមួយ `clipBehavior: Clip.hardEdge` ដោយគ្មាន `BoxDecoration` ធ្វើឱ្យ Throw Assertion Exception។
   - **ដំណោះស្រាយ៖** ជំនួសមកប្រើ `ClipRect(child: Container(width: sidebarWidth, color: sidebarBg, child: ...))` ដែលជាវិធីសាស្ត្រស្តង់ដារ និងមានស្ថិរភាពបំផុតរបស់ Flutter (Commit `67d445e`)។

14. **កិច្ចការទី ១៤ (Task 14 — រួចរាល់ ១០០% ✅) ៖ ចុះឈ្មោះនិស្សិតពិតប្រាកដទាំង ២០ នាក់ពេញលេញ (IT Gen 20 Clean Production)**
   - ផ្អែកលើតារាងសាលាផ្លូវការរបស់សាកលវិទ្យាល័យ (រូបភាព `media_1794914096166_0425cad2.jpg`)៖
     - **ដកឈ្មោះ `នាង ប៊ុនថានឌី` (`NEANG BUNTHANDY` - លេខរៀងទី ១៥) ចេញ** ពីបញ្ជីសិស្ស ស្របតាមការណែនាំរបស់ម្ចាស់គម្រោង ដោយសារគាត់ជា Master Admin អ្នកគ្រប់គ្រងកំពូលនៃប្រព័ន្ធ។
     - ចំនួននិស្សិតពិតប្រាកដសរុបគឺ **២០ នាក់** នៃដេប៉ាតឺម៉ង់ព័ត៌មានវិទ្យា (IT) ជំនាន់ទី ២០ ឆ្នាំទី ៤ (Intake 2023)។
   - **និស្សិតទាំង ២០ នាក់ត្រូវបានចុះឈ្មោះក្នុង MySQL Database ដោយជោគជ័យ៖**
     1. `IT20-001` — **កាទិក វីរ៉ាច** (KATHIK VIRAJ) — `kathik.viraj@scanin.app`
     2. `IT20-002` — **គឹម សីហា** (KIM SEYHA) — `kim.seyha@scanin.app`
     3. `IT20-003` — **ឃន រតនសត្យា** (KHORN RATHANAKSATYA) — `khorn.rathanaksatya@scanin.app`
     4. `IT20-004` — **ឆែម ម៉ីហា** (CHHEM MEYHA) — `chhem.meyha@scanin.app`
     5. `IT20-005` — **ដាំ អាយុសុធី** (DAM ARYUSOTHY) — `dam.aryusothy@scanin.app`
     6. `IT20-006` — **ឃឿន សុខខេង** (KHOEURN SOKKHENG) — `khoeurn.sokkheng@scanin.app`
     7. `IT20-007` — **ចៅ សុភក្ត្រា** (CHAO SOPHEAKTRA) — `chao.sopheaktra@scanin.app`
     8. `IT20-008` — **ឆន មករា** (CHHON MAKARA) — `chhon.makara@scanin.app`
     9. `IT20-009` — **ឌៀប ជោគជ័យ** (DIEB JOKCHEY) — `dieb.jokchey@scanin.app`
     10. `IT20-010` — **ណន ដានីត** (NORN DANITH) — `norn.danith@scanin.app`
     11. `IT20-011` — **តាន់ ជូហេង** (TANN CHOUHENG) — `tann.chouheng@scanin.app`
     12. `IT20-012` — **ថង សុដាវ៉ាន់** (THORNG SODAVAN) — `thorng.sodavan@scanin.app`
     13. `IT20-013` — **ធី ចាន់ថន** (THEY CHANTHORN) — `they.chanthorn@scanin.app`
     14. `IT20-014` — **ធេង គីមហេង** (THENG KOEMHENG) — `theng.koemheng@scanin.app`
     15. `IT20-015` — **នី ស៊ីដា** (NY SHIDA) — `ny.shida@scanin.app`
     16. `IT20-016` — **ប៉ែន វ៉ារី** (PEN VARY) — `pen.vary@scanin.app`
     17. `IT20-017` — **ផាង វិផាត់** (PHANG VIPHATH) — `phang.viphath@scanin.app`
     18. `IT20-018` — **ពិសិដ្ឋ ចាន់កក្កដា** (PISETH CHANKAKADA) — `piseth.chankakada@scanin.app`
     19. `IT20-019` — **ភៅ ព័ន្ធមុនីរ័ត្ន** (PHAO POANMONIRATH) — `phao.poanmonirath@scanin.app`
     20. `IT20-020` — **ម៉ន ប៊ុននាត** (MON BUNNEAT) — `mon.bunneat@scanin.app`
   - **ផ្ទៀងផ្ទាត់សមកាលកម្មថ្នាក់រៀន (Class Roster Verification)៖**
     - ថ្នាក់រៀន `Hybrid Mobile App` (`HMA-Y4`) បានឆ្លុះបញ្ចាំងនិស្សិតត្រូវគ្នាទាំង **២០ នាក់ (20 Matched Students)** ស្វ័យប្រវត្តិតាម Database។
     - Test Suite ដំណើរការជោគជ័យ **៣០ passed (១៩៣ assertions) ១០០%**។

15. **កិច្ចការទី ១៥ (Task 15 — រួចរាល់ ១០០% ✅) ៖ ស្ថិតិបង្រៀនមិនរាប់ស្ទួន (Distinct Subject & Unique Students) & សុក្រឹតភាពកាលវិភាគ**
   - **លើ Lecturer Dashboard & Profile (`lecturer_dashboard_screen.dart` & `lecturer_profile_screen.dart`) ៖**
     - **កាត «ថ្នាក់បង្រៀន» ៖** គណនាត្រឹមតែ Unique Course Code (`HMA-Y4`) ដោយមិនរាប់ស្ទួនតាមចំនួន Session កាលបរិច្ឆេទឡើយ ➔ បង្ហាញលេខ **១ ថ្នាក់បង្រៀន** យ៉ាងត្រឹមត្រូវ។
     - **កាត «សិស្សសរុប» ៖** បូកសរុបតែសិស្សនៃមុខវិជ្ជា Distinct មិនបូកស្ទួនសិស្ស ២០ នាក់ដដែលៗជា ៤០ នាក់ឡើយ ➔ បង្ហាញលេខ **២០ សិស្សសរុប** យ៉ាងត្រឹមត្រូវ។
   - **លើការផ្គូផ្គងកាលវិភាគ (`app_datetime.dart`) ៖**
     - កែសម្រួល `AppDateTime.matchesClassSchedule` ឱ្យមានសុក្រឹតភាពខ្ពស់បំផុត៖ ប្រសិនបើថ្នាក់រៀនមាន `classDate` (ឧ. `2026-11-21` ឬ `2026-11-28`) ប្រព័ន្ធផ្គូផ្គងចំកាលបរិច្ឆេទនោះតែម្តង ដោយមិនធ្លាក់ទៅជាន់ថ្ងៃសប្តាហ៍ «សៅរ៍» នាំឱ្យបង្ហាញថ្នាក់ខុសកាលបរិច្ឆេទឡើយ។
     - ពេលគ្រូចុចលើថ្ងៃសៅរ៍ ទី២៨ វិច្ឆិកា នឹងបង្ហាញតែ Session ថ្ងៃទី ២៨ មួយគត់ (បង្ហាញ `ថ្នាក់បង្រៀនតាមថ្ងៃ (1)`), ហើយពេលចុចថ្ងៃទី ២១ នឹងបង្ហាញតែ Session ថ្ងៃទី ២១។
     - ធ្វើសមកាលកម្មកូដនេះដូចគ្នាទាំងលើ Mobile App និង Web Admin។

---

### 🧹 ការត្រួតពិនិត្យ និងសម្អាត File, Folder & Code (Project Hygiene & Zero Dead Code - FFC Audit)
- **ការត្រួតពិនិត្យឯកសារ និងថត (Files & Folders) ៖**
  - បានបោសសម្អាតឯកសារបណ្តោះអាសន្ន 0-byte (`name}`, `student_code}`) ចេញពី `scan_in_backend`។
  - គ្មានឯកសារ Scratch/Test (`test_*.php`, `check_*.php`) នៅក្នុង Directory គម្រោងឡើយ។
  - គ្មាន log files ចាស់ៗ (`flutter_*.log`) នៅក្នុង Repository។
- **សុពលភាពកូដ និងការធ្វើតេស្ត (Code Quality & Verification) ៖**
  - **Laravel Backend Test Suite ៖** `php artisan test` ទទួលបានលទ្ធផល **៣០ passed, ១៩៣ assertions (១០០% PASS)** រយៈពេលត្រឹមតែ **២.៧៨ វិនាទី**។
  - **Flutter Web Admin (`scan_in_admin`) ៖** `flutter analyze` ទទួលបាន **No issues found! (0 warnings, 0 errors)** ក្នុងរយៈពេល **២.០ វិនាទី**។
  - **Flutter Mobile App (`scan_in`) ៖** `flutter analyze` ទទួលបាន **No issues found! (0 warnings, 0 errors)** ក្នុងរយៈពេល **២.២ វិនាទី**។
  - **Database Service ៖** MySQL / MariaDB ដំណើរការយ៉ាងរលូនលើ Port 3306។
- **Git & Backup ៖**
  - Git Working Tree ស្អាតបាត ១០០% (`nothing to commit, working tree clean`)។
  - Commit ចុងក្រោយត្រូវបាន Push ទៅកាន់ `origin/main` (GitHub) និង Robocopy Sync ទៅកាន់ Backup Mirror `C:\Users\Jitsu Window\Scan_In_App_Backup\`។

---

### 📋 ផែនការការងារជំហានបន្ទាប់ (Next Steps Roadmap)
1. **មុខងារ Upload Profile Photo (Camera / Gallery) ៖**
   - ដំឡើង package `image_picker` លើ Mobile App `scan_in`។
   - បង្កើត API `POST /api/profile/avatar` ក្នុង Laravel សម្រាប់ Upload និងរក្សាទុករូបភាព Profile សិស្ស និងគ្រូ។
3. **មុខងារ Export របាយការណ៍វត្តមាន (Excel / PDF) ៖**
   - គាំទ្រការទាញទិន្នន័យវត្តមានតាមមុខវិជ្ជា និងតាមដេប៉ាតឺម៉ង់សម្រាប់គ្រូ និងរដ្ឋបាលយកទៅប្រើប្រាស់ផ្លូវការ។
4. **WebSocket / Auto-Refresh សម្រាប់ Projector Mode ៖**
   - ពេលសិស្សស្កេនលើទូរស័ព្ទ បញ្ជីឈ្មោះលើផ្ទាំង Projector កុំព្យូទ័រគ្រូ update ឡើងមកភ្លាមៗដោយស្វ័យប្រវត្តិ។
