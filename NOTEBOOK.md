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
   * `id`, `name`, `email`, `password`, `role` (`lecturer` / `student` / `admin`), `student_code`, `gender` (ភេទ), `date_of_birth` (ថ្ងៃខែឆ្នាំកំណើត), `staff_id`, `department`, `phone`, `avatar_url`
2. **`classes` (ថ្នាក់រៀន/មុខវិជ្ជា)៖**
   * `id`, `user_id` (ID គ្រូបង្រៀនដែល Admin បានចាត់តាំង), `subject_name`, `subject_code`, `room`, `day_of_week`, `time`, `semester`, `academic_year`, `is_qr_active`, `qr_token`
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
| 11 | **បញ្ជីសិស្សស្កេន Live ក្នុង ShowQR** | `lib/screens/lecturer/show_qr_screen.dart` | ⏳ **នៅ** | បញ្ជីឈ្មោះសិស្សដែលស្កេនឃើញ Live នៅបាតអេក្រង់ QR លើទូរស័ព្ទ នៅប្រើ MockData |
| 12 | **បញ្ជីវត្តមានតាមថ្នាក់របស់គ្រូ** | `lib/screens/lecturer/attendance_list_screen.dart` | ✅ **រួចរាល់** | ទាញយកវត្តមានតាមថ្នាក់នីមួយៗតាម `GET /api/classes/{id}/attendances` ពី DB |
| 13 | **គ្រូកែប្រែវត្តមាន & Note លើទូរស័ព្ទ**| `lib/screens/lecturer/attendance_list_screen.dart` | ✅ **រួចរាល់** | កែប្រែ Status (មក, យឺត, អវត្តមាន) ព្រមទាំង Note តាម `PUT /api/attendances/{id}` ចូល DB (គាំទ្រ Dark Mode ពេញលេញ) |
| 14 | **ព័ត៌មានលម្អិតថ្នាក់ (សិស្សក្នុងថ្នាក់)** | `lib/screens/lecturer/class_detail_screen.dart` | ⏳ **នៅ** | ព័ត៌មានថ្នាក់បង្ហាញពី DB, គាំទ្រ Dark Mode ពេញលេញ ប៉ុន្តែបញ្ជីឈ្មោះសិស្សក្នុងថ្នាក់នៅប្រើ MockData |
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
| 26 | **Admin បង្កើតថ្នាក់រៀនកណ្តាល** | `lib/screens/admin_classes_screen.dart` | ✅ **រួចរាល់** | បង្កើតថ្នាក់ (ឆ្នាំ, ឆមាស, កូដ, ឈ្មោះ, បន្ទប់, ម៉ោង, គ្រូ) តាម `POST /api/classes` ចូល DB |
| 27 | **Admin កែប្រែ / លុបថ្នាក់រៀន** | `lib/screens/admin_classes_screen.dart` | ✅ **រួចរាល់** | មានប៊ូតុង Actions (Edit & Delete) កែប្រែព័ត៌មាន និងលុបថ្នាក់រៀនព្រមទាំង Attendance ពាក់ព័ន្ធតាម `PUT/DELETE /api/classes/{id}` ចូល DB |
| 28 | **គ្រូបញ្ចាំង Dynamic QR Projector** | `lib/screens/admin_classes_screen.dart` | ✅ **រួចរាល់** | Projector Fullscreen លើ Laptop, Toggle QR តាម `POST /api/classes/{id}/toggle-qr` ចូល DB |
| 29 | **ពិនិត្យវត្តមានសិស្សតាមថ្នាក់លើ Web**| `lib/screens/admin_attendances_screen.dart` | ✅ **រួចរាល់** | ទាញយកវត្តមានតាមថ្នាក់ដែលជ្រើសរើសតាម `GET /api/classes/{id}/attendances` ពី DB |
| 30 | **កែប្រែវត្តមាន & Note លើ Web** | `lib/screens/admin_attendances_screen.dart` | ✅ **រួចរាល់** | ប៊ូតុង "កែប្រែ" ប្តូរ Status និង Quick Note តាម `PUT /api/attendances/{id}` ចូល DB ភ្លាមៗ |
| 31 | **Export របាយការណ៍វត្តមាន (Excel/PDF)**| `lib/screens/admin_attendances_screen.dart` | ⏳ **នៅ** | មិនទាន់មានប៊ូតុងទាញយកជារបាយការណ៍ Excel ឬ PDF សម្រាប់រដ្ឋបាលសាលា |

---

## ៥. សេចក្តីសង្ខេប និងកិច្ចការបន្ត (Summary & Next Steps)

### 📊 សរុបស្ថិតិ UI to DB៖
* ✅ **មុខងារដែលបានភ្ជាប់ Database រួចរាល់៖** **២៨ មុខងារ** (ស្មើនឹង **៨៨%** នៃប្រព័ន្ធទាំងមូល រួមមានស្នូលសំខាន់ៗ៖ Login, Admin បង្កើត/កែប្រែ/លុបគ្រូ, បង្កើត/កែប្រែ/លុបសិស្ស, Import សិស្សពី Excel/CSV, បង្កើត/កែប្រែ/លុបថ្នាក់រៀន, Projector Fullscreen QR, ស្កេនកត់វត្តមាន, និងកែប្រែវត្តមាន)។
* ⏳ **មុខងារដែលនៅសល់ត្រូវបន្តភ្ជាប់ DB៖** **៤ មុខងារ** (ស្មើនឹង **១២%**)។

### 🎯 ជំហានបន្តបន្ទាប់ (Action Plan)៖
1. [x] **កែប្រែ និងលុបថ្នាក់រៀន (Edit & Delete Classes - Admin Only) [រួចរាល់ ✅]**
2. [x] **កែប្រែ និងលុបគណនីគ្រូបង្រៀន (Edit & Delete Lecturers - Admin Only) [រួចរាល់ ✅]**
3. [x] **កែប្រែ និងលុបគណនីសិស្ស (Edit & Delete Students - Admin Only) [រួចរាល់ ✅]**
4. [x] **Import បញ្ជីសិស្សពី Excel / CSV (Bulk Student Import with Gender & DOB) [រួចរាល់ ✅]**
5. [ ] **ការភ្ជាប់បញ្ជីឈ្មោះសិស្សក្នុងថ្នាក់ (Enrolled Students Roster)** (Live Scanned Students & `ClassDetailScreen`)
