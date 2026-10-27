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
}
