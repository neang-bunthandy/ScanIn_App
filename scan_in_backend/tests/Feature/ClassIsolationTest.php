<?php
// Automated test suite: ClassIsolationTest.php.

namespace Tests\Feature;

use App\Models\ClassModel;
use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class ClassIsolationTest extends TestCase
{
    use DatabaseTransactions;

    public function test_unauthenticated_request_to_classes_is_rejected(): void
    {
        $this->getJson('/api/classes')->assertStatus(401);
        $this->getJson('/api/lecturers')->assertStatus(401);
        $this->getJson('/api/students')->assertStatus(401);
    }

    public function test_lecturer_only_sees_and_controls_own_classes(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $dara = User::factory()->create([
            'name' => 'Chan Dara',
            'role' => 'lecturer',
            'password' => Hash::make('secret123'),
        ]);
        $otherLecturer = User::factory()->create([
            'name' => 'Oun Bong',
            'role' => 'lecturer',
            'password' => Hash::make('secret123'),
        ]);

        $daraClass = ClassModel::create([
            'user_id' => $dara->id,
            'subject_name' => 'Database Systems',
            'subject_code' => 'TESTDB01',
            'room' => 'R101',
            'qr_token' => 'TOKEN-DARA-1',
            'is_qr_active' => false,
        ]);

        $otherClass = ClassModel::create([
            'user_id' => $otherLecturer->id,
            'subject_name' => 'Other Subject',
            'subject_code' => 'TESTOT01',
            'room' => 'R202',
            'qr_token' => 'TOKEN-OTHER-1',
            'is_qr_active' => false,
        ]);

        $adminClasses = $this->actingAs($admin)->getJson('/api/classes')
            ->assertStatus(200)
            ->json('data');
        $adminIds = collect($adminClasses)->pluck('id')->all();
        $this->assertContains($daraClass->id, $adminIds);
        $this->assertContains($otherClass->id, $adminIds);

        $daraClasses = $this->actingAs($dara)->getJson('/api/classes')
            ->assertStatus(200)
            ->json('data');
        $this->assertCount(1, $daraClasses);
        $this->assertEquals($daraClass->id, $daraClasses[0]['id']);

        $otherClasses = $this->actingAs($otherLecturer)->getJson('/api/classes')
            ->assertStatus(200)
            ->json('data');
        $this->assertCount(1, $otherClasses);
        $this->assertEquals($otherClass->id, $otherClasses[0]['id']);

        $this->actingAs($dara)->getJson("/api/classes/{$otherClass->id}/attendances")
            ->assertStatus(403);
        $this->actingAs($dara)->postJson("/api/classes/{$otherClass->id}/toggle-qr", ['is_qr_active' => true])
            ->assertStatus(403);

        $this->actingAs($dara)->getJson("/api/classes/{$daraClass->id}/attendances")
            ->assertStatus(200);
        $this->actingAs($dara)->postJson("/api/classes/{$daraClass->id}/toggle-qr", ['is_qr_active' => true])
            ->assertStatus(200);
    }

    public function test_admin_can_create_class_with_class_date_and_filter_by_date(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $lecturer = User::factory()->create(['role' => 'lecturer']);

        $createRes = $this->actingAs($admin)->postJson('/api/classes', [
            'subject_name' => 'Data Mining With Python',
            'subject_code' => 'IT001',
            'lecturer_id' => $lecturer->id,
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'room' => 'Room 112',
            'day_of_week' => 'សៅរ៍ (Sat)',
            'time' => '07:00 - 08:30',
            'class_date' => '2026-11-14',
            'semester' => '1',
            'academic_year' => '2026-2027',
        ])->assertStatus(201)->json('data');

        $classId = $createRes['id'];
        $this->assertEquals('2026-11-14', $createRes['class_date']);

        $listRes = $this->actingAs($admin)->getJson('/api/classes')
            ->assertStatus(200)->json('data');
        $found = collect($listRes)->firstWhere('id', $classId);
        $this->assertEquals('2026-11-14', $found['class_date']);

        $filteredMatch = $this->actingAs($admin)->getJson('/api/classes?date=2026-11-14')
            ->assertStatus(200)->json('data');
        $this->assertNotEmpty(collect($filteredMatch)->where('id', $classId));

        $filteredMismatch = $this->actingAs($admin)->getJson('/api/classes?date=2026-11-21')
            ->assertStatus(200)->json('data');
        $this->assertEmpty(collect($filteredMismatch)->where('id', $classId));

        $this->actingAs($admin)->putJson("/api/classes/{$classId}", [
            'class_date' => '2026-11-21',
        ])->assertStatus(200);

        $updatedFound = $this->actingAs($admin)->getJson('/api/classes?date=2026-11-21')
            ->assertStatus(200)->json('data');
        $this->assertNotEmpty(collect($updatedFound)->where('id', $classId));
    }
}
