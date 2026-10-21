<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * User Login API
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
            'role' => 'nullable|string', // 'student', 'lecturer', 'teacher'
        ]);

        $user = User::where('email', $request->email)->first();

        // ផ្ទៀងផ្ទាត់ Email & Password
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'status' => false,
                'message' => 'អ៊ីមែល ឬពាក្យសម្ងាត់មិនត្រឹមត្រូវឡើយ។',
            ], 401);
        }

        // ផ្ទៀងផ្ទាត់តួនាទី (Role) ប្រសិនបើ Frontend ផ្ញើមក
        if ($request->filled('role')) {
            $expectedRole = strtolower($request->role);
            if ($expectedRole === 'teacher') {
                $expectedRole = 'lecturer';
            }

            if ($user->role !== $expectedRole && $user->role !== 'admin') {
                $roleLabelKh = ($expectedRole === 'student') ? 'សិស្ស/និស្សិត' : 'គ្រូបង្រៀន';
                return response()->json([
                    'status' => false,
                    'message' => "គណនីនេះមិនមែនជាគណនី{$roleLabelKh}ឡើយ។",
                ], 403);
            }
        }

        // បង្កើត Sanctum Token
        $token = $user->createToken('scan_in_token')->plainTextToken;

        return response()->json([
            'status' => true,
            'message' => 'ចូលប្រើប្រាស់បានជោគជ័យ',
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'student_code' => $user->student_code,
                'staff_id' => $user->staff_id,
                'department' => $user->department,
                'phone' => $user->phone,
                'avatar_url' => $user->avatar_url,
                'created_at' => $user->created_at?->toIso8601String(),
            ],
        ], 200);
    }

    /**
     * Get Current Authenticated User Profile
     */
    public function me(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'status' => true,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'student_code' => $user->student_code,
                'staff_id' => $user->staff_id,
                'department' => $user->department,
                'phone' => $user->phone,
                'avatar_url' => $user->avatar_url,
                'created_at' => $user->created_at?->toIso8601String(),
            ],
        ], 200);
    }

    /**
     * User Logout API
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status' => true,
            'message' => 'ចាកចេញពីគណនីបានជោគជ័យ',
        ], 200);
    }
}
