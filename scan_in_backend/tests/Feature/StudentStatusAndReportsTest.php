<?php

namespace Tests\Feature;

use App\Models\ClassModel;
use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class StudentStatusAndReportsTest extends TestCase
{
    use DatabaseTransactions;

    public function test_admin_only_student_stats_report_counts_all_statuses_by_intake_year_and_department(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $lecturer = User::factory()->create([
            'role' => 'lecturer',
            'password' => Hash::make('secret123'),
        ]);

        $deptIt = 'TestStats-IT';
        $deptCs = 'TestStats-CS';

        // Year 2022: 2 IT (1 active, 1 graduated), 1 CS (inactive)
        User::factory()->create([
            'role' => 'student',
            'department' => $deptIt,
            'generation' => 'ជំនាន់ទី ១៤ (Gen 14)',
            'intake_year' => '2022',
            'year_level' => 4,
            'status' => 'active',
            'gender' => 'ប្រុស',
            'student_code' => 'ST22-01',
        ]);
        User::factory()->create([
            'role' => 'student',
            'department' => $deptIt,
            'generation' => 'ជំនាន់ទី ១៤ (Gen 14)',
            'intake_year' => '2022',
            'year_level' => 4,
            'status' => 'graduated',
            'gender' => 'ស្រី',
            'student_code' => 'ST22-02',
        ]);
        User::factory()->create([
            'role' => 'student',
            'department' => $deptCs,
            'generation' => 'ជំនាន់ទី ១៤ (Gen 14)',
            'intake_year' => '2022',
            'year_level' => 4,
            'status' => 'inactive',
            'gender' => 'ប្រុស',
            'student_code' => 'ST22-03',
        ]);

        // Lecturer and Student are forbidden (403)
        $this->actingAs($lecturer)->getJson('/api/admin/reports/student-stats')->assertStatus(403);

        // Admin filters by generation Gen 14 + intake_year 2022
        $res = $this->actingAs($admin)->getJson('/api/admin/reports/student-stats?intake_year=2022&generation=' . urlencode('ជំនាន់ទី ១៤ (Gen 14)'))
            ->assertStatus(200)
            ->json('data');

        $this->assertEquals(3, $res['summary']['total_students']);
        $this->assertEquals(1, $res['summary']['active_count']);
        $this->assertEquals(1, $res['summary']['graduated_count']);
        $this->assertEquals(1, $res['summary']['inactive_count']);
        $this->assertEquals(2, $res['summary']['male_count']);
        $this->assertEquals(1, $res['summary']['female_count']);

        $yearRow = $res['by_intake_year'][0];
        $this->assertEquals('2022', $yearRow['intake_year']);
        $this->assertEquals(2, $yearRow['departments'][$deptIt]);
        $this->assertEquals(1, $yearRow['departments'][$deptCs]);
    }

    public function test_graduated_and_inactive_students_are_blocked_from_active_classes_but_kept_in_reports(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $lecturer = User::factory()->create(['role' => 'lecturer']);

        $dept = 'StatusClass-Unique';
        $activeStu = User::factory()->create([
            'role' => 'student',
            'department' => $dept,
            'generation' => 'ជំនាន់ទី ១៥ (Gen 15)',
            'intake_year' => '2024',
            'year_level' => 3,
            'status' => 'active',
            'student_code' => 'ACT001',
        ]);
        $gradStu = User::factory()->create([
            'role' => 'student',
            'department' => $dept,
            'generation' => 'ជំនាន់ទី ១៥ (Gen 15)',
            'intake_year' => '2024',
            'year_level' => 3,
            'status' => 'graduated',
            'student_code' => 'GRAD001',
        ]);
        $inactStu = User::factory()->create([
            'role' => 'student',
            'department' => $dept,
            'generation' => 'ជំនាន់ទី ១៥ (Gen 15)',
            'intake_year' => '2024',
            'year_level' => 3,
            'status' => 'inactive',
            'student_code' => 'INACT001',
        ]);

        $class = ClassModel::create([
            'user_id' => $lecturer->id,
            'subject_name' => 'Active Cohort Only',
            'subject_code' => 'STAT101',
            'department' => $dept,
            'year_level' => 3,
            'qr_token' => 'QR-STAT-101',
            'is_qr_active' => true,
        ]);

        // Class student_count and roster count ONLY active student (1)
        $classes = $this->actingAs($admin)->getJson('/api/classes')->assertStatus(200)->json('data');
        $found = collect($classes)->firstWhere('id', $class->id);
        $this->assertEquals(1, $found['student_count']);

        $roster = $this->actingAs($lecturer)->getJson("/api/classes/{$class->id}/students")->assertStatus(200)->json('data');
        $this->assertCount(1, $roster);
        $this->assertEquals($activeStu->id, $roster[0]['id']);

        // Graduated & Inactive students cannot see or scan active classes
        $this->assertCount(0, $this->actingAs($gradStu)->getJson('/api/student/classes')->json('data'));
        $this->assertCount(0, $this->actingAs($inactStu)->getJson('/api/student/classes')->json('data'));
        $this->actingAs($gradStu)->postJson('/api/attendances/scan', ['qr_token' => 'QR-STAT-101'])->assertStatus(403);
        $this->actingAs($inactStu)->postJson('/api/attendances/scan', ['qr_token' => 'QR-STAT-101'])->assertStatus(403);

        // Active student CAN scan
        $this->actingAs($activeStu)->postJson('/api/attendances/scan', ['qr_token' => 'QR-STAT-101'])->assertStatus(200);

        // Bulk status update marks activeStu & inactStu as graduated too (2 modified, gradStu already graduated) -> all 3 remain counted in Admin report!
        $this->actingAs($admin)->postJson('/api/students/bulk-status', [
            'department' => $dept,
            'status' => 'graduated',
        ])->assertStatus(200)
            ->assertJson(['updated_count' => 2]);

        $stats = $this->actingAs($admin)->getJson('/api/admin/reports/student-stats?department=' . urlencode($dept))
            ->assertStatus(200)
            ->json('data');
        $this->assertEquals(3, $stats['summary']['total_students']);
        $this->assertEquals(3, $stats['summary']['graduated_count']);
    }
}
