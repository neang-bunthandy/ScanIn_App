# 📓 កំណត់ត្រាសង្ខេបគម្រោង (ScanIn App Notebook)

---

## ១. ទិដ្ឋភាពទូទៅនៃកម្មវិធី (App Overview)
* **ឈ្មោះគម្រោង៖** ScanIn Attendance System
* **បច្ចេកវិទ្យា (Tech Stack)៖**
  * **Frontend (Mobile)៖** Flutter (Dart) — គាំទ្រ Android & iOS
  * **Backend (API)៖** Laravel 12 (PHP) — RESTful API + Laravel Sanctum (Bearer Token)
  * **Database៖** MySQL (Database Name: `scan_in`)
* **តួនាទីអ្នកប្រើប្រាស់ (Roles)៖**
  * **គ្រូ (Lecturer)៖** បង្កើត/គ្រប់គ្រងថ្នាក់រៀន, បើក/បិទ Dynamic QR Code, ពិនិត្យបញ្ជីវត្តមានសិស្ស។
  * **សិស្ស (Student)៖** ស្កេន QR Code កត់វត្តមាន, មើលកាលវិភាគថ្នាក់រៀន, តាមដានប្រវត្តិវត្តមានផ្ទាល់ខ្លួន។
  * **Admin (Web Panel - នឹងបន្ថែម)៖** គ្រប់គ្រងគណនីគ្រូ សិស្ស និងរបាយការណ៍រួមទូទាំងសាលា។

---

## ២. ដំណើរការ Code (Code Flow)

```
[Flutter UI] ---> [Services] ---> [ApiConfig] ---> [Laravel API Routes] ---> [Controllers] ---> [MySQL DB]
```

### ក. Flow ចូលប្រើប្រាស់ (Authentication Flow)
1. User បញ្ចូល Email & Password លើ `login_screen.dart`
2. ហៅ `AuthService.login()` ផ្ញើទៅ `POST /api/login`
3. Laravel ផ្ទៀងផ្ទាត់ Hash Password -> បង្កើត **Sanctum Bearer Token**
4. Flutter ទទួល Token រក្សាទុកក្នុង `SharedPreferences` រួចបញ្ជូន User ទៅកាន់ Dashboard តាម Role (គ្រូ ឬ សិស្ស)។

### ខ. Flow គ្រូបើក QR និងពិនិត្យវត្តមាន (Lecturer Flow)
1. គ្រូបើកដំណើរការ QR លើថ្នាក់រៀន -> ហៅ `ClassService.toggleQr()` -> `POST /api/classes/{id}/toggle-qr` (Update `is_qr_active` = true & `qr_token`)
2. បញ្ចាំង QR Code លើផ្ទាំង Projector ឱ្យសិស្សស្កេន (`show_qr_screen.dart`)
3. ពិនិត្យបញ្ជីវត្តមានតាមថ្នាក់ (`attendance_list_screen.dart`) -> ហៅ `AttendanceService.getClassAttendances(classId)` -> `GET /api/classes/{id}/attendances` ទាញទិន្នន័យជាក់ស្តែងពី DB។

### គ. Flow សិស្សស្កេនកត់វត្តមាន (Student Flow)
1. សិស្សបើក Camera ស្កេន QR ឬវាយ QR Token (`student_home_screen.dart`)
2. ហៅ `AttendanceService.scanAttendance()` -> `POST /api/attendances/scan`
3. Laravel ពិនិត្យ Token និងស្ថានភាព QR -> បើត្រូវ បង្កើត Record ចូលតារាង `attendances` (Status: `present`)
4. សិស្សអាចចូលមើលកំណត់ត្រាស្កេនរបស់ខ្លួនភ្លាមៗក្នុង `student_history_screen.dart` (ទាញពី `GET /api/student/attendances`)។

---

## ៣. រចនាសម្ព័ន្ធ Database (Database Flow & Schema)

### Diagram ទំនាក់ទំនងតារាង (ER Diagram)
```
[ users ] (1) <---បង្រៀន---> (N) [ classes ]
   |                                 |
  (1)                               (1)
   |                                 |
  កត់វត្តមាន                       មានវត្តមាន
   |                                 |
  (N)                               (N)
   +-------------> [ attendances ] <--+
```

### តារាងសំខាន់ៗ (Tables)
1. **`users` (គណនីអ្នកប្រើប្រាស់)៖**
   * `id`, `name`, `email`, `password`, `role` (`lecturer` / `student` / `admin`), `student_code`, `staff_id`, `department`, `phone`, `avatar_url`
2. **`classes` (ថ្នាក់រៀន/មុខវិជ្ជា)៖**
   * `id`, `user_id` (ID គ្រូបង្រៀន), `subject_name`, `subject_code`, `room`, `day_of_week`, `time`, `semester`, `academic_year`, `is_qr_active`, `qr_token`
3. **`attendances` (ទិន្នន័យកត់វត្តមាន)៖**
   * `id`, `class_id` (ID ថ្នាក់), `user_id` (ID សិស្ស), `status` (`present` / `late` / `absent`), `date`, `scanned_at`, `note`

---

## ៤. ស្ថានភាពបច្ចុប្បន្ន និងជំហានបន្ទាប់ (Status & Next Steps)
* ✅ **រួចរាល់៖** Login (Auth Sanctum), Toggle QR, Student History (UI to DB), Class Attendance List (UI to DB)។
* 🎯 **ជំហានបន្ទាប់ (To-Do Next)៖**
  1. គ្រូកែប្រែ Status វត្តមានសិស្សដោយផ្ទាល់ដៃ (`PUT /api/attendances/{id}`) ចូល DB។
  2. គណនាស្ថិតិវត្តមានជាក់ស្តែងលើ Dashboard សិស្ស (មក, យឺត, អវត្តមាន)។
  3. ប្តូរពាក្យសម្ងាត់ (Change Password) និងកែប្រែព័ត៌មាន Profile ចូល DB។

