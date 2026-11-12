<?php

namespace Tests\Feature;

use App\Models\ClassModel;
use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class GenerationYearIsolationTest extends TestCase
{
    use DatabaseTransactions;

    public function test_students_only_see_and_scan_classes_for_their_own_year_level(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $lecturer = User::factory()->create([
            'role' => 'lecturer',
            'password' => Hash::make('secret123'),
        ]);

        $dept = 'ព័ត៌មានវិទ្យា (IT)';

        $year2Student = User::factory()->create([
            'role' => 'student',
            'department' => $dept,
            'generation' => 'ជំនាន់ទី ១៦ (Gen 16)',
            'intake_year' => '2025',
            'year_level' => 2,
            'student_code' => 'Y2STU01',
            'password' => Hash::make('secret123'),
        ]);

        $year3Student = User::factory()->create([
            'role' => 'student',
            'department' => $dept,
            'generation' => 'ជំនាន់ទី ១៥ (Gen 15)',
            'intake_year' => '2024',
            'year_level' => 3,
            'student_code' => 'Y3STU01',
            'password' => Hash::make('secret123'),
        ]);

        $classYear1 = ClassModel::create([
            'user_id' => $lecturer->id,
            'subject_name' => 'Intro IT (Y1)',
            'subject_code' => 'Y101',
            'department' => $dept,
            'year_level' => 1,
            'qr_token' => 'QR-Y1-01',
            'is_qr_active' => true,
        ]);

        $classYear2 = ClassModel::create([
            'user_id' => $lecturer->id,
            'subject_name' => 'Database Systems (Y2)',
            'subject_code' => 'Y201',
            'department' => $dept,
            'year_level' => 2,
            'qr_token' => 'QR-Y2-01',
            'is_qr_active' => true,
        ]);

        $classYear3 = ClassModel::create([
            'user_id' => $lecturer->id,
            'subject_name' => 'Mobile App Dev (Y3)',
            'subject_code' => 'Y301',
            'department' => $dept,
            'year_level' => 3,
            'qr_token' => 'QR-Y3-01',
            'is_qr_active' => true,
        ]);

        $classYear4 = ClassModel::create([
            'user_id' => $lecturer->id,
            'subject_name' => 'Senior Project (Y4)',
            'subject_code' => 'Y401',
            'department' => $dept,
            'year_level' => 4,
            'qr_token' => 'QR-Y4-01',
            'is_qr_active' => true,
        ]);

        // Year 3 student only sees Year 3 class (not Y1, Y2, Y4)
        $y3Classes = $this->actingAs($year3Student)->getJson('/api/student/classes')
            ->assertStatus(200)
            ->json('data');
        $y3Ids = collect($y3Classes)->pluck('id')->all();
        $this->assertContains($classYear3->id, $y3Ids);
        $this->assertNotContains($classYear1->id, $y3Ids);
        $this->assertNotContains($classYear2->id, $y3Ids);
        $this->assertNotContains($classYear4->id, $y3Ids);

        // Year 2 student only sees Year 2 class (not Y1, Y3, Y4)
        $y2Classes = $this->actingAs($year2Student)->getJson('/api/student/classes')
            ->assertStatus(200)
            ->json('data');
        $y2Ids = collect($y2Classes)->pluck('id')->all();
        $this->assertContains($classYear2->id, $y2Ids);
        $this->assertNotContains($classYear1->id, $y2Ids);
        $this->assertNotContains($classYear3->id, $y2Ids);
        $this->assertNotContains($classYear4->id, $y2Ids);

        // Year 3 student cannot scan Year 2 or Year 1 QR (403)
        $this->actingAs($year3Student)->postJson('/api/attendances/scan', [
            'qr_token' => 'QR-Y2-01',
        ])->assertStatus(403);

        // Year 3 student CAN scan Year 3 QR (200)
        $this->actingAs($year3Student)->postJson('/api/attendances/scan', [
            'qr_token' => 'QR-Y3-01',
        ])->assertStatus(200);

        // Admin /classes checks dynamic student_count per year_level
        $adminClasses = $this->actingAs($admin)->getJson('/api/classes')
            ->assertStatus(200)
            ->json('data');
        $foundY3 = collect($adminClasses)->firstWhere('id', $classYear3->id);
        $this->assertEquals(1, $foundY3['student_count']);

        $rosterY3 = $this->actingAs($lecturer)->getJson("/api/classes/{$classYear3->id}/students")
            ->assertStatus(200)
            ->json('data');
        $this->assertCount(1, $rosterY3);
        $this->assertEquals($year3Student->id, $rosterY3[0]['id']);
    }

    public function test_generation_restriction_and_student_promotion(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $lecturer = User::factory()->create([
            'role' => 'lecturer',
            'password' => Hash::make('secret123'),
        ]);

        $dept = 'GenTestDept-Unique';
        $gen15 = 'ជំនាន់ទី ១៥ (Gen 15)';
        $gen16 = 'ជំនាន់ទី ១៦ (Gen 16)';

        $stuGen15 = User::factory()->create([
            'role' => 'student',
            'department' => $dept,
            'generation' => $gen15,
            'intake_year' => '2024',
            'year_level' => 2,
            'student_code' => 'GEN15-01',
            'password' => Hash::make('secret123'),
        ]);

        $stuGen16 = User::factory()->create([
            'role' => 'student',
            'department' => $dept,
            'generation' => $gen16,
            'intake_year' => '2025',
            'year_level' => 2,
            'student_code' => 'GEN16-01',
            'password' => Hash::make('secret123'),
        ]);

        $gen15Class = ClassModel::create([
            'user_id' => $lecturer->id,
            'subject_name' => 'Gen 15 Special Lab',
            'subject_code' => 'GEN15L',
            'department' => $dept,
            'generation' => $gen15,
            'year_level' => 2,
            'qr_token' => 'QR-GEN15-LAB',
            'is_qr_active' => true,
        ]);

        // Only Gen 15 student can see & scan gen15Class
        $gen15Visible = collect($this->actingAs($stuGen15)->getJson('/api/student/classes')->json('data'))
            ->pluck('id')->all();
        $this->assertContains($gen15Class->id, $gen15Visible);

        $gen16Visible = collect($this->actingAs($stuGen16)->getJson('/api/student/classes')->json('data'))
            ->pluck('id')->all();
        $this->assertNotContains($gen15Class->id, $gen16Visible);

        $this->actingAs($stuGen16)->postJson('/api/attendances/scan', [
            'qr_token' => 'QR-GEN15-LAB',
        ])->assertStatus(403);

        // Admin promotes only Gen 16 from Year 2 to Year 3
        $promoteRes = $this->actingAs($admin)->postJson('/api/students/promote', [
            'department' => $dept,
            'generation' => $gen16,
        ])->assertStatus(200)
            ->json();
        $this->assertEquals(1, $promoteRes['promoted_count']);

        $this->assertEquals(3, $stuGen16->fresh()->year_level);
        $this->assertEquals(2, $stuGen15->fresh()->year_level);
    }
}

