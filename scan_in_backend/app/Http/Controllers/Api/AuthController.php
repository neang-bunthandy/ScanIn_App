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
            $expectedRole = strtolower(trim($request->role));
            if ($expectedRole === 'teacher') {
                $expectedRole = 'lecturer';
            }

            // ១. ផ្ទាំង «សាកលវិទ្យាធិការ» (Rector / Master Admin) - ផ្តាច់មុខសម្រាប់តែ Admin កំពូល CLI តែមួយគត់!
            if (in_array($expectedRole, ['rector', 'admin', 'master_admin'])) {
                if ($user->role !== 'admin') {
                    $msg = $user->role === 'sub_admin'
                        ? 'គណនីនេះជាគណនីបុគ្គលិក (Sub-Admin) មិនអាចចូលជាសាកលវិទ្យាធិការបានឡើយ។ សូមជ្រើសរើសផ្ទាំង "គ្រូ / បុគ្គលិក"។'
                        : ($user->role === 'lecturer'
                            ? 'គណនីនេះជាគណនីគ្រូបង្រៀន មិនអាចចូលជាសាកលវិទ្យាធិការបានឡើយ។ សូមជ្រើសរើសផ្ទាំង "គ្រូ / បុគ្គលិក"។'
                            : 'គណនីសិស្សមិនអាចចូលប្រើប្រាស់ Web បានឡើយ។');

                    return response()->json([
                        'status' => false,
                        'message' => $msg,
                    ], 403);
                }
            }

            // ២. ផ្ទាំង «គ្រូ / បុគ្គលិក» (Staff & Lecturers) - សម្រាប់តែ Sub-Admin និង គ្រូបង្រៀន
            if (in_array($expectedRole, ['staff', 'lecturer'])) {
                if (!in_array($user->role, ['sub_admin', 'lecturer'])) {
                    $msg = $user->role === 'admin'
                        ? 'គណនីនេះជាគណនីសាកលវិទ្យាធិការ (Master Admin)។ សូមជ្រើសរើសផ្ទាំង "សាកលវិទ្យាធិការ" ដើម្បីចូលគ្រប់គ្រង។'
                        : 'គណនីសិស្សមិនអាចចូលប្រើប្រាស់ Web បានឡើយ។';

                    return response()->json([
                        'status' => false,
                        'message' => $msg,
                    ], 403);
                }
            }

            // ៣. ករណី Mobile App Login (student)
            if ($expectedRole === 'student') {
                if ($user->role !== 'student') {
                    return response()->json([
                        'status' => false,
                        'message' => 'គណនីនេះមិនមែនជាគណនីសិស្ស/និស្សិតឡើយ។',
                    ], 403);
                }
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
                'latin_name' => $user->latin_name,
                'email' => $user->email,
                'role' => $user->role,
                'student_code' => $user->student_code,
                'staff_id' => $user->staff_id,
                'department' => $user->department,
                'generation' => $user->generation,
                'intake_year' => $user->intake_year,
                'year_level' => $user->year_level !== null ? (int)$user->year_level : null,
                'status' => $user->status ?? 'active',
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
                'latin_name' => $user->latin_name,
                'email' => $user->email,
                'role' => $user->role,
                'student_code' => $user->student_code,
                'staff_id' => $user->staff_id,
                'department' => $user->department,
                'generation' => $user->generation,
                'intake_year' => $user->intake_year,
                'year_level' => $user->year_level !== null ? (int)$user->year_level : null,
                'status' => $user->status ?? 'active',
                'phone' => $user->phone,
                'avatar_url' => $user->avatar_url,
                'created_at' => $user->created_at?->toIso8601String(),
            ],
        ], 200);
    }

    /**
     * Change User Password API
     */
    public function changePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required|string',
            'new_password' => 'required|string|min:6',
        ]);

        $user = $request->user();

        // ផ្ទៀងផ្ទាត់ Password ចាស់
        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'status' => false,
                'message' => 'ពាក្យសម្ងាត់ចាស់មិនត្រឹមត្រូវឡើយ។',
            ], 422);
        }

        // Update ពាក្យសម្ងាត់ថ្មី
        $user->password = Hash::make($request->new_password);
        $user->save();

        return response()->json([
            'status' => true,
            'message' => 'បានប្តូរពាក្យសម្ងាត់ដោយជោគជ័យ!',
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
