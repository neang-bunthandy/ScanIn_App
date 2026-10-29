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
     * បង្កើតថ្នាក់រៀនថ្មី (Create New Class)
     */
    public function store(Request $request)
    {
        $request->validate([
            'subject_name' => 'required|string|max:255',
            'subject_code' => 'required|string|max:50',
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

        $userId = $request->user()?->id ?? $request->input('lecturer_id', 1);

        $code = strtoupper(trim($request->subject_code));
        $qrToken = $request->qr_token ?? ('SCANIN-' . $code . '-' . date('Y'));

        $class = ClassModel::create([
            'user_id' => $userId,
            'subject_name' => $request->subject_name,
            'subject_code' => $code,
            'room' => $request->room,
            'day_of_week' => $request->day_of_week,
            'time' => $request->time,
            'semester' => $request->semester ?? 'ឆមាសទី ១',
            'academic_year' => $request->academic_year ?? '2026-2027',
            'student_count' => $request->student_count ?? 30,
            'completed_sessions' => 0,
            'total_sessions' => $request->total_sessions ?? 15,
            'description' => $request->description,
            'is_qr_active' => (bool)$request->input('is_qr_active', false),
            'qr_token' => $qrToken,
        ]);

        $class->load('lecturer');

        return response()->json([
            'status' => true,
            'message' => 'បានបង្កើតថ្នាក់រៀនដោយជោគជ័យ',
            'data' => [
                'id' => $class->id,
                'lecturer_id' => $class->user_id,
                'lecturer_name' => $class->lecturer?->name,
                'teacher_email' => $class->lecturer?->email,
                'teacher_phone' => $class->lecturer?->phone,
                'subject_name' => $class->subject_name,
                'subject_code' => $class->subject_code,
                'room' => $class->room,
                'day_of_week' => $class->day_of_week,
                'time' => $class->time,
                'semester' => $class->semester,
                'academic_year' => $class->academic_year,
                'student_count' => $class->student_count,
                'completed_sessions' => $class->completed_sessions,
                'total_sessions' => $class->total_sessions,
                'description' => $class->description,
                'is_qr_active' => (bool)$class->is_qr_active,
                'qr_token' => $class->qr_token,
                'created_at' => $class->created_at,
            ],
        ], 201);
    }

    /**
     * បើក ឬបិទដំណើរការ QR Code សម្រាប់ថ្នាក់រៀន (Toggle QR Code)
     */
    public function toggleQr(Request $request, $id)
    {
        $class = ClassModel::findOrFail($id);

        if ($request->has('is_qr_active')) {
            $class->is_qr_active = (bool)$request->is_qr_active;
        } else {
            $class->is_qr_active = !$class->is_qr_active;
        }

        if ($request->has('qr_token')) {
            $class->qr_token = $request->qr_token;
        }

        $class->save();

        return response()->json([
            'status' => true,
            'message' => $class->is_qr_active ? 'បានបើកដំណើរការ QR ជោគជ័យ' : 'បានបិទដំណើរការ QR ជោគជ័យ',
            'is_qr_active' => (bool)$class->is_qr_active,
            'qr_token' => $class->qr_token,
            'class_id' => $class->id,
        ], 200);
    }
}
