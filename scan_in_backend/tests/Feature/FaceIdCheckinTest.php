<?php

namespace Tests\Feature;

use App\Models\CampusSetting;
use App\Models\ClassModel;
use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class FaceIdCheckinTest extends TestCase
{
    use DatabaseTransactions;

    private function createClassAndStudent(): array
    {
        $lecturer = User::create([
            'name' => 'Lecturer FaceID',
            'email' => 'lec_face_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'lecturer',
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
        ]);

        $student = User::create([
            'name' => 'Student FaceID',
            'email' => 'stu_face_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'student',
            'student_code' => 'IT20-FACE',
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'year_level' => 4,
            'generation' => 'ជំនាន់ទី 20 (Gen 20)',
            'status' => 'active',
        ]);

        // Even when QR is paused/not opened yet, Face ID check-in works for students inside campus!
        $class = ClassModel::create([
            'user_id' => $lecturer->id,
            'subject_name' => 'Hybrid Mobile App',
            'subject_code' => 'HMA-FACE',
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'generation' => 'ជំនាន់ទី 20 (Gen 20)',
            'year_level' => 4,
            'room' => '112',
            'day_of_week' => 'សៅរ៍ (Sat)',
            'time' => '07:00 - 08:30',
            'is_qr_active' => false,
        ]);

        return [$class, $student];
    }

    public function test_student_can_check_in_via_face_id_inside_campus_and_binds_device(): void
    {
        CampusSetting::current()->update([
            'campus_lat' => 13.095742,
            'campus_lng' => 103.202218,
            'allowed_radius_meters' => 65,
            'enforce_gps' => true,
            'allow_face_id_checkin' => true,
        ]);

        [$class, $student] = $this->createClassAndStudent();
        Sanctum::actingAs($student);

        $response = $this->postJson('/api/attendances/face-checkin', [
            'class_id' => $class->id,
            'biometric_verified' => true,
            'device_id' => 'DEVICE-IPHONE-001',
            'latitude' => 13.095842,
            'longitude' => 103.202218,
            'is_mocked' => false,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
                'attendance' => [
                    'check_in_method' => 'face_id',
                ],
            ]);

        $student->refresh();
        $this->assertEquals('DEVICE-IPHONE-001', $student->device_id);
    }

    public function test_different_device_id_is_rejected_until_admin_resets_device(): void
    {
        $admin = User::create([
            'name' => 'Admin Reset',
            'email' => 'adm_rst_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'admin',
        ]);

        [$class, $student] = $this->createClassAndStudent();
        $student->update(['device_id' => 'ORIGINAL-PHONE-111']);

        Sanctum::actingAs($student);
        $this->postJson('/api/attendances/face-checkin', [
            'class_id' => $class->id,
            'biometric_verified' => true,
            'device_id' => 'FRIEND-PHONE-999',
        ])->assertStatus(403);

        // Admin resets student's device ID
        Sanctum::actingAs($admin);
        $this->postJson('/api/admin/students/' . $student->id . '/reset-device')
            ->assertStatus(200)
            ->assertJson(['status' => true]);

        // Now student can bind new phone
        Sanctum::actingAs($student->fresh());
        $this->postJson('/api/attendances/face-checkin', [
            'class_id' => $class->id,
            'biometric_verified' => true,
            'device_id' => 'NEW-PHONE-222',
        ])->assertStatus(200);

        $student->refresh();
        $this->assertEquals('NEW-PHONE-222', $student->device_id);
    }

    public function test_face_checkin_rejected_when_biometric_failed_or_disabled(): void
    {
        [$class, $student] = $this->createClassAndStudent();
        Sanctum::actingAs($student);

        // Biometric failed
        $this->postJson('/api/attendances/face-checkin', [
            'class_id' => $class->id,
            'biometric_verified' => false,
            'device_id' => 'DEVICE-123',
        ])->assertStatus(403);

        // Disabled globally by admin
        CampusSetting::current()->update(['allow_face_id_checkin' => false]);
        $this->postJson('/api/attendances/face-checkin', [
            'class_id' => $class->id,
            'biometric_verified' => true,
            'device_id' => 'DEVICE-123',
        ])->assertStatus(403);
    }
}
