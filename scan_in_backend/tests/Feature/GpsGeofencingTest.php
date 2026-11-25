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

class GpsGeofencingTest extends TestCase
{
    use DatabaseTransactions;

    private function createClassAndStudent(): array
    {
        $lecturer = User::create([
            'name' => 'Lecturer GPS',
            'email' => 'lec_gps_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'lecturer',
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
        ]);

        $student = User::create([
            'name' => 'Student GPS',
            'email' => 'stu_gps_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'student',
            'student_code' => 'IT20-GPS',
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'year_level' => 4,
            'generation' => 'ជំនាន់ទី 20 (Gen 20)',
            'status' => 'active',
        ]);

        $class = ClassModel::create([
            'user_id' => $lecturer->id,
            'subject_name' => 'Hybrid Mobile App',
            'subject_code' => 'HMA-GPS',
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'generation' => 'ជំនាន់ទី 20 (Gen 20)',
            'year_level' => 4,
            'room' => '112',
            'day_of_week' => 'សៅរ៍ (Sat)',
            'time' => '07:00 - 08:30',
            'is_qr_active' => true,
            'qr_token' => 'QR-GPS-' . Str::random(8),
        ]);

        return [$class, $student];
    }

    public function test_admin_can_update_campus_gps_settings_and_student_cannot(): void
    {
        $admin = User::create([
            'name' => 'Admin GPS',
            'email' => 'adm_gps_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'admin',
        ]);

        $student = User::create([
            'name' => 'Student No Perm',
            'email' => 'stu_noperm_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'student',
        ]);

        Sanctum::actingAs($student);
        $this->putJson('/api/admin/campus-settings', [
            'campus_lat' => 13.095742,
            'campus_lng' => 103.202218,
            'allowed_radius_meters' => 65,
            'enforce_gps' => true,
        ])->assertStatus(403);

        Sanctum::actingAs($admin);
        $this->putJson('/api/admin/campus-settings', [
            'campus_name' => 'Battambang Campus (45m x 75m)',
            'campus_lat' => 13.095742,
            'campus_lng' => 103.202218,
            'allowed_radius_meters' => 65,
            'enforce_gps' => true,
        ])->assertStatus(200)
          ->assertJson([
              'status' => true,
              'data' => [
                  'allowed_radius_meters' => 65,
                  'enforce_gps' => true,
              ],
          ]);
    }

    public function test_haversine_distance_between_battambang_and_pailin(): void
    {
        $distance = CampusSetting::calculateDistanceMeters(13.0957, 103.2022, 12.8489, 102.6093);
        // Battambang to Pailin is roughly 69.8 km (69,800m)
        $this->assertGreaterThan(68000, $distance);
        $this->assertLessThan(72000, $distance);
    }

    public function test_student_inside_campus_radius_can_scan_and_saves_distance(): void
    {
        CampusSetting::current()->update([
            'campus_lat' => 13.095742,
            'campus_lng' => 103.202218,
            'allowed_radius_meters' => 65,
            'enforce_gps' => true,
        ]);

        [$class, $student] = $this->createClassAndStudent();
        Sanctum::actingAs($student);

        // ~22 meters away from campus center (well inside 65m for 45x75m campus)
        $response = $this->postJson('/api/attendances/scan', [
            'qr_token' => $class->qr_token,
            'latitude' => 13.095942,
            'longitude' => 103.202218,
            'is_mocked' => false,
        ]);

        $response->assertStatus(200)
            ->assertJson(['status' => true]);

        $distance = $response->json('attendance.distance_meters');
        $this->assertNotNull($distance);
        $this->assertLessThanOrEqual(65, $distance);
    }

    public function test_student_in_pailin_or_outside_campus_radius_is_rejected(): void
    {
        CampusSetting::current()->update([
            'campus_lat' => 13.095742,
            'campus_lng' => 103.202218,
            'allowed_radius_meters' => 65,
            'enforce_gps' => true,
        ]);

        [$class, $student] = $this->createClassAndStudent();
        Sanctum::actingAs($student);

        // Student scanning from Pailin
        $response = $this->postJson('/api/attendances/scan', [
            'qr_token' => $class->qr_token,
            'latitude' => 12.848900,
            'longitude' => 102.609300,
            'is_mocked' => false,
        ]);

        $response->assertStatus(403)
            ->assertJson(['status' => false]);
        $this->assertGreaterThan(65, $response->json('distance_meters'));
    }

    public function test_fake_gps_mock_location_is_always_rejected(): void
    {
        [$class, $student] = $this->createClassAndStudent();
        Sanctum::actingAs($student);

        $response = $this->postJson('/api/attendances/scan', [
            'qr_token' => $class->qr_token,
            'latitude' => 13.095742,
            'longitude' => 103.202218,
            'is_mocked' => true,
        ]);

        $response->assertStatus(403)
            ->assertJson(['status' => false]);
    }

    public function test_missing_gps_when_enforced_is_rejected(): void
    {
        CampusSetting::current()->update([
            'campus_lat' => 13.095742,
            'campus_lng' => 103.202218,
            'allowed_radius_meters' => 65,
            'enforce_gps' => true,
        ]);

        [$class, $student] = $this->createClassAndStudent();
        Sanctum::actingAs($student);

        $response = $this->postJson('/api/attendances/scan', [
            'qr_token' => $class->qr_token,
        ]);

        $response->assertStatus(403)
            ->assertJson(['status' => false]);
    }
}
