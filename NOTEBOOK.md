# 📓 កំណត់ត្រាសង្ខេបគម្រោង (ScanIn App Notebook)

---

## ១. ទិដ្ឋភាពទូទៅនៃកម្មវិធី (App Overview)
* **ឈ្មោះគម្រោង៖** ScanIn Attendance System
* **បច្ចេកវិទ្យា (Tech Stack)៖**
  * **Frontend (Mobile)៖** Flutter (Dart) — `scan_in` (សម្រាប់សិស្សស្កេនកាមេរ៉ា និងគ្រូប្រើចល័ត)
  * **Web Portal (Laptop / Desktop)៖** Flutter for Web (Dart) — `scan_in_admin` (ញែកដាច់រវាង Admin Panel និង Lecturer Classroom View)
  * **Backend (API)៖** Laravel 12 (PHP) — `scan_in_backend` (RESTful API + Sanctum + Multi-role Guard)
  * **Database៖** MySQL (Database Name: `scan_in`)
* **តួនាទីអ្នកប្រើប្រាស់ និងការបែងចែកសិទ្ធិដាច់ខាត (Roles & Strict Access Control)៖**
  * **Admin (អ្នកគ្រប់គ្រងសាលា)៖** មានសិទ្ធិផ្តាច់មុខក្នុងការបង្កើតគណនីគ្រូ, បង្កើតគណនីសិស្ស, បង្កើតថ្នាក់រៀន (ឆ្នាំសិក្សា, ឆមាស, កូដ, ឈ្មោះ, បន្ទប់, ម៉ោង) និងចាត់តាំងគ្រូបង្រៀន, មើល Dashboard និងរបាយការណ៍សរុបទូទាំងសាកលវិទ្យាល័យ។ **(គ្រូ និងសិស្ស មិនអាចចូលជា Admin បានដាច់ខាត)**។
  * **គ្រូ (Lecturer - Laptop Web & Mobile)៖** ទទួលបានគណនីពីសាលា, ពិនិត្យតែថ្នាក់ដែលខ្លួនត្រូវបានចាត់តាំង, បើក Projector Fullscreen QR Code លើ Laptop ក្នុងថ្នាក់រៀន, តាមដានវត្តមានសិស្សស្កេនផ្ទាល់, កែប្រែ Status វត្តមានជាក់ស្តែង (មក, យឺត, អវត្តមាន, ច្បាប់)។ **(គ្មានសិទ្ធិបង្កើតគណនី ឬកែប្រែកាលវិភាគមេរបស់ Admin ឡើយ)**។
  * **សិស្ស (Student - Mobile App Only)៖** ទទួលបានគណនីពីសាលា (Email/Password), ចូល Mobile App, បើក Camera ទូរស័ព្ទស្កេន QR Code កត់វត្តមាន, មើលស្ថិតិ Dashboard (មក, យឺត, អវត្តមាន), តាមដានប្រវត្តិវត្តមានផ្ទាល់ខ្លួន, ប្តូរពាក្យសម្ងាត់ផ្ទាល់ខ្លួន។ **(មិនអនុញ្ញាតឱ្យចូលប្រើលើ Web ឡើយ)**។

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
2. **បង្កើតគណនីសិស្ស៖** Admin ចូលផ្ទាំង `AdminStudentsScreen` -> `POST /api/students` -> ប្រគល់ Email/Pass ជូនសិស្ស។
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
1. **`users` (គណនីអ្នកប្រើប្រាស់ដែលបង្កើតដោយ Admin)៖**
   * `id`, `name` (ឈ្មោះជាអក្សរខ្មែរ), `latin_name` (ឈ្មោះជាអក្សរឡាតាំង), `email`, `password`, `role` (`lecturer` / `student` / `admin`), `student_code`, `gender` (ភេទ), `date_of_birth` (ថ្ងៃខែឆ្នាំកំណើត), `staff_id`, `department`, `generation` (ជំនាន់), `intake_year` (ចាប់ពីឆ្នាំ), `year_level` (ឆ្នាំទី ១–៤), `status` (`active` / `graduated` / `inactive`), `phone`, `avatar_url`
2. **`classes` (ថ្នាក់រៀន/មុខវិជ្ជា)៖**
   * `id`, `user_id` (ID គ្រូបង្រៀនដែល Admin បានចាត់តាំង), `subject_name`, `subject_code`, `department` (ដេប៉ាតឺម៉ង់), `generation` (ជំនាន់ - ស្រេចចិត្ត), `year_level` (ឆ្នាំទី ១–៤), `room`, `day_of_week`, `time`, `semester`, `academic_year`, `student_count`, `completed_sessions`, `total_sessions` (Default 15 - កែសម្រួលបាន 1–60), `is_qr_active`, `qr_token`
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

---

## ៥. សេចក្តីសង្ខេប និងកិច្ចការបន្ត (Summary & Next Steps)

### 📅 កំណត់ត្រាកិច្ចការដែលបានសម្រេច (13/11/2026)៖
1. **បញ្ជីឈ្មោះសិស្សក្នុងថ្នាក់រៀន (Class Student Roster Dialog)៖**
   * បន្ថែម `ClassService.getClassStudents(classId)` ហៅទៅ API `GET /api/classes/{id}/students`។
   * បន្ថែមប៊ូតុង `[បញ្ជីសិស្ស]` ក្នុងតារាងថ្នាក់រៀន `admin_classes_screen.dart` ដើម្បីបើក Modal មើលឈ្មោះខ្មែរ, ឈ្មោះឡាតាំង, អត្តលេខ, ភេទ, លេខទូរស័ព្ទ និងស្ថានភាពវត្តមានថ្ងៃនេះ។
2. **Export វត្តមានតាមថ្នាក់ជា CSV៖**
   * បន្ថែមប៊ូតុង `[Export CSV]` លើ `admin_attendances_screen.dart` អាចទាញយកទិន្នន័យវត្តមានសិស្សទាំងអស់ជា CSV ទៅបើកក្នុង Microsoft Excel ភ្លាមៗ។
3. **កែលម្អការ Import សិស្សពី Excel / CSV និង Horizontal Drag៖**
   * បន្ថែមប្រអប់កំណត់តម្លៃរួម (Batch Defaults) ក្នុងផ្ទាំង Import ៖ ជំនាន់ (Generation), ចាប់ពីឆ្នាំ (Intake Year), ឆ្នាំទី (Year Level), ដេប៉ាតឺម៉ង់លំនាំដើម។
   * គាំទ្រទាំងទម្រង់ពេញលេញ ១១ ជួរឈរ និងទម្រង់ចាស់ ៧ ជួរឈរ ដោយបំពេញជំនាន់/ឆ្នាំទីស្វ័យប្រវត្តិ (មិនឱ្យសិស្សជាប់ស្ថានភាព "មិនទាន់កំណត់ឆ្នាំទី" ទៀតឡើយ)។
   * បន្ថែមមុខងារ Smart Department Normalization ទាំងខាង Backend និង Web Admin (ឧ. "Information Technology" -> "ព័ត៌មានវិទ្យា (IT)", "Computer Science" -> "វិទ្យាសាស្ត្រកុំព្យូទ័រ (CS)")។
   * បំពាក់ `ScrollConfiguration` គាំទ្រ Mouse Drag និង `Scrollbar` ជាប់ជាមួយ `_horizontalScrollCtrl` ទាំងលើតារាងសិស្ស និងតារាងថ្នាក់រៀន ជួយឱ្យ User អាចអូសទៅស្ដាំមើលជួរឈរ "សកម្មភាព (Actions)" បានយ៉ាងរលូន។
4. **អនុញ្ញាតឱ្យកំណត់ដោយដៃ (Dynamic & Manual Entry) មិនចងស្លាប់លើ Dropdown៖**
   * ពង្រីក `buildIntakeYearOptions`, `buildAcademicYearOptions`, និង `buildGenerationOptions` ក្នុង `ClassService` ឱ្យបង្កើតជម្រើសឆ្លាតវៃវែងឆ្ងាយ (ជំនាន់ទី ១០–៣០, ឆ្នាំ ២០២០–២០៣៥+) មិនបាច់សរសេរកូដសារជាថ្មីពេលឆ្លងឆ្នាំ។
   * គ្រប់ប្រអប់បញ្ចូលប្រើ `EditableComboField` ដែលអាចឱ្យ Admin វាយតម្លៃណាមួយដោយដៃផ្ទាល់ក៏បាន ឬចុចរើសពីបញ្ជីរហ័សក៏បាន។
5. **ដេប៉ាតឺម៉ង់ / មហាវិទ្យាល័យ អាចវាយបន្ថែមដោយដៃ និងឆ្លុះបញ្ចាំងគ្រប់អេក្រង់ (Global Department Sync)៖**
   * បង្កើត API `GET /api/departments` ទាញយកដេប៉ាតឺម៉ង់ និងជំនាញទាំងអស់ដែលធ្លាប់បង្កើតក្នុង DB (ទាំងពីតារាង `users` និង `classes`) បូកបញ្ចូលជាមួយ Preset ដេប៉ាតឺម៉ង់។
   * ប្តូរប្រអប់ "ដេប៉ាតឺម៉ង់ / មហាវិទ្យាល័យ" លើផ្ទាំង **បង្កើត/កែប្រែគ្រូបង្រៀន (`admin_lecturers_screen.dart`)**, **បង្កើត/កែប្រែសិស្ស (`admin_students_screen.dart`)**, និង **បង្កើត/កែប្រែថ្នាក់រៀន (`admin_classes_screen.dart`)** ពី Dropdown ចងស្លាប់ មកជា `EditableComboField` អាចវាយបញ្ចូលដោយដៃសេរី ឬរើសពីបញ្ជីរហ័ស។
   * ពេល Admin វាយឈ្មោះដេប៉ាតឺម៉ង់ថ្មីណាមួយ ប្រព័ន្ធនឹង Register និង Sync ចូល `ClassService` ភ្លាមៗ ធ្វើឱ្យឈ្មោះដេប៉ាតឺម៉ង់ថ្មីនោះលេចចេញក្នុងបញ្ជីជ្រើសរើសនៃគ្រប់ផ្ទាំង (សិស្ស, ថ្នាក់រៀន, គ្រូ, ផ្ទាំង Import, និង Dropdown Filter) ដោយស្វ័យប្រវត្តិ។
6. **ជួសជុល និង Sync ទិន្នន័យក្រោយដាច់ភ្លើង (NTFS Healing & Recovery)៖**
   * ជួសជុល File 0-byte ក្នុង `.git` និង `vendor` ពី Backup mirror ស្អាតស្អំ ១០០%។
   * ធ្វើតេស្ត `php artisan test` ឆ្លងកាត់ទាំង **18 passed (141 assertions)**, `flutter analyze` ទាំង Mobile និង Web **No issues found**។

---

### 📅 កំណត់ត្រាកិច្ចការដែលបានសម្រេចថ្ងៃនេះ (Completed Today — 12/11/2026)៖
1. **ការពារសិទ្ធិថ្នាក់រៀន (Role & Ownership Isolation)៖**
   * ដកមុខងារបង្កើត/កែ/លុបថ្នាក់ចេញពី Mobile App គ្រូ (`scan_in`), កែ `create_class_screen.dart` ចោល, កែការស្វាគមន៍ `"លោកគ្រូ លោកគ្រូ"` ត្រួតគ្នា។
   * គ្រូម្នាក់ៗមើលឃើញ និងគ្រប់គ្រង **តែថ្នាក់ដែល Admin ចាត់តាំងឱ្យខ្លួន** (`ClassController`, `AttendanceController`, `AdminClassesScreen`), ផ្ទាំងផ្សេងការពារ `403`។
   * បន្ថែម `RefreshIndicator` (Pull-to-Refresh) គ្រប់អេក្រង់ទាំង Mobile (`scan_in`) និង Web Admin (`scan_in_admin`) ព្រមទាំងជួសជុល Gradle NTFS `build_corrupt`។
2. **លុប `MockData` ចេញពីកូដដំណើរការ 100% & ភ្ជាប់ DB សុទ្ធ៖**
   * ដក `MockData` fallback ទាំងអស់ចេញពី `scan_in` និង `scan_in_admin` (រួមទាំង `StudentHomeScreen`, `StudentDashboardScreen`, `ClassDetailScreen`, `ShowQrScreen`, `AttendanceListScreen`, និង Services)។
   * បង្កើត API `GET /api/classes/{id}/students` ដើម្បីទាញនិស្សិតពិត និងគណនា `student_count` ពិតពី MySQL។
3. **ដេប៉ាតឺម៉ង់, ជំនាន់, ចាប់ពីឆ្នាំ, ឆ្នាំទី (1–4) & ស្ថានភាពសិស្ស៖**
   * បន្ថែមជួរឈរ DB (Migrations Batch 5–8)៖ `department` លើ `classes`, `latin_name` លើ `users`, `generation`, `intake_year`, `year_level` លើ `users`/`classes`, និង `status` (`active`, `graduated`, `inactive`) លើ `users`។
   * សិស្សឃើញ និងស្កេនបាន **តែថ្នាក់ត្រូវតាម `department` + `year_level` + `generation` និងមានស្ថានភាព `active` ប៉ុណ្ណោះ** (បដិសេធ `403` បើខុសឆ្នាំ/ដេប៉ាតឺម៉ង់ ឬរៀនចប់/ឈប់រៀន)។
   * អាចកំណត់ **ឈ្មោះជាអក្សរខ្មែរ (`name`)** និង **ឈ្មោះជាអក្សរឡាតាំង (`latin_name`)** សម្រាប់ទាំងគ្រូ និងសិស្ស។
4. **Admin Controls & Historical Reporting៖**
   * កំណត់ **ចំនួនសប្តាហ៍សិក្សា (`total_sessions`)** ដោយ Default `15` (Admin កែបាន 1–60 តាមសាលានីមួយៗ) និងរាប់ `completed_sessions` ស្វ័យប្រវត្តិពីថ្ងៃស្កេនពិត។
   * បន្ថែម `EditableComboField` ([editable_combo_field.dart](file:///d:/Flutter_Project/Scan_In_App/scan_in_admin/lib/widgets/editable_combo_field.dart)) ឱ្យ Admin **វាយកំណត់ដោយដៃ ឬរើសរហ័ស** សម្រាប់ `ឆ្នាំសិក្សា`, `ចាប់ពីឆ្នាំ`, និង `ជំនាន់` ដោយកើនតាមឆ្នាំបច្ចុប្បន្នស្វ័យប្រវត្តិ។
   * រៀបចំម៉ឺនុយ **`របាយការណ៍`** អាចពន្លាជម្រើសរងបាន + ទំព័រ **`ស្ថិតិតាមឆ្នាំ & ជំនាញ` (Admin Only)** (`GET /api/admin/reports/student-stats`) រក្សាទិន្នន័យសិស្សទាំងអស់អចិន្ត្រៃយ៍ + Copy CSV។

### ✅ ស្ថានភាពត្រួតពិនិត្យកូដ File & Folder (Audit — 12/11/2026)៖
* **Root Workspace (`d:\Flutter_Project\Scan_In_App`)៖** `scan_in` (Mobile App), `scan_in_admin` (Web Portal), `scan_in_backend` (Laravel 12 API), `NOTEBOOK.md`, `APP_OVERVIEW.txt`, `README.md`, `.gitignore` — ស្អាតគ្មាន File លើស។
* **`flutter analyze` (`scan_in_admin` & `scan_in`)៖** `No issues found!` ទាំងពីរ។
* **`php artisan migrate:status`៖** Migrations ទាំង ១១ (`Batch 1–8`) បាន Run ចូល MySQL រួចរាល់ (`Ran`)។
* **`php artisan test`៖** **17 passed (136 assertions)** (`AuthApiTest`, `ClassIsolationTest`, `DepartmentIsolationTest`, `DualNameUsersTest`, `GenerationYearIsolationTest`, `StudentStatusAndReportsTest`)។
* **Backup៖** បានរក្សាទុកចូល Git និង Backup នៅ `C:\Users\Jitsu Window\Scan_In_App_Backup\`។

---

### 🚀 ផែនការងារដែលត្រូវធ្វើបន្ត (Roadmap & Production Checklist)៖

1. **[កត់ចំណាំពេលដាក់ឱ្យប្រើប្រាស់ជាក់ស្តែង — Real Production Checklist]៖**
   * **ដកគណនីគំរូ (Demo Users)៖** ដក `dara@scanin.app` (គ្រូ ចាន់ ដារ៉ា) និង `student@scanin.app` (សិស្ស សុខា ម៉េង) ចេញពី [DatabaseSeeder.php](file:///d:/Flutter_Project/Scan_In_App/scan_in_backend/database/seeders/DatabaseSeeder.php) ដោយទុកតែគណនី Admin មេពិតប្រាកដ ឬ Seeder ស្អាតស្អំ។
   * **ធ្វើបច្ចុប្បន្នភាព [AuthApiTest.php](file:///d:/Flutter_Project/Scan_In_App/scan_in_backend/tests/Feature/AuthApiTest.php)៖** ប្តូរពីការហៅគណនីរឹងក្នុង Seeder មកប្រើ `User::factory()->create()` ជាមួយ `DatabaseTransactions` ដូច Test ឯទៀត ដើម្បីឱ្យ Automated Tests ទាំងអស់នៅតែ pass 100% ទោះបី Database គ្មានទិន្នន័យគំរូ Seeder សូម្បីតែមួយក៏ដោយ។
   * **សម្អាត MySQL Database៖** សម្អាតថ្នាក់រៀនសាកល្បង និងសិស្សសាកល្បងចេញ ដើម្បីទុកតែទិន្នន័យពិតរបស់សាលា។

2. **[តេស្តជាក់ស្តែង End-to-End] ពិនិត្យទិន្នន័យលើ Web Admin & Mobile App៖**
   * ចូល Web Admin ដើម្បីកំណត់ `ដេប៉ាតឺម៉ង់`, `ឆ្នាំទី`, `ជំនាន់`, `ចាប់ពីឆ្នាំ`, `ឈ្មោះជាអក្សរឡាតាំង` ឱ្យគ្រូ សិស្ស និងថ្នាក់រៀនចាស់ៗដែលបង្កើតមុនការអាប់ដេត, រួចសាក Login ស្កេន QR និងពិនិត្យ `របាយការណ៍ → ស្ថិតិតាមឆ្នាំ & ជំនាញ`។
2. **[អាទិភាពទី ២] បន្ថែមរបាយការណ៍រងថ្មីៗក្រោមម៉ឺនុយ `របាយការណ៍` & Export (Admin Reports)៖**
   * បន្ថែមជម្រើសរបាយការណ៍ថ្មីតាមតម្រូវការសាលា និងប៊ូតុង Export របាយការណ៍វត្តមានជា Excel / CSV / PDF ក្នុង `AdminAttendancesScreen`។
3. **[អាទិភាពទី ៣] Profile Avatar Upload & Personal Info Editing (UI to DB)៖**
   * បង្កើត API `POST /api/user/profile` ដើម្បីឱ្យគ្រូ និងសិស្សអាច Upload រូបថត Profile ពិតប្រាកដ រក្សាទុកក្នុង `storage/app/public/avatars` និង Update ចូល Database។
