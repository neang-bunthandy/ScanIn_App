<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\CampusSetting;
use App\Models\ClassModel;
use Illuminate\Http\Request;
use Carbon\Carbon;

class AttendanceController extends Controller
{
    /**
     * សិស្សស្កេនកូដ QR ដើម្បីកត់វត្តមាន (Scan Attendance + GPS Geofencing)
     */
    public function scan(Request $request)
    {
        $request->validate([
            'qr_token' => 'required|string',
            'latitude' => 'nullable|numeric|between:-90,90',
            'longitude' => 'nullable|numeric|between:-180,180',
            'is_mocked' => 'nullable|boolean',
        ]);

        // ១. ការពារកម្មវិធីបន្លំទីតាំង (Anti-Fake GPS / Mock Location)
        if ($request->boolean('is_mocked')) {
            return response()->json([
                'status' => false,
                'message' => 'រកឃើញការប្រើប្រាស់កម្មវិធីបន្លំទីតាំង (Fake GPS)! មិនអាចកត់វត្តមានបានឡើយ។',
            ], 403);
        }

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

        // ពិនិត្យស្ថានភាពសិស្ស (អនុញ្ញាតតែសិស្សកំពុងសិក្សា 'active' ប៉ុណ្ណោះ)
        $studentStatus = strtolower(trim((string)($user->status ?? 'active')));
        if ($user->role === 'student' && $studentStatus !== 'active') {
            $statusMsg = $studentStatus === 'graduated'
                ? 'គណនីរបស់អ្នកមានស្ថានភាព "រៀនចប់ (Graduated)" មិនអាចស្កេនកត់វត្តមានបានទេ!'
                : 'គណនីរបស់អ្នកត្រូវបានផ្អាក / ឈប់រៀន ("Inactive") មិនអាចស្កេនកត់វត្តមានបានទេ!';
            return response()->json([
                'status' => false,
                'message' => $statusMsg,
            ], 403);
        }

        // ពិនិត្យថាតើនិស្សិតស្ថិតក្នុងដេប៉ាតឺម៉ង់របស់ថ្នាក់នេះឬទេ
        if (!empty($class->department) && trim((string)($user->department ?? '')) !== trim((string)$class->department)) {
            return response()->json([
                'status' => false,
                'message' => 'ថ្នាក់រៀននេះសម្រាប់តែនិស្សិតដេប៉ាតឺម៉ង់ "' . $class->department . '" ប៉ុណ្ណោះ!',
            ], 403);
        }

        // ពិនិត្យឆ្នាំសិក្សា (Year Level 1-4)
        if (!empty($class->year_level) && (int)($user->year_level ?? 0) !== (int)$class->year_level) {
            return response()->json([
                'status' => false,
                'message' => 'ថ្នាក់រៀននេះសម្រាប់តែនិស្សិតឆ្នាំទី ' . $class->year_level . ' ប៉ុណ្ណោះ!',
            ], 403);
        }

        // ពិនិត្យជំនាន់ (Generation) ប្រសិនបើថ្នាក់បានកំណត់ (គាំទ្រទាំងលេខខ្មែរ និងអារ៉ាប់)
        if (!empty($class->generation) && !\App\Models\ClassModel::matchesGeneration($user->generation, $class->generation)) {
            return response()->json([
                'status' => false,
                'message' => 'ថ្នាក់រៀននេះសម្រាប់តែនិស្សិតជំនាន់ "' . $class->generation . '" ប៉ុណ្ណោះ!',
            ], 403);
        }

        $today = Carbon::today()->toDateString();
        $now = Carbon::now();
        $recordDate = $class->class_date ?: $today;

        // ២. ពិនិត្យទីតាំង GPS ក្នុងបរិវេណសាលា (GPS Geofencing)
        $campus = CampusSetting::current();
        $scanLat = $request->filled('latitude') ? (float)$request->latitude : null;
        $scanLng = $request->filled('longitude') ? (float)$request->longitude : null;
        $distanceMeters = null;

        if ($campus->campus_lat !== null && $campus->campus_lng !== null && $scanLat !== null && $scanLng !== null) {
            $distanceMeters = (int) round(CampusSetting::calculateDistanceMeters(
                (float)$campus->campus_lat,
                (float)$campus->campus_lng,
                $scanLat,
                $scanLng
            ));
        }

        if ($campus->enforce_gps && $campus->campus_lat !== null && $campus->campus_lng !== null) {
            if ($scanLat === null || $scanLng === null) {
                return response()->json([
                    'status' => false,
                    'message' => 'សូមបើកទីតាំង GPS លើទូរស័ព្ទរបស់អ្នកជាមុនសិន ដើម្បីស្កេនកត់វត្តមាន!',
                ], 403);
            }

            if ($distanceMeters > $campus->allowed_radius_meters) {
                $distLabel = $distanceMeters >= 1000
                    ? number_format($distanceMeters / 1000, 1) . ' km'
                    : $distanceMeters . ' ម៉ែត្រ';

                return response()->json([
                    'status' => false,
                    'message' => 'អ្នកនៅក្រៅបរិវេណសាលា! ចម្ងាយរបស់អ្នកគឺ ' . $distLabel . ' ពីសាលា (អនុញ្ញាតត្រឹម ' . $campus->allowed_radius_meters . ' ម៉ែត្រ)។',
                    'distance_meters' => $distanceMeters,
                    'allowed_radius_meters' => $campus->allowed_radius_meters,
                ], 403);
            }
        }

        // ពិនិត្យម៉ោងចាប់ផ្តើមថ្នាក់រៀន ដើម្បីកំណត់ថាមកទាន់ពេល ឬមកយឺត (> 15 នាទី)
        $status = 'present';
        $note = 'បានស្កេនតាម QR Code';

        if (!empty($class->time) && preg_match('/(\d{1,2}:\d{2})/', $class->time, $m)) {
            try {
                $startTime = Carbon::createFromFormat('Y-m-d H:i', $today . ' ' . $m[1]);
                if ($now->greaterThan($startTime->copy()->addMinutes(15))) {
                    $status = 'late';
                    $note = 'ស្កេនយឺត (ម៉ោង ' . $now->format('H:i') . ' លើស ១៥ នាទី)';
                }
            } catch (\Exception $e) {
                // រក្សា status = present ប្រសិនបើ parse ម៉ោងមិនចេញ
            }
        }

        // ពិនិត្យមើលថាតើសិស្សបានស្កេនរួចហើយឬនៅសម្រាប់ថ្ងៃនេះ
        $attendance = Attendance::updateOrCreate(
            [
                'class_id' => $class->id,
                'user_id' => $user->id,
                'date' => $recordDate,
            ],
            [
                'status' => $status,
                'scanned_at' => $now,
                'note' => $note,
                'scan_lat' => $scanLat,
                'scan_lng' => $scanLng,
                'distance_meters' => $distanceMeters,
            ]
        );

        return response()->json([
            'status' => true,
            'message' => 'បានកត់វត្តមានជោគជ័យសម្រាប់ថ្នាក់ ' . $class->subject_name,
            'attendance' => [
                'id' => $attendance->id,
                'class_id' => $attendance->class_id,
                'subject_name' => $class->subject_name,
                'subject_code' => $class->subject_code,
                'room' => $class->room,
                'time' => $class->time,
                'student_id' => $user->id,
                'student_name' => $user->name,
                'student_code' => $user->student_code ?? 'STU-' . $user->id,
                'status' => $attendance->status,
                'date' => $attendance->date,
                'scanned_at' => $attendance->scanned_at?->toIso8601String(),
                'note' => $attendance->note,
                'scan_lat' => $attendance->scan_lat,
                'scan_lng' => $attendance->scan_lng,
                'distance_meters' => $attendance->distance_meters,
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
                    'scan_lat' => $att->scan_lat,
                    'scan_lng' => $att->scan_lng,
                    'distance_meters' => $att->distance_meters,
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
    public function classAttendances(Request $request, $classId)
    {
        $class = ClassModel::find($classId);
        if (!$class) {
            return response()->json([
                'status' => false,
                'message' => 'រកមិនឃើញថ្នាក់រៀននេះទេ',
            ], 404);
        }

        if ($request->user() && $request->user()->role === 'lecturer' && (int)$class->user_id !== (int)$request->user()->id) {
            return response()->json([
                'status' => false,
                'message' => 'អ្នកគ្មានសិទ្ធិមើលវត្តមានថ្នាក់របស់គ្រូផ្សេងឡើយ។',
            ], 403);
        }

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
                    'scan_lat' => $att->scan_lat,
                    'scan_lng' => $att->scan_lng,
                    'distance_meters' => $att->distance_meters,
                ];
            });

        return response()->json([
            'status' => true,
            'message' => 'ទាញយកវត្តមានក្នុងថ្នាក់បានជោគជ័យ',
            'data' => $attendances,
        ], 200);
    }

    /**
     * គ្រូកែប្រែស្ថានភាពវត្តមានសិស្ស (Update Attendance Status)
     */
    public function update(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:present,late,absent',
            'note' => 'nullable|string',
        ]);

        $attendance = Attendance::with('classModel')->find($id);

        if (!$attendance) {
            return response()->json([
                'status' => false,
                'message' => 'រកមិនឃើញទិន្នន័យវត្តមាននេះឡើយ!',
            ], 404);
        }

        if ($request->user() && $request->user()->role === 'lecturer' && (int)$attendance->classModel?->user_id !== (int)$request->user()->id) {
            return response()->json([
                'status' => false,
                'message' => 'អ្នកគ្មានសិទ្ធិកែប្រែវត្តមានថ្នាក់របស់គ្រូផ្សេងឡើយ។',
            ], 403);
        }

        $attendance->status = $request->status;
        if ($request->has('note')) {
            $attendance->note = $request->note;
        } else {
            if ($request->status === 'present') {
                $attendance->note = 'កែប្រែដោយគ្រូ';
            } elseif ($request->status === 'late') {
                $attendance->note = 'មកយឺត';
            } else {
                $attendance->note = 'អវត្តមាន';
            }
        }

        if ($request->status === 'absent') {
            $attendance->scanned_at = null;
        } elseif (!$attendance->scanned_at) {
            $attendance->scanned_at = Carbon::now();
        }

        $attendance->save();

        return response()->json([
            'status' => true,
            'message' => 'បានកែប្រែវត្តមានដោយជោគជ័យ',
            'data' => [
                'id' => $attendance->id,
                'class_id' => $attendance->class_id,
                'student_id' => $attendance->user_id,
                'status' => $attendance->status,
                'date' => (string)$attendance->date,
                'scanned_at' => $attendance->scanned_at?->toIso8601String(),
                'note' => $attendance->note,
            ],
        ], 200);
    }

    /**
     * គ្រូ ឬ Admin កែសម្រួលវត្តមានសិស្សដោយផ្ទាល់ (Manual Attendance Override)
     * គាំទ្រ៖ present, late, absent, reset (លុបកំណត់ត្រាដើម្បីឱ្យសិស្សស្កេនឡើងវិញ)
     */
    public function manual(Request $request)
    {
        $request->validate([
            'class_id' => 'required|exists:classes,id',
            'student_id' => 'required|exists:users,id',
            'status' => 'required|in:present,late,absent,reset',
            'date' => 'nullable|date',
            'note' => 'nullable|string',
        ]);

        $class = ClassModel::find($request->class_id);
        if (!$class) {
            return response()->json([
                'status' => false,
                'message' => 'រកមិនឃើញថ្នាក់រៀននេះឡើយ!',
            ], 404);
        }

        $user = $request->user();
        // សិទ្ធិ៖ មានតែគ្រូបង្រៀនប្រចាំថ្នាក់នេះ ឬ Admin/Sub-Admin ប៉ុណ្ណោះដែលអាចកែប្រែវត្តមានបាន
        $isClassTeacher = ($user && $user->role === 'lecturer' && (int)$class->user_id === (int)$user->id);
        $isAdmin = ($user && $user->isAcademicAdmin());

        if (!$isClassTeacher && !$isAdmin) {
            return response()->json([
                'status' => false,
                'message' => 'លោកអ្នកមិនមានសិទ្ធិកែប្រែវត្តមានសម្រាប់ថ្នាក់រៀននេះឡើយ!',
            ], 403);
        }

        $date = $request->filled('date') ? $request->date : ($class->class_date ?: Carbon::today()->toDateString());
        $studentId = $request->student_id;
        $targetStatus = strtolower($request->status);

        // ករណី reset៖ លុបកំណត់ត្រាវត្តមានចោល ដើម្បីឱ្យសិស្សត្រឡប់ទៅសភាពដើម "មិនទាន់ស្កេន" ឬអាចស្កេនម្តងទៀត
        if ($targetStatus === 'reset') {
            Attendance::where('class_id', $class->id)
                ->where('user_id', $studentId)
                ->where('date', $date)
                ->delete();

            return response()->json([
                'status' => true,
                'message' => 'បានកំណត់វត្តមានសិស្សឡើងវិញ (មិនទាន់ស្កេន) ដោយជោគជ័យ!',
                'data' => [
                    'class_id' => $class->id,
                    'student_id' => (int)$studentId,
                    'status' => null,
                    'date' => (string)$date,
                    'scanned_at' => null,
                ],
            ], 200);
        }

        // ករណី present, late, absent
        $note = $request->filled('note')
            ? $request->note
            : ($targetStatus === 'present' ? 'កែសម្រួលដោយគ្រូ (មករៀន)' : ($targetStatus === 'late' ? 'កែសម្រួលដោយគ្រូ (មកយឺត)' : 'កែសម្រួលដោយគ្រូ (អវត្តមាន)'));

        $scannedAt = ($targetStatus === 'absent') ? null : Carbon::now();

        $attendance = Attendance::updateOrCreate(
            [
                'class_id' => $class->id,
                'user_id' => $studentId,
                'date' => $date,
            ],
            [
                'status' => $targetStatus,
                'scanned_at' => $scannedAt,
                'note' => $note,
            ]
        );

        return response()->json([
            'status' => true,
            'message' => 'បានកែប្រែវត្តមានសិស្សដោយជោគជ័យ!',
            'data' => [
                'id' => $attendance->id,
                'class_id' => $attendance->class_id,
                'student_id' => $attendance->user_id,
                'status' => $attendance->status,
                'date' => (string)$attendance->date,
                'scanned_at' => $attendance->scanned_at?->toIso8601String(),
                'note' => $attendance->note,
            ],
        ], 200);
    }
}
