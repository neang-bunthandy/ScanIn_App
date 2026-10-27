<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\ClassModel;
use Illuminate\Http\Request;
use Carbon\Carbon;

class AttendanceController extends Controller
{
    /**
     * សិស្សស្កេនកូដ QR ដើម្បីកត់វត្តមាន (Scan Attendance)
     */
    public function scan(Request $request)
    {
        $request->validate([
            'qr_token' => 'required|string',
        ]);

        $user = $request->user();
        $qrToken = trim($request->qr_token);

        // ស្វែងរកថ្នាក់រៀនដែលមាន token ត្រូវគ្នា
        $class = ClassModel::where('qr_token', $qrToken)->first();

        if (!$class) {
            return response()->json([
                'status' => false,
                'message' => 'កូដ QR មិនត្រឹមត្រូវ ឬមិនមានក្នុងប្រព័ន្ធ!',
            ], 404);
        }

        if (!$class->is_qr_active) {
            return response()->json([
                'status' => false,
                'message' => 'QR Code នេះត្រូវបានបិទដោយគ្រូបង្រៀនរួចហើយ!',
            ], 400);
        }

        $today = Carbon::today()->toDateString();
        $now = Carbon::now();

        // ពិនិត្យមើលថាតើសិស្សបានស្កេនរួចហើយឬនៅសម្រាប់ថ្ងៃនេះ
        $attendance = Attendance::updateOrCreate(
            [
                'class_id' => $class->id,
                'user_id' => $user->id,
                'date' => $today,
            ],
            [
                'status' => 'present',
                'scanned_at' => $now,
                'note' => 'បានស្កេនតាម QR Code',
            ]
        );

        return response()->json([
            'status' => true,
            'message' => 'បានកត់វត្តមានជោគជ័យសម្រាប់ថ្នាក់ ' . $class->subject_name,
            'attendance' => [
                'id' => $attendance->id,
                'class_id' => $attendance->class_id,
                'student_id' => $user->id,
                'student_name' => $user->name,
                'student_code' => $user->student_code ?? 'STU-' . $user->id,
                'status' => $attendance->status,
                'date' => $attendance->date,
                'scanned_at' => $attendance->scanned_at?->toIso8601String(),
                'note' => $attendance->note,
            ],
        ], 200);
    }

    /**
     * ប្រវត្តិវត្តមានផ្ទាល់ខ្លួនរបស់សិស្ស (Student Attendance History)
     */
    public function studentHistory(Request $request)
    {
        $user = $request->user();

        $attendances = Attendance::with(['classModel', 'student'])
            ->where('user_id', $user->id)
            ->orderBy('date', 'desc')
            ->get()
            ->map(function ($att) {
                return [
                    'id' => $att->id,
                    'class_id' => $att->class_id,
                    'class_name' => $att->classModel?->subject_name,
                    'subject_code' => $att->classModel?->subject_code,
                    'student_id' => $att->user_id,
                    'student_name' => $att->student?->name,
                    'student_code' => $att->student?->student_code,
                    'status' => $att->status,
                    'date' => (string)$att->date,
                    'scanned_at' => $att->scanned_at?->toIso8601String(),
                    'note' => $att->note,
                ];
            });

        return response()->json([
            'status' => true,
            'message' => 'ទាញយកប្រវត្តិវត្តមានបានជោគជ័យ',
            'data' => $attendances,
        ], 200);
    }

    /**
     * បញ្ជីវត្តមានក្នុងថ្នាក់រៀនជាក់លាក់មួយ (សម្រាប់គ្រូមើល)
     */
    public function classAttendances($classId)
    {
        $attendances = Attendance::with('student')
            ->where('class_id', $classId)
            ->orderBy('date', 'desc')
            ->get()
            ->map(function ($att) {
                return [
                    'id' => $att->id,
                    'class_id' => $att->class_id,
                    'student_id' => $att->user_id,
                    'student_name' => $att->student?->name,
                    'student_code' => $att->student?->student_code,
                    'status' => $att->status,
                    'date' => (string)$att->date,
                    'scanned_at' => $att->scanned_at?->toIso8601String(),
                    'note' => $att->note,
                ];
            });

        return response()->json([
            'status' => true,
            'message' => 'ទាញយកវត្តមានក្នុងថ្នាក់បានជោគជ័យ',
            'data' => $attendances,
        ], 200);
    }
}
