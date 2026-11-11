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

        // បើមាន User Login និងជាគ្រូ អាច filter យកតែថ្នាក់របស់គាត់
        if ($request->user() && $request->user()->role === 'lecturer') {
            $query->where('user_id', $request->user()->id);
        }

        $classes = $query->orderBy('id', 'desc')->get()->map(function ($c) {
            return [
                'id' => $c->id,
                'lecturer_id' => $c->user_id,
                'lecturer_name' => $c->lecturer?->name,
                'teacher_email' => $c->lecturer?->email,
                'teacher_phone' => $c->lecturer?->phone,
                'subject_name' => $c->subject_name,
                'subject_code' => $c->subject_code,
                'room' => $c->room,
                'day_of_week' => $c->day_of_week,
                'time' => $c->time,
                'semester' => $c->semester,
                'academic_year' => $c->academic_year,
                'student_count' => $c->student_count,
                'completed_sessions' => $c->completed_sessions,
                'total_sessions' => $c->total_sessions,
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
            'lecturer_id' => 'nullable|exists:users,id',
            'room' => 'nullable|string|max:100',
            'day_of_week' => 'nullable|string|max:50',
            'time' => 'nullable|string|max:100',
            'semester' => 'nullable|string|max:50',
            'academic_year' => 'nullable|string|max:50',
            'student_count' => 'nullable|integer',
            'total_sessions' => 'nullable|integer',
            'description' => 'nullable|string',
            'is_qr_active' => 'nullable|boolean',
            'qr_token' => 'nullable|string',
        ]);

        // ប្រសិនបើ Admin ជាអ្នកបង្កើត និងបានជ្រើសរើសគ្រូ យក lecturer_id
        $userId = $request->input('lecturer_id') ?? $request->user()?->id ?? 1;

        $code = strtoupper(trim($request->subject_code));
        $qrToken = $request->qr_token ?? ('SCANIN-' . $code . '-' . date('Y'));

        $class = ClassModel::create([
            'user_id' => $userId,
            'subject_name' => $request->subject_name,
            'subject_code' => $code,
            'room' => $request->room,
            'day_of_week' => $request->day_of_week,
            'time' => $request->time,
            'semester' => $request->semester ?? '1',
            'academic_year' => $request->academic_year ?? date('Y'),
            'student_count' => $request->student_count ?? 0,
            'total_sessions' => $request->total_sessions ?? 15,
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
    public function show($id)
    {
        $class = ClassModel::with('lecturer')->find($id);

        if (!$class) {
            return response()->json([
                'status' => false,
                'message' => 'រកមិនឃើញថ្នាក់រៀននេះទេ',
            ], 404);
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
            'lecturer_id' => 'nullable|exists:users,id',
            'room' => 'nullable|string|max:100',
            'day_of_week' => 'nullable|string|max:50',
            'time' => 'nullable|string|max:100',
            'semester' => 'nullable|string|max:50',
            'academic_year' => 'nullable|string|max:50',
            'student_count' => 'nullable|integer',
            'total_sessions' => 'nullable|integer',
            'description' => 'nullable|string',
        ]);

        if ($request->filled('subject_name')) $class->subject_name = $request->subject_name;
        if ($request->filled('subject_code')) $class->subject_code = strtoupper(trim($request->subject_code));
        if ($request->has('lecturer_id') && $request->lecturer_id) $class->user_id = $request->lecturer_id;
        if ($request->has('room')) $class->room = $request->room;
        if ($request->has('day_of_week')) $class->day_of_week = $request->day_of_week;
        if ($request->has('time')) $class->time = $request->time;
        if ($request->has('semester')) $class->semester = $request->semester;
        if ($request->has('academic_year')) $class->academic_year = $request->academic_year;
        if ($request->has('student_count')) $class->student_count = $request->student_count;
        if ($request->has('total_sessions')) $class->total_sessions = $request->total_sessions;
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
}
