<?php
// Automated test suite: AttendanceFeatureTest.php.

namespace Tests\Feature;

use App\Models\Attendance;
use App\Models\ClassModel;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Tests\TestCase;

class AttendanceFeatureTest extends TestCase
{
    use DatabaseTransactions;

    private function createLecturer(): User
    {
        return User::create([
            'name' => 'Lecturer Test',
            'email' => 'lec_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'lecturer',
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'status' => 'active',
        ]);
    }

    private function createStudent(): User
    {
        return User::create([
            'name' => 'Student Test',
            'email' => 'stu_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'student',
            'student_code' => 'STU-' . rand(1000, 9999),
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'generation' => 'Gen 20',
            'year_level' => 4,
            'status' => 'active',
        ]);
    }

    private function createClass(User $lecturer, string $time = '07:00 - 08:30'): ClassModel
    {
        return ClassModel::create([
            'subject_name' => 'Test Subject',
            'subject_code' => 'TS101',
            'user_id' => $lecturer->id,
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'generation' => 'Gen 20',
            'year_level' => 4,
            'room' => 'Room 101',
            'day_of_week' => 'សៅរ៍ (Sat)',
            'time' => $time,
            'class_date' => Carbon::today()->toDateString(),
            'total_sessions' => 15,
            'is_qr_active' => true,
            'qr_token' => 'QR-' . Str::random(10),
        ]);
    }

    public function test_teacher_can_manually_override_attendance_and_reset(): void
    {
        $lecturer = $this->createLecturer();
        $student = $this->createStudent();
        $class = $this->createClass($lecturer);

        $resp1 = $this->actingAs($lecturer)->postJson('/api/attendances/manual', [
            'class_id' => $class->id,
            'student_id' => $student->id,
            'status' => 'present',
        ]);
        $resp1->assertStatus(200);
        $this->assertDatabaseHas('attendances', [
            'class_id' => $class->id,
            'user_id' => $student->id,
            'status' => 'present',
        ]);

        $resp2 = $this->actingAs($lecturer)->postJson('/api/attendances/manual', [
            'class_id' => $class->id,
            'student_id' => $student->id,
            'status' => 'late',
        ]);
        $resp2->assertStatus(200);
        $this->assertDatabaseHas('attendances', [
            'class_id' => $class->id,
            'user_id' => $student->id,
            'status' => 'late',
        ]);

        $resp3 = $this->actingAs($lecturer)->postJson('/api/attendances/manual', [
            'class_id' => $class->id,
            'student_id' => $student->id,
            'status' => 'reset',
        ]);
        $resp3->assertStatus(200);
        $this->assertDatabaseMissing('attendances', [
            'class_id' => $class->id,
            'user_id' => $student->id,
        ]);
    }

    public function test_other_teacher_cannot_override_attendance(): void
    {
        $teacher1 = $this->createLecturer();
        $teacher2 = $this->createLecturer();
        $student = $this->createStudent();
        $class = $this->createClass($teacher1);

        $response = $this->actingAs($teacher2)->postJson('/api/attendances/manual', [
            'class_id' => $class->id,
            'student_id' => $student->id,
            'status' => 'present',
        ]);
        $response->assertStatus(403);
    }

    public function test_scan_marks_late_if_over_15_minutes(): void
    {
        $lecturer = $this->createLecturer();
        $student = $this->createStudent();

        $pastStartTime = Carbon::now()->subHours(2)->format('H:i');
        $pastEndTime = Carbon::now()->subHours(1)->format('H:i');
        $class = $this->createClass($lecturer, "{$pastStartTime} - {$pastEndTime}");

        $response = $this->actingAs($student)->postJson('/api/attendances/scan', [
            'qr_token' => $class->qr_token,
        ]);

        $response->assertStatus(200);
        $this->assertEquals('late', $response->json('attendance.status'));
    }
}
