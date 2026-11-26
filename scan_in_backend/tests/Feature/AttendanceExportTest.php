<?php
// Automated test suite: AttendanceExportTest.php.

namespace Tests\Feature;

use App\Models\Attendance;
use App\Models\ClassModel;
use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AttendanceExportTest extends TestCase
{
    use DatabaseTransactions;

    public function test_admin_can_export_attendance_as_utf8_bom_csv(): void
    {
        $admin = User::create([
            'name' => 'Admin Export',
            'email' => 'admin_exp_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'admin',
        ]);

        $lecturer = User::create([
            'name' => 'គ្រូបង្រៀន តេស្ត',
            'email' => 'lec_exp_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'lecturer',
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
        ]);

        $student = User::create([
            'name' => 'និស្សិត តេស្ត',
            'latin_name' => 'TEST STUDENT',
            'email' => 'stu_exp_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'student',
            'student_code' => 'IT20-999',
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
        ]);

        $class = ClassModel::create([
            'user_id' => $lecturer->id,
            'subject_name' => 'Hybrid Mobile App',
            'subject_code' => 'HMA-EXP',
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'generation' => 'ជំនាន់ទី 20 (Gen 20)',
            'year_level' => 4,
            'room' => '112',
            'day_of_week' => 'សៅរ៍ (Sat)',
            'time' => '07:00 - 08:30',
        ]);

        Attendance::create([
            'class_id' => $class->id,
            'user_id' => $student->id,
            'status' => 'present',
            'date' => '2026-11-21',
            'scanned_at' => '2026-11-21 07:05:00',
            'note' => 'On time',
        ]);

        Sanctum::actingAs($admin);

        $response = $this->get('/api/reports/attendance/export?class_id=' . $class->id);

        $response->assertStatus(200);
        $this->assertStringContainsString('text/csv', $response->headers->get('Content-Type'));
        $content = $response->getContent();

        $this->assertStringStartsWith("\xEF\xBB\xBF", $content);
        $this->assertStringContainsString('IT20-999', $content);
        $this->assertStringContainsString('និស្សិត តេស្ត', $content);
        $this->assertStringContainsString('HMA-EXP', $content);
    }

    public function test_lecturer_can_export_own_class_but_cannot_export_other_class(): void
    {
        $lecturerA = User::create([
            'name' => 'Lecturer A',
            'email' => 'leca_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'lecturer',
        ]);

        $lecturerB = User::create([
            'name' => 'Lecturer B',
            'email' => 'lecb_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'lecturer',
        ]);

        $classA = ClassModel::create([
            'user_id' => $lecturerA->id,
            'subject_name' => 'Class A',
            'subject_code' => 'CLS-A',
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'room' => '101',
            'day_of_week' => 'ចន្ទ (Mon)',
            'time' => '07:00 - 08:30',
        ]);

        $classB = ClassModel::create([
            'user_id' => $lecturerB->id,
            'subject_name' => 'Class B',
            'subject_code' => 'CLS-B',
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'room' => '102',
            'day_of_week' => 'អង្គារ (Tue)',
            'time' => '07:00 - 08:30',
        ]);

        Sanctum::actingAs($lecturerA);

        $ownResp = $this->get('/api/reports/attendance/export?class_id=' . $classA->id . '&format=json');
        $ownResp->assertStatus(200)->assertJson(['status' => true]);

        $otherResp = $this->get('/api/reports/attendance/export?class_id=' . $classB->id);
        $otherResp->assertStatus(403);
    }

    public function test_student_cannot_export_class_attendance_report(): void
    {
        $student = User::create([
            'name' => 'Student Denied',
            'email' => 'studen_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'student',
        ]);

        Sanctum::actingAs($student);

        $response = $this->getJson('/api/reports/attendance/export');
        $response->assertStatus(403);
    }
}
