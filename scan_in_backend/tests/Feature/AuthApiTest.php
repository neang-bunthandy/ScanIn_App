<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthApiTest extends TestCase
{
    public function test_lecturer_can_login_with_valid_credentials(): void
    {
        $response = $this->postJson('/api/login', [
            'email' => 'dara@scanin.app',
            'password' => '223232323',
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
                    'email' => 'dara@scanin.app',
                    'role' => 'lecturer',
                ],
            ]);
    }

    public function test_student_can_login_with_valid_credentials(): void
    {
        $response = $this->postJson('/api/login', [
            'email' => 'student@scanin.app',
            'password' => '12345678',
            'role' => 'student',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
                'user' => [
                    'email' => 'student@scanin.app',
                    'role' => 'student',
                    'student_code' => 'STU001',
                ],
            ]);
    }

    public function test_login_fails_with_invalid_password(): void
    {
        $response = $this->postJson('/api/login', [
            'email' => 'student@scanin.app',
            'password' => 'wrongpassword',
        ]);

        $response->assertStatus(401)
            ->assertJson([
                'status' => false,
            ]);
    }

    public function test_authenticated_user_can_access_me_and_logout(): void
    {
        $loginResponse = $this->postJson('/api/login', [
            'email' => 'student@scanin.app',
            'password' => '12345678',
        ]);

        $token = $loginResponse->json('access_token');

        // Test /api/me
        $meResponse = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/me');

        $meResponse->assertStatus(200)
            ->assertJson([
                'status' => true,
                'user' => [
                    'email' => 'student@scanin.app',
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
}
