<?php
// Handles user authentication, profile, password, and avatar upload.

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
            'role' => 'nullable|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'status' => false,
                'message' => 'អ៊ីមែល ឬពាក្យសម្ងាត់មិនត្រឹមត្រូវឡើយ។',
            ], 401);
        }

        if ($request->filled('role')) {
            $expectedRole = strtolower(trim($request->role));
            if ($expectedRole === 'teacher') {
                $expectedRole = 'lecturer';
            }

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

            if ($expectedRole === 'student') {
                if ($user->role !== 'student') {
                    return response()->json([
                        'status' => false,
                        'message' => 'គណនីនេះមិនមែនជាគណនីសិស្ស/និស្សិតឡើយ។',
                    ], 403);
                }
            }
        }

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

    public function changePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required|string',
            'new_password' => 'required|string|min:6',
        ]);

        $user = $request->user();

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'status' => false,
                'message' => 'ពាក្យសម្ងាត់ចាស់មិនត្រឹមត្រូវឡើយ។',
            ], 422);
        }

        $user->password = Hash::make($request->new_password);
        $user->save();

        return response()->json([
            'status' => true,
            'message' => 'បានប្តូរពាក្យសម្ងាត់ដោយជោគជ័យ!',
        ], 200);
    }

    public function uploadAvatar(Request $request)
    {
        $request->validate([
            'avatar' => 'required|image|mimes:jpeg,png,jpg,webp|max:5120',
        ]);

        $user = $request->user();
        $file = $request->file('avatar');

        if ($user->avatar_url && str_starts_with($user->avatar_url, '/storage/avatars/')) {
            $oldRelativePath = str_replace('/storage/', '', $user->avatar_url);
            \Illuminate\Support\Facades\Storage::disk('public')->delete($oldRelativePath);
        }

        $extension = $file->getClientOriginalExtension() ?: 'jpg';
        $filename = 'avatar_' . $user->id . '_' . time() . '_' . \Illuminate\Support\Str::random(6) . '.' . $extension;
        $path = $file->storeAs('avatars', $filename, 'public');

        $avatarUrl = '/storage/' . $path;
        $user->avatar_url = $avatarUrl;
        $user->save();

        return response()->json([
            'status' => true,
            'message' => 'បានផ្លាស់ប្តូររូបថត Profile ដោយជោគជ័យ',
            'avatar_url' => $avatarUrl,
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

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status' => true,
            'message' => 'ចាកចេញពីគណនីបានជោគជ័យ',
        ], 200);
    }
}
