<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ClassController;
use App\Http\Controllers\Api\AttendanceController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Public Routes
|--------------------------------------------------------------------------
*/
Route::post('/login', [AuthController::class, 'login']);

/*
|--------------------------------------------------------------------------
| Protected Routes (Requires Bearer Token)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/classes', [ClassController::class, 'index']);
    Route::put('/classes/{id}', [ClassController::class, 'update']);
    Route::delete('/classes/{id}', [ClassController::class, 'destroy']);
    Route::get('/classes/{id}/students', [ClassController::class, 'students']);
    Route::get('/classes/{id}/attendances', [AttendanceController::class, 'classAttendances']);
    Route::put('/attendances/{id}', [AttendanceController::class, 'update']);

// Lecturers API (Admin provisions lecturer accounts)
Route::get('/lecturers', function (Request $request) {
    if ($request->user()->role !== 'admin') {
        return response()->json([
            'status' => false,
            'message' => 'មានតែអ្នកគ្រប់គ្រង (Admin) ប៉ុណ្ណោះដែលអាចមើលបញ្ជីគ្រូបង្រៀនបាន។',
        ], 403);
    }
    $lecturers = \App\Models\User::where('role', 'lecturer')
        ->withCount('classes')
        ->select('id', 'name', 'latin_name', 'email', 'department', 'phone', 'staff_id')
        ->orderBy('id', 'desc')
        ->get();
    return response()->json(['status' => true, 'data' => $lecturers]);
});

Route::post('/lecturers', function (Request $request) {
    // ធានាសុវត្ថិភាព៖ មានតែ Admin ប៉ុណ្ណោះដែលអាចបង្កើតគណនីគ្រូបង្រៀនបាន
    if ($request->user() && $request->user()->role !== 'admin') {
        return response()->json([
            'status' => false,
            'message' => 'មានតែអ្នកគ្រប់គ្រង (Admin) ប៉ុណ្ណោះដែលអាចបង្កើតគណនីគ្រូបង្រៀនបាន។',
        ], 403);
    }

    $request->validate([
        'name' => 'required|string|max:255',
        'latin_name' => 'nullable|string|max:255',
        'email' => 'required|email|unique:users,email',
        'password' => 'required|string|min:6',
        'department' => 'nullable|string|max:255',
        'staff_id' => 'nullable|string|max:50',
        'phone' => 'nullable|string|max:50',
    ]);

    $lecturer = \App\Models\User::create([
        'name' => trim($request->name),
        'latin_name' => $request->filled('latin_name') ? trim($request->latin_name) : null,
        'email' => strtolower(trim($request->email)),
        'password' => \Illuminate\Support\Facades\Hash::make($request->password),
        'role' => 'lecturer',
        'department' => $request->department,
        'staff_id' => $request->staff_id,
        'phone' => $request->phone,
    ]);

    return response()->json([
        'status' => true,
        'message' => 'បានបង្កើតគណនីគ្រូបង្រៀនដោយជោគជ័យ',
        'data' => $lecturer,
    ], 201);
});

Route::put('/lecturers/{id}', function (Request $request, $id) {
    if ($request->user() && $request->user()->role !== 'admin') {
        return response()->json([
            'status' => false,
            'message' => 'មានតែអ្នកគ្រប់គ្រង (Admin) ប៉ុណ្ណោះដែលអាចកែប្រែគណនីគ្រូបង្រៀនបាន។',
        ], 403);
    }

    $lecturer = \App\Models\User::where('role', 'lecturer')->find($id);
    if (!$lecturer) {
        return response()->json([
            'status' => false,
            'message' => 'រកមិនឃើញគណនីគ្រូបង្រៀននេះទេ',
        ], 404);
    }

    $request->validate([
        'name' => 'sometimes|required|string|max:255',
        'latin_name' => 'nullable|string|max:255',
        'email' => 'sometimes|required|email|unique:users,email,' . $id,
        'password' => 'nullable|string|min:6',
        'department' => 'nullable|string|max:255',
        'staff_id' => 'nullable|string|max:50',
        'phone' => 'nullable|string|max:50',
    ]);

    if ($request->filled('name')) $lecturer->name = trim($request->name);
    if ($request->has('latin_name')) $lecturer->latin_name = $request->filled('latin_name') ? trim($request->latin_name) : null;
    if ($request->filled('email')) $lecturer->email = strtolower(trim($request->email));
    if ($request->filled('password')) $lecturer->password = \Illuminate\Support\Facades\Hash::make($request->password);
    if ($request->has('department')) $lecturer->department = $request->department;
    if ($request->has('staff_id')) $lecturer->staff_id = $request->staff_id;
    if ($request->has('phone')) $lecturer->phone = $request->phone;

    $lecturer->save();

    return response()->json([
        'status' => true,
        'message' => 'បានកែប្រែគណនីគ្រូបង្រៀនដោយជោគជ័យ',
        'data' => $lecturer,
    ]);
});

Route::delete('/lecturers/{id}', function (Request $request, $id) {
    if ($request->user() && $request->user()->role !== 'admin') {
        return response()->json([
            'status' => false,
            'message' => 'មានតែអ្នកគ្រប់គ្រង (Admin) ប៉ុណ្ណោះដែលអាចលុបគណនីគ្រូបង្រៀនបាន។',
        ], 403);
    }

    $lecturer = \App\Models\User::where('role', 'lecturer')->find($id);
    if (!$lecturer) {
        return response()->json([
            'status' => false,
            'message' => 'រកមិនឃើញគណនីគ្រូបង្រៀននេះទេ',
        ], 404);
    }

    // ដោះដូរគ្រូបង្រៀនចេញពីថ្នាក់រៀន
    \App\Models\ClassModel::where('user_id', $id)->update(['user_id' => null]);
    $lecturer->delete();

    return response()->json([
        'status' => true,
        'message' => 'បានលុបគណនីគ្រូបង្រៀនដោយជោគជ័យ',
    ]);
});

// Students API (Admin provisions student accounts)
Route::get('/students', function (Request $request) {
    if ($request->user()->role !== 'admin') {
        return response()->json([
            'status' => false,
            'message' => 'មានតែអ្នកគ្រប់គ្រង (Admin) ប៉ុណ្ណោះដែលអាចមើលបញ្ជីសិស្សបាន។',
        ], 403);
    }
    $studentsQuery = \App\Models\User::where('role', 'student')
        ->select('id', 'name', 'latin_name', 'email', 'student_code', 'gender', 'date_of_birth', 'department', 'generation', 'intake_year', 'year_level', 'phone', 'created_at');

    if ($request->filled('department')) {
        $studentsQuery->where('department', trim($request->department));
    }
    if ($request->filled('generation')) {
        $studentsQuery->where('generation', trim($request->generation));
    }
    if ($request->filled('intake_year')) {
        $studentsQuery->where('intake_year', trim($request->intake_year));
    }
    if ($request->filled('year_level')) {
        $studentsQuery->where('year_level', (int)$request->year_level);
    }

    $students = $studentsQuery->orderBy('id', 'desc')->get();
    return response()->json(['status' => true, 'data' => $students]);
});

Route::post('/students', function (Request $request) {
    // ធានាសុវត្ថិភាព៖ មានតែ Admin ប៉ុណ្ណោះដែលអាចបង្កើតគណនីសិស្សបាន
    if ($request->user() && $request->user()->role !== 'admin') {
        return response()->json([
            'status' => false,
            'message' => 'មានតែអ្នកគ្រប់គ្រង (Admin) ប៉ុណ្ណោះដែលអាចបង្កើតគណនីសិស្សបាន។',
        ], 403);
    }

    $request->validate([
        'name' => 'required|string|max:255',
        'latin_name' => 'nullable|string|max:255',
        'email' => 'required|email|unique:users,email',
        'password' => 'required|string|min:6',
        'student_code' => 'required|string|max:50|unique:users,student_code',
        'gender' => 'nullable|string|max:20',
        'date_of_birth' => 'nullable|date',
        'department' => 'nullable|string|max:255',
        'generation' => 'nullable|string|max:255',
        'intake_year' => 'nullable|string|max:20',
        'year_level' => 'nullable|integer|min:1|max:6',
        'phone' => 'nullable|string|max:50',
    ]);

    $student = \App\Models\User::create([
        'name' => trim($request->name),
        'latin_name' => $request->filled('latin_name') ? trim($request->latin_name) : null,
        'email' => strtolower(trim($request->email)),
        'password' => \Illuminate\Support\Facades\Hash::make($request->password),
        'role' => 'student',
        'student_code' => strtoupper(trim($request->student_code)),
        'gender' => $request->gender,
        'date_of_birth' => $request->date_of_birth,
        'department' => $request->department,
        'generation' => $request->filled('generation') ? trim($request->generation) : null,
        'intake_year' => $request->filled('intake_year') ? trim($request->intake_year) : null,
        'year_level' => $request->filled('year_level') ? (int)$request->year_level : null,
        'phone' => $request->phone,
    ]);

    return response()->json([
        'status' => true,
        'message' => 'បានបង្កើតគណនីសិស្សដោយជោគជ័យ',
        'data' => $student,
    ], 201);
});

// Import Students in Bulk (from Excel / CSV or JSON)
Route::post('/students/import', function (Request $request) {
    if ($request->user() && $request->user()->role !== 'admin') {
        return response()->json([
            'status' => false,
            'message' => 'មានតែអ្នកគ្រប់គ្រង (Admin) ប៉ុណ្ណោះដែលអាច Import បញ្ជីសិស្សបាន។',
        ], 403);
    }

    $rows = [];
    if ($request->hasFile('file')) {
        $file = $request->file('file');
        $handle = fopen($file->getRealPath(), 'r');
        $header = null;
        while (($row = fgetcsv($handle, 1000, ',')) !== false) {
            if (!$header) {
                $header = array_map(function($h) { return strtolower(trim(str_replace(' ', '_', $h))); }, $row);
            } else {
                if (count($row) === count($header)) {
                    $rows[] = array_combine($header, $row);
                }
            }
        }
        fclose($handle);
    } elseif ($request->has('students') && is_array($request->students)) {
        $rows = $request->students;
    } else {
        return response()->json([
            'status' => false,
            'message' => 'សូមផ្ញើ File CSV ឬបញ្ជី JSON សិស្សដែលត្រូវ Import!',
        ], 422);
    }

    if (empty($rows)) {
        return response()->json([
            'status' => false,
            'message' => 'មិនមានទិន្នន័យសិស្សក្នុង File សម្រាប់ Import ឡើយ!',
        ], 422);
    }

    $imported = 0;
    $skipped = 0;
    $errors = [];

    foreach ($rows as $index => $row) {
        $studentCode = strtoupper(trim($row['student_code'] ?? $row['code'] ?? $row['id'] ?? ''));
        $name = trim($row['name'] ?? $row['khmer_name'] ?? $row['full_name'] ?? '');
        $latinName = trim($row['latin_name'] ?? $row['english_name'] ?? $row['romanized_name'] ?? '');
        $email = strtolower(trim($row['email'] ?? ''));
        $gender = trim($row['gender'] ?? $row['sex'] ?? '');
        $dob = trim($row['date_of_birth'] ?? $row['dob'] ?? '');
        $dept = trim($row['department'] ?? $row['major'] ?? 'General');
        $generation = trim($row['generation'] ?? $row['batch'] ?? '');
        $intakeYear = trim($row['intake_year'] ?? $row['start_year'] ?? '');
        $yearLevelRaw = $row['year_level'] ?? $row['year'] ?? null;
        $yearLevel = is_numeric($yearLevelRaw) ? (int)$yearLevelRaw : null;
        $phone = trim($row['phone'] ?? $row['tel'] ?? '');
        $password = !empty($row['password']) ? $row['password'] : 'password123';

        if (empty($studentCode) || empty($name)) {
            $skipped++;
            continue;
        }

        if (empty($email)) {
            $email = strtolower($studentCode) . '@student.scanin.app';
        }

        $exists = \App\Models\User::where('email', $email)
            ->orWhere('student_code', $studentCode)
            ->exists();

        if ($exists) {
            $skipped++;
            continue;
        }

        try {
            \App\Models\User::create([
                'name' => $name,
                'latin_name' => $latinName ?: null,
                'email' => $email,
                'student_code' => $studentCode,
                'password' => \Illuminate\Support\Facades\Hash::make($password),
                'role' => 'student',
                'gender' => $gender ?: null,
                'date_of_birth' => !empty($dob) ? date('Y-m-d', strtotime($dob)) : null,
                'department' => $dept ?: null,
                'generation' => $generation ?: null,
                'intake_year' => $intakeYear ?: null,
                'year_level' => $yearLevel,
                'phone' => $phone ?: null,
            ]);
            $imported++;
        } catch (\Exception $e) {
            $skipped++;
            $errors[] = "Row $index ($studentCode): " . $e->getMessage();
        }
    }

    return response()->json([
        'status' => true,
        'message' => "បាន Import សិស្សដោយជោគជ័យចំនួន $imported នាក់ (រំលង $skipped នាក់)",
        'imported_count' => $imported,
        'skipped_count' => $skipped,
        'errors' => $errors,
    ], 200);
});

Route::put('/students/{id}', function (Request $request, $id) {
    if ($request->user() && $request->user()->role !== 'admin') {
        return response()->json([
            'status' => false,
            'message' => 'មានតែអ្នកគ្រប់គ្រង (Admin) ប៉ុណ្ណោះដែលអាចកែប្រែគណនីសិស្សបាន។',
        ], 403);
    }

    $student = \App\Models\User::where('role', 'student')->find($id);
    if (!$student) {
        return response()->json([
            'status' => false,
            'message' => 'រកមិនឃើញគណនីសិស្សនេះទេ',
        ], 404);
    }

    $request->validate([
        'name' => 'sometimes|required|string|max:255',
        'latin_name' => 'nullable|string|max:255',
        'email' => 'sometimes|required|email|unique:users,email,' . $id,
        'student_code' => 'sometimes|required|string|max:50|unique:users,student_code,' . $id,
        'password' => 'nullable|string|min:6',
        'gender' => 'nullable|string|max:20',
        'date_of_birth' => 'nullable|date',
        'department' => 'nullable|string|max:255',
        'generation' => 'nullable|string|max:255',
        'intake_year' => 'nullable|string|max:20',
        'year_level' => 'nullable|integer|min:1|max:6',
        'phone' => 'nullable|string|max:50',
    ]);

    if ($request->filled('name')) $student->name = trim($request->name);
    if ($request->has('latin_name')) $student->latin_name = $request->filled('latin_name') ? trim($request->latin_name) : null;
    if ($request->filled('email')) $student->email = strtolower(trim($request->email));
    if ($request->filled('student_code')) $student->student_code = strtoupper(trim($request->student_code));
    if ($request->filled('password')) $student->password = \Illuminate\Support\Facades\Hash::make($request->password);
    if ($request->has('gender')) $student->gender = $request->gender;
    if ($request->has('date_of_birth')) $student->date_of_birth = $request->date_of_birth;
    if ($request->has('department')) $student->department = $request->department;
    if ($request->has('generation')) $student->generation = $request->filled('generation') ? trim($request->generation) : null;
    if ($request->has('intake_year')) $student->intake_year = $request->filled('intake_year') ? trim($request->intake_year) : null;
    if ($request->has('year_level')) $student->year_level = $request->filled('year_level') ? (int)$request->year_level : null;
    if ($request->has('phone')) $student->phone = $request->phone;

    $student->save();

    return response()->json([
        'status' => true,
        'message' => 'បានកែប្រែគណនីសិស្សដោយជោគជ័យ',
        'data' => $student,
    ]);
});

// ដំឡើងឆ្នាំសិក្សាសិស្សតាមជំនាន់ ឬទូទាំងប្រព័ន្ធ (Promote Students Year Level - Admin Only)
Route::post('/students/promote', function (Request $request) {
    if ($request->user() && $request->user()->role !== 'admin') {
        return response()->json([
            'status' => false,
            'message' => 'មានតែអ្នកគ្រប់គ្រង (Admin) ប៉ុណ្ណោះដែលអាចដំឡើងឆ្នាំសិក្សាសិស្សបាន។',
        ], 403);
    }

    $query = \App\Models\User::where('role', 'student')
        ->whereNotNull('year_level')
        ->where('year_level', '<', 4);

    if ($request->filled('generation')) {
        $query->where('generation', trim($request->generation));
    }
    if ($request->filled('intake_year')) {
        $query->where('intake_year', trim($request->intake_year));
    }
    if ($request->filled('department')) {
        $query->where('department', trim($request->department));
    }
    if ($request->filled('from_year_level')) {
        $query->where('year_level', (int)$request->from_year_level);
    }

    $promoted = $query->increment('year_level');

    return response()->json([
        'status' => true,
        'message' => "បានដំឡើងឆ្នាំសិក្សាឱ្យនិស្សិតចំនួន $promoted នាក់ដោយជោគជ័យ!",
        'promoted_count' => $promoted,
    ], 200);
});

Route::delete('/students/{id}', function (Request $request, $id) {
    if ($request->user() && $request->user()->role !== 'admin') {
        return response()->json([
            'status' => false,
            'message' => 'មានតែអ្នកគ្រប់គ្រង (Admin) ប៉ុណ្ណោះដែលអាចលុបគណនីសិស្សបាន។',
        ], 403);
    }

    $student = \App\Models\User::where('role', 'student')->find($id);
    if (!$student) {
        return response()->json([
            'status' => false,
            'message' => 'រកមិនឃើញគណនីសិស្សនេះទេ',
        ], 404);
    }

    // លុបកំណត់ត្រាវត្តមានទាំងអស់របស់សិស្សនេះ
    \App\Models\Attendance::where('user_id', $id)->delete();
    $student->delete();

    return response()->json([
        'status' => true,
        'message' => 'បានលុបគណនីសិស្សដោយជោគជ័យ',
    ]);
});

    // Auth & Student / Lecturer Protected Routes
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/user/change-password', [AuthController::class, 'changePassword']);
    Route::get('/student/classes', [ClassController::class, 'index']);

    // Class routes
    Route::post('/classes', [ClassController::class, 'store']);
    Route::post('/classes/{id}/toggle-qr', [ClassController::class, 'toggleQr']);

    // Attendance routes for students
    Route::post('/attendances/scan', [AttendanceController::class, 'scan']);
    Route::get('/student/attendances', [AttendanceController::class, 'studentHistory']);
});
