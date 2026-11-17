<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Tests\TestCase;

class AuthApiTest extends TestCase
{
    use DatabaseTransactions;

    public function test_lecturer_can_login_with_valid_credentials(): void
    {
        $lecturer = User::create([
            'name' => 'Dr. Test Lecturer',
            'email' => 'lecturer_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'lecturer',
            'staff_id' => 'STF-' . rand(100, 999),
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'status' => 'active',
        ]);

        $response = $this->postJson('/api/login', [
            'email' => $lecturer->email,
            'password' => 'password123',
            'role' => 'teacher',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'status',
                'message',
                'access_token',
                'token_type',
                'user' => [
                    'id',
                    'name',
                    'email',
                    'role',
                    'staff_id',
                ],
            ])
            ->assertJson([
                'status' => true,
                'user' => [
                    'email' => $lecturer->email,
                    'role' => 'lecturer',
                ],
            ]);
    }

    public function test_student_can_login_with_valid_credentials(): void
    {
        $student = User::create([
            'name' => 'Test Student',
            'email' => 'student_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'student',
            'student_code' => 'STU' . rand(1000, 9999),
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'status' => 'active',
        ]);

        $response = $this->postJson('/api/login', [
            'email' => $student->email,
            'password' => 'password123',
            'role' => 'student',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
                'user' => [
                    'email' => $student->email,
                    'role' => 'student',
                    'student_code' => $student->student_code,
                ],
            ]);
    }

    public function test_login_fails_with_invalid_password(): void
    {
        $student = User::create([
            'name' => 'Test Student',
            'email' => 'student_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'student',
            'student_code' => 'STU' . rand(1000, 9999),
            'status' => 'active',
        ]);

        $response = $this->postJson('/api/login', [
            'email' => $student->email,
            'password' => 'wrongpassword',
        ]);

        $response->assertStatus(401)
            ->assertJson([
                'status' => false,
            ]);
    }

    public function test_authenticated_user_can_access_me_and_logout(): void
    {
        $student = User::create([
            'name' => 'Test Student',
            'email' => 'student_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'student',
            'student_code' => 'STU' . rand(1000, 9999),
            'status' => 'active',
        ]);

        $loginResponse = $this->postJson('/api/login', [
            'email' => $student->email,
            'password' => 'password123',
        ]);

        $token = $loginResponse->json('access_token');

        // Test /api/me
        $meResponse = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/me');

        $meResponse->assertStatus(200)
            ->assertJson([
                'status' => true,
                'user' => [
                    'email' => $student->email,
                ],
            ]);

        // Test /api/logout
        $logoutResponse = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/logout');

        $logoutResponse->assertStatus(200)
            ->assertJson([
                'status' => true,
            ]);
    }

    public function test_user_can_change_password_successfully(): void
    {
        $user = User::create([
            'name' => 'Test User',
            'email' => 'user_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('oldpassword123'),
            'role' => 'admin',
            'status' => 'active',
        ]);

        $loginResponse = $this->postJson('/api/login', [
            'email' => $user->email,
            'password' => 'oldpassword123',
        ]);

        $token = $loginResponse->json('access_token');

        // Call change password API
        $changeResponse = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/user/change-password', [
                'current_password' => 'oldpassword123',
                'new_password' => 'newpassword456',
            ]);

        $changeResponse->assertStatus(200)
            ->assertJson([
                'status' => true,
            ]);

        // Verify login with new password works
        $newLoginResponse = $this->postJson('/api/login', [
            'email' => $user->email,
            'password' => 'newpassword456',
        ]);

        $newLoginResponse->assertStatus(200)
            ->assertJson([
                'status' => true,
            ]);
    }
}
