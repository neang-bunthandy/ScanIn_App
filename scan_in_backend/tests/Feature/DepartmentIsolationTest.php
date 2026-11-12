<?php

namespace Tests\Feature;

use App\Models\ClassModel;
use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class DepartmentIsolationTest extends TestCase
{
    use DatabaseTransactions;

    public function test_student_only_sees_classes_matching_own_department(): void
    {
        $lecturer = User::factory()->create([
            'role' => 'lecturer',
            'password' => Hash::make('secret123'),
        ]);

        $itStudent = User::factory()->create([
            'role' => 'student',
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'student_code' => 'TESTIT001',
            'password' => Hash::make('secret123'),
        ]);

        $csStudent = User::factory()->create([
            'role' => 'student',
            'department' => 'វិទ្យាសាស្ត្រកុំព្យូទ័រ (CS)',
            'student_code' => 'TESTCS001',
            'password' => Hash::make('secret123'),
        ]);

        $noDeptStudent = User::factory()->create([
            'role' => 'student',
            'department' => null,
            'student_code' => 'TESTNO001',
            'password' => Hash::make('secret123'),
        ]);

        $itClass = ClassModel::create([
            'user_id' => $lecturer->id,
            'subject_name' => 'IT Networking',
            'subject_code' => 'DEPTIT01',
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'room' => 'Room 101',
            'qr_token' => 'QR-DEPT-IT-01',
            'is_qr_active' => true,
        ]);

        $csClass = ClassModel::create([
            'user_id' => $lecturer->id,
            'subject_name' => 'CS Algorithms',
            'subject_code' => 'DEPTCS01',
            'department' => 'វិទ្យាសាស្ត្រកុំព្យូទ័រ (CS)',
            'room' => 'Room 202',
            'qr_token' => 'QR-DEPT-CS-01',
            'is_qr_active' => true,
        ]);

        $nullDeptClass = ClassModel::create([
            'user_id' => $lecturer->id,
            'subject_name' => 'Unassigned Subject',
            'subject_code' => 'DEPTNONE01',
            'department' => null,
            'room' => 'Room 303',
            'qr_token' => 'QR-DEPT-NONE-01',
            'is_qr_active' => true,
        ]);

        // IT student only sees IT class
        $itClasses = $this->actingAs($itStudent)->getJson('/api/student/classes')
            ->assertStatus(200)
            ->json('data');
        $itIds = collect($itClasses)->pluck('id')->all();
        $this->assertContains($itClass->id, $itIds);
        $this->assertNotContains($csClass->id, $itIds);
        $this->assertNotContains($nullDeptClass->id, $itIds);

        // CS student only sees CS class
        $csClasses = $this->actingAs($csStudent)->getJson('/api/student/classes')
            ->assertStatus(200)
            ->json('data');
        $csIds = collect($csClasses)->pluck('id')->all();
        $this->assertContains($csClass->id, $csIds);
        $this->assertNotContains($itClass->id, $csIds);
        $this->assertNotContains($nullDeptClass->id, $csIds);

        // Student without department sees empty list
        $noneClasses = $this->actingAs($noDeptStudent)->getJson('/api/student/classes')
            ->assertStatus(200)
            ->json('data');
        $this->assertCount(0, $noneClasses);
    }

    public function test_student_cannot_scan_qr_from_different_department(): void
    {
        $lecturer = User::factory()->create([
            'role' => 'lecturer',
            'password' => Hash::make('secret123'),
        ]);

        $itStudent = User::factory()->create([
            'role' => 'student',
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'student_code' => 'SCANIT001',
            'password' => Hash::make('secret123'),
        ]);

        ClassModel::create([
            'user_id' => $lecturer->id,
            'subject_name' => 'CS Theory',
            'subject_code' => 'SCANCS01',
            'department' => 'វិទ្យាសាស្ត្រកុំព្យូទ័រ (CS)',
            'room' => 'Lab 1',
            'qr_token' => 'QR-SCAN-CS-999',
            'is_qr_active' => true,
        ]);

        ClassModel::create([
            'user_id' => $lecturer->id,
            'subject_name' => 'IT Web Dev',
            'subject_code' => 'SCANIT01',
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'room' => 'Lab 2',
            'qr_token' => 'QR-SCAN-IT-999',
            'is_qr_active' => true,
        ]);

        // Cross-department scan rejected (403)
        $this->actingAs($itStudent)->postJson('/api/attendances/scan', [
            'qr_token' => 'QR-SCAN-CS-999',
        ])->assertStatus(403);

        // Own department scan succeeds (200)
        $this->actingAs($itStudent)->postJson('/api/attendances/scan', [
            'qr_token' => 'QR-SCAN-IT-999',
        ])->assertStatus(200)
            ->assertJson(['status' => true]);
    }

    public function test_class_students_endpoint_and_student_count_match_real_db_department(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $owner = User::factory()->create([
            'role' => 'lecturer',
            'password' => Hash::make('secret123'),
        ]);
        $otherLecturer = User::factory()->create([
            'role' => 'lecturer',
            'password' => Hash::make('secret123'),
        ]);

        $uniqueDept = 'TestDept-Unique-X99';
        $studentA = User::factory()->create([
            'role' => 'student',
            'department' => $uniqueDept,
            'student_code' => 'UNIQ001',
            'password' => Hash::make('secret123'),
        ]);
        $studentB = User::factory()->create([
            'role' => 'student',
            'department' => $uniqueDept,
            'student_code' => 'UNIQ002',
            'password' => Hash::make('secret123'),
        ]);
        User::factory()->create([
            'role' => 'student',
            'department' => 'Other-Dept-Y88',
            'student_code' => 'OTHER001',
            'password' => Hash::make('secret123'),
        ]);

        $class = ClassModel::create([
            'user_id' => $owner->id,
            'subject_name' => 'Unique Dept Subject',
            'subject_code' => 'UNIQ101',
            'department' => $uniqueDept,
            'room' => 'R505',
            'qr_token' => 'QR-UNIQ-101',
            'is_qr_active' => true,
        ]);

        // Student A scans attendance
        $this->actingAs($studentA)->postJson('/api/attendances/scan', [
            'qr_token' => 'QR-UNIQ-101',
        ])->assertStatus(200);

        // Lecturer sees dynamic student_count = 2 matching uniqueDept students
        $lecClasses = $this->actingAs($owner)->getJson('/api/classes')
            ->assertStatus(200)
            ->json('data');
        $foundClass = collect($lecClasses)->firstWhere('id', $class->id);
        $this->assertNotNull($foundClass);
        $this->assertEquals(2, $foundClass['student_count']);

        // Owner lecturer & Admin can fetch class students with today_status
        $roster = $this->actingAs($owner)->getJson("/api/classes/{$class->id}/students")
            ->assertStatus(200)
            ->json('data');
        $this->assertCount(2, $roster);

        $rowA = collect($roster)->firstWhere('id', $studentA->id);
        $rowB = collect($roster)->firstWhere('id', $studentB->id);
        $this->assertEquals('present', $rowA['today_status']);
        $this->assertNull($rowB['today_status']);

        $this->actingAs($admin)->getJson("/api/classes/{$class->id}/students")
            ->assertStatus(200);

        // Student & other lecturer are blocked (403)
        $this->actingAs($studentA)->getJson("/api/classes/{$class->id}/students")
            ->assertStatus(403);
        $this->actingAs($otherLecturer)->getJson("/api/classes/{$class->id}/students")
            ->assertStatus(403);
    }
}
