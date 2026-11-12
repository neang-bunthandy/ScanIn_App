<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ClassModel;
use Illuminate\Http\Request;

class ClassController extends Controller
{
    /**
     * បង្ហាញបញ្ជីថ្នាក់រៀនទាំងអស់ (Get list of classes)
     */
    public function index(Request $request)
    {
        $query = ClassModel::with('lecturer');
        $user = $request->user();

        // បើមាន User Login និងជាគ្រូ Filter យកតែថ្នាក់របស់គាត់
        if ($user && $user->role === 'lecturer') {
            $query->where('user_id', $user->id);
        } elseif ($user && $user->role === 'student') {
            $studentStatus = strtolower(trim((string)($user->status ?? 'active')));
            // សិស្សម្នាក់ៗឃើញតែថ្នាក់រៀនតាម ដេប៉ាតឺម៉ង់ + ឆ្នាំទី (1-4) + ជំនាន់ និងត្រូវតែមានស្ថានភាព active
            $dept = trim((string)($user->department ?? ''));
            if ($dept !== '' && $studentStatus === 'active') {
                $query->where('department', $dept);

                $studentYearLevel = (int)($user->year_level ?? 0);
                if ($studentYearLevel > 0) {
                    $query->where(function ($q) use ($studentYearLevel) {
                        $q->whereNull('year_level')
                          ->orWhere('year_level', $studentYearLevel);
                    });
                } else {
                    $query->whereNull('year_level');
                }

                $studentGen = trim((string)($user->generation ?? ''));
                if ($studentGen !== '') {
                    $query->where(function ($q) use ($studentGen) {
                        $q->whereNull('generation')
                          ->orWhere('generation', '')
                          ->orWhere('generation', $studentGen);
                    });
                } else {
                    $query->where(function ($q) {
                        $q->whereNull('generation')
                          ->orWhere('generation', '');
                    });
                }
            } else {
                $query->whereRaw('1 = 0');
            }
        }

        // ទាញសិស្សកំពុងសិក្សា (active) ដើម្បីគណនាចំនួនសិស្សពិតប្រាកដតាម ដេប៉ាតឺម៉ង់ + ឆ្នាំទី + ជំនាន់
        $allStudents = \App\Models\User::where('role', 'student')
            ->whereNotNull('department')
            ->where(function ($q) {
                $q->whereNull('status')
                  ->orWhere('status', 'active');
            })
            ->select('department', 'year_level', 'generation')
            ->get();

        // គណនាចំនួនថ្ងៃ/សប្តាហ៍ដែលបានស្កេនវត្តមានពិតប្រាកដក្នុង DB សម្រាប់ថ្នាក់នីមួយៗ
        $sessionCounts = \App\Models\Attendance::selectRaw('class_id, COUNT(DISTINCT date) as total_days')
            ->groupBy('class_id')
            ->pluck('total_days', 'class_id');

        $classes = $query->orderBy('id', 'desc')->get()->map(function ($c) use ($allStudents, $sessionCounts) {
            $realStudentCount = 0;
            if (!empty($c->department)) {
                $classDept = trim((string)$c->department);
                $classYear = $c->year_level !== null ? (int)$c->year_level : null;
                $classGen = trim((string)($c->generation ?? ''));

                $realStudentCount = $allStudents->filter(function ($s) use ($classDept, $classYear, $classGen) {
                    if (trim((string)$s->department) !== $classDept) return false;
                    if ($classYear !== null && (int)($s->year_level ?? 0) !== $classYear) return false;
                    if ($classGen !== '' && trim((string)($s->generation ?? '')) !== $classGen) return false;
                    return true;
                })->count();
            }

            $realCompletedSessions = max(
                (int)($c->completed_sessions ?? 0),
                (int)($sessionCounts[$c->id] ?? 0)
            );

            return [
                'id' => $c->id,
                'lecturer_id' => $c->user_id,
                'lecturer_name' => $c->lecturer?->name,
                'lecturer_latin_name' => $c->lecturer?->latin_name,
                'teacher_email' => $c->lecturer?->email,
                'teacher_phone' => $c->lecturer?->phone,
                'subject_name' => $c->subject_name,
                'subject_code' => $c->subject_code,
                'department' => $c->department,
                'generation' => $c->generation,
                'year_level' => $c->year_level !== null ? (int)$c->year_level : null,
                'room' => $c->room,
                'day_of_week' => $c->day_of_week,
                'time' => $c->time,
                'semester' => $c->semester,
                'academic_year' => $c->academic_year,
                'student_count' => $realStudentCount,
                'completed_sessions' => $realCompletedSessions,
                'total_sessions' => (int)($c->total_sessions ?: 15),
                'description' => $c->description,
                'is_qr_active' => (bool)$c->is_qr_active,
                'qr_token' => $c->qr_token,
                'created_at' => $c->created_at,
            ];
        });

        return response()->json([
            'status' => true,
            'message' => 'ទាញយកបញ្ជីថ្នាក់រៀនបានជោគជ័យ',
            'data' => $classes,
        ], 200);
    }

    /**
     * បង្កើតថ្នាក់រៀនថ្មី (Create New Class - Admin Only)
     */
    public function store(Request $request)
    {
        // ធានាសុវត្ថិភាព៖ មានតែ Admin ប៉ុណ្ណោះដែលអាចបង្កើតថ្នាក់រៀនបាន គ្រូមិនអាចបង្កើតបានទេ
        if ($request->user() && $request->user()->role !== 'admin') {
            return response()->json([
                'status' => false,
                'message' => 'មានតែអ្នកគ្រប់គ្រង (Admin) ប៉ុណ្ណោះដែលអាចបង្កើតថ្នាក់រៀនបាន។ គ្រូមិនមានសិទ្ធិនេះឡើយ។',
            ], 403);
        }

        $request->validate([
            'subject_name' => 'required|string|max:255',
            'subject_code' => 'required|string|max:50',
            'department' => 'nullable|string|max:255',
            'generation' => 'nullable|string|max:255',
            'year_level' => 'nullable|integer|min:1|max:6',
            'lecturer_id' => 'nullable|exists:users,id',
            'room' => 'nullable|string|max:100',
            'day_of_week' => 'nullable|string|max:50',
            'time' => 'nullable|string|max:100',
            'semester' => 'nullable|string|max:50',
            'academic_year' => 'nullable|string|max:50',
            'student_count' => 'nullable|integer',
            'completed_sessions' => 'nullable|integer|min:0|max:60',
            'total_sessions' => 'nullable|integer|min:1|max:60',
            'description' => 'nullable|string',
            'is_qr_active' => 'nullable|boolean',
            'qr_token' => 'nullable|string',
        ]);

        // ប្រសិនបើ Admin ជាអ្នកបង្កើត និងបានជ្រើសរើសគ្រូ យក lecturer_id
        $userId = $request->input('lecturer_id') ?? $request->user()?->id ?? 1;
        $department = $request->filled('department')
            ? trim($request->department)
            : \App\Models\User::find($userId)?->department;

        $code = strtoupper(trim($request->subject_code));
        $qrToken = $request->qr_token ?? ('SCANIN-' . $code . '-' . date('Y'));

        $class = ClassModel::create([
            'user_id' => $userId,
            'subject_name' => $request->subject_name,
            'subject_code' => $code,
            'department' => $department,
            'generation' => $request->filled('generation') ? trim($request->generation) : null,
            'year_level' => $request->filled('year_level') ? (int)$request->year_level : null,
            'room' => $request->room,
            'day_of_week' => $request->day_of_week,
            'time' => $request->time,
            'semester' => $request->semester ?? '1',
            'academic_year' => $request->academic_year ?? date('Y'),
            'student_count' => $request->student_count ?? 0,
            'completed_sessions' => $request->input('completed_sessions') ?? 0,
            'total_sessions' => $request->input('total_sessions') ?: 15,
            'description' => $request->description,
            'is_qr_active' => $request->is_qr_active ?? false,
            'qr_token' => $qrToken,
        ]);

        return response()->json([
            'status' => true,
            'message' => 'បានបង្កើតថ្នាក់រៀន និងចាត់តាំងគ្រូបង្រៀនដោយជោគជ័យ',
            'data' => $class,
        ], 201);
    }

    /**
     * បង្ហាញព័ត៌មានលម្អិតនៃថ្នាក់រៀន (Class Detail)
     */
    public function show(Request $request, $id)
    {
        $class = ClassModel::with('lecturer')->find($id);

        if (!$class) {
            return response()->json([
                'status' => false,
                'message' => 'រកមិនឃើញថ្នាក់រៀននេះទេ',
            ], 404);
        }

        if ($request->user() && $request->user()->role === 'lecturer' && (int)$class->user_id !== (int)$request->user()->id) {
            return response()->json([
                'status' => false,
                'message' => 'អ្នកគ្មានសិទ្ធិមើលថ្នាក់រៀនរបស់គ្រូផ្សេងឡើយ។',
            ], 403);
        }

        return response()->json([
            'status' => true,
            'data' => $class,
        ], 200);
    }

    /**
     * បើក / បិទ QR Code សម្រាប់ថ្នាក់រៀន (Toggle QR Code)
     */
    public function toggleQr(Request $request, $id)
    {
        $class = ClassModel::find($id);

        if (!$class) {
            return response()->json([
                'status' => false,
                'message' => 'រកមិនឃើញថ្នាក់រៀននេះទេ',
            ], 404);
        }

        if ($request->user() && $request->user()->role === 'lecturer' && (int)$class->user_id !== (int)$request->user()->id) {
            return response()->json([
                'status' => false,
                'message' => 'អ្នកគ្មានសិទ្ធិបើក/បិទ QR សម្រាប់ថ្នាក់របស់គ្រូផ្សេងឡើយ។',
            ], 403);
        }

        $request->validate([
            'is_qr_active' => 'required|boolean',
            'qr_token' => 'nullable|string',
        ]);

        $class->is_qr_active = $request->is_qr_active;

        if ($request->filled('qr_token')) {
            $class->qr_token = $request->qr_token;
        }

        $class->save();

        return response()->json([
            'status' => true,
            'message' => $class->is_qr_active ? 'បានបើកដំណើរការ QR Code ជោគជ័យ' : 'បានបិទដំណើរការ QR Code ជោគជ័យ',
            'is_qr_active' => $class->is_qr_active,
            'qr_token' => $class->qr_token,
        ], 200);
    }

    /**
     * កែសម្រួលព័ត៌មានថ្នាក់រៀន (Update Class - Admin Only)
     */
    public function update(Request $request, $id)
    {
        if ($request->user() && $request->user()->role !== 'admin') {
            return response()->json([
                'status' => false,
                'message' => 'មានតែអ្នកគ្រប់គ្រង (Admin) ប៉ុណ្ណោះដែលអាចកែប្រែថ្នាក់រៀនបាន។',
            ], 403);
        }

        $class = ClassModel::find($id);
        if (!$class) {
            return response()->json([
                'status' => false,
                'message' => 'រកមិនឃើញថ្នាក់រៀននេះទេ',
            ], 404);
        }

        $request->validate([
            'subject_name' => 'sometimes|required|string|max:255',
            'subject_code' => 'sometimes|required|string|max:50',
            'department' => 'nullable|string|max:255',
            'generation' => 'nullable|string|max:255',
            'year_level' => 'nullable|integer|min:1|max:6',
            'lecturer_id' => 'nullable|exists:users,id',
            'room' => 'nullable|string|max:100',
            'day_of_week' => 'nullable|string|max:50',
            'time' => 'nullable|string|max:100',
            'semester' => 'nullable|string|max:50',
            'academic_year' => 'nullable|string|max:50',
            'student_count' => 'nullable|integer',
            'completed_sessions' => 'nullable|integer|min:0|max:60',
            'total_sessions' => 'nullable|integer|min:1|max:60',
            'description' => 'nullable|string',
        ]);

        if ($request->filled('subject_name')) $class->subject_name = $request->subject_name;
        if ($request->filled('subject_code')) $class->subject_code = strtoupper(trim($request->subject_code));
        if ($request->has('department')) $class->department = $request->filled('department') ? trim($request->department) : null;
        if ($request->has('generation')) $class->generation = $request->filled('generation') ? trim($request->generation) : null;
        if ($request->has('year_level')) $class->year_level = $request->filled('year_level') ? (int)$request->year_level : null;
        if ($request->has('lecturer_id') && $request->lecturer_id) $class->user_id = $request->lecturer_id;
        if ($request->has('room')) $class->room = $request->room;
        if ($request->has('day_of_week')) $class->day_of_week = $request->day_of_week;
        if ($request->has('time')) $class->time = $request->time;
        if ($request->has('semester')) $class->semester = $request->semester;
        if ($request->has('academic_year')) $class->academic_year = $request->academic_year;
        if ($request->has('student_count')) $class->student_count = $request->student_count;
        if ($request->has('completed_sessions') && $request->completed_sessions !== null) $class->completed_sessions = $request->completed_sessions;
        if ($request->has('total_sessions') && $request->total_sessions !== null) $class->total_sessions = $request->total_sessions;
        if ($request->has('description')) $class->description = $request->description;

        $class->save();

        return response()->json([
            'status' => true,
            'message' => 'បានកែសម្រួលព័ត៌មានថ្នាក់រៀនដោយជោគជ័យ',
            'data' => $class,
        ], 200);
    }

    /**
     * លុបថ្នាក់រៀន (Delete Class - Admin Only)
     */
    public function destroy(Request $request, $id)
    {
        if ($request->user() && $request->user()->role !== 'admin') {
            return response()->json([
                'status' => false,
                'message' => 'មានតែអ្នកគ្រប់គ្រង (Admin) ប៉ុណ្ណោះដែលអាចលុបថ្នាក់រៀនបាន។',
            ], 403);
        }

        $class = ClassModel::find($id);
        if (!$class) {
            return response()->json([
                'status' => false,
                'message' => 'រកមិនឃើញថ្នាក់រៀននេះទេ',
            ], 404);
        }

        // លុបកំណត់ត្រាវត្តមានដែលពាក់ព័ន្ធនឹងថ្នាក់នេះ
        \App\Models\Attendance::where('class_id', $id)->delete();
        $class->delete();

        return response()->json([
            'status' => true,
            'message' => 'បានលុបថ្នាក់រៀនដោយជោគជ័យ',
        ], 200);
    }

    /**
     * ទាញយកបញ្ជីឈ្មោះនិស្សិតក្នុងថ្នាក់រៀនតាមដេប៉ាតឺម៉ង់ (Class Roster - DB)
     */
    public function students(Request $request, $id)
    {
        $class = ClassModel::find($id);
        if (!$class) {
            return response()->json([
                'status' => false,
                'message' => 'រកមិនឃើញថ្នាក់រៀននេះទេ',
            ], 404);
        }

        $user = $request->user();
        if ($user && $user->role === 'student') {
            return response()->json([
                'status' => false,
                'message' => 'សិស្សមិនមានសិទ្ធិមើលបញ្ជីឈ្មោះសិស្សទាំងអស់ក្នុងថ្នាក់ឡើយ។',
            ], 403);
        }
        if ($user && $user->role === 'lecturer' && (int)$class->user_id !== (int)$user->id) {
            return response()->json([
                'status' => false,
                'message' => 'អ្នកគ្មានសិទ្ធិមើលបញ្ជីសិស្សក្នុងថ្នាក់របស់គ្រូផ្សេងឡើយ។',
            ], 403);
        }

        if (empty($class->department)) {
            return response()->json([
                'status' => true,
                'message' => 'ថ្នាក់នេះមិនទាន់បានកំណត់ដេប៉ាតឺម៉ង់នៅឡើយទេ',
                'data' => [],
            ], 200);
        }

        $today = \Carbon\Carbon::today()->toDateString();
        $todayAtts = \App\Models\Attendance::where('class_id', $class->id)
            ->where('date', $today)
            ->get()
            ->keyBy('user_id');

        $studentsQuery = \App\Models\User::where('role', 'student')
            ->where('department', $class->department)
            ->where(function ($q) {
                $q->whereNull('status')
                  ->orWhere('status', 'active');
            });

        if ($class->year_level !== null) {
            $studentsQuery->where('year_level', (int)$class->year_level);
        }
        if (!empty($class->generation)) {
            $studentsQuery->where('generation', trim((string)$class->generation));
        }

        $students = $studentsQuery
            ->orderBy('student_code')
            ->get()
            ->map(function ($s) use ($todayAtts) {
                $att = $todayAtts->get($s->id);
                return [
                    'id' => $s->id,
                    'name' => $s->name,
                    'latin_name' => $s->latin_name,
                    'email' => $s->email,
                    'role' => $s->role,
                    'student_code' => $s->student_code,
                    'department' => $s->department,
                    'generation' => $s->generation,
                    'intake_year' => $s->intake_year,
                    'year_level' => $s->year_level !== null ? (int)$s->year_level : null,
                    'status' => $s->status ?? 'active',
                    'phone' => $s->phone,
                    'gender' => $s->gender,
                    'date_of_birth' => $s->date_of_birth,
                    'avatar_url' => $s->avatar_url,
                    'today_status' => $att?->status,
                    'today_scanned_at' => $att?->scanned_at?->toIso8601String(),
                ];
            });

        return response()->json([
            'status' => true,
            'message' => 'ទាញយកបញ្ជីឈ្មោះសិស្សក្នុងថ្នាក់បានជោគជ័យ',
            'data' => $students,
        ], 200);
    }
}
