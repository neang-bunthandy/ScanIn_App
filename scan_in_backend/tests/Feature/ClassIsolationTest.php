<?php

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

        // Admin sees both classes
        $adminClasses = $this->actingAs($admin)->getJson('/api/classes')
            ->assertStatus(200)
            ->json('data');
        $adminIds = collect($adminClasses)->pluck('id')->all();
        $this->assertContains($daraClass->id, $adminIds);
        $this->assertContains($otherClass->id, $adminIds);

        // Dara ONLY sees daraClass, NOT otherClass
        $daraClasses = $this->actingAs($dara)->getJson('/api/classes')
            ->assertStatus(200)
            ->json('data');
        $this->assertCount(1, $daraClasses);
        $this->assertEquals($daraClass->id, $daraClasses[0]['id']);

        // Other lecturer ONLY sees otherClass, NOT daraClass
        $otherClasses = $this->actingAs($otherLecturer)->getJson('/api/classes')
            ->assertStatus(200)
            ->json('data');
        $this->assertCount(1, $otherClasses);
        $this->assertEquals($otherClass->id, $otherClasses[0]['id']);

        // Dara cannot view attendances or toggle QR of otherClass (403)
        $this->actingAs($dara)->getJson("/api/classes/{$otherClass->id}/attendances")
            ->assertStatus(403);
        $this->actingAs($dara)->postJson("/api/classes/{$otherClass->id}/toggle-qr", ['is_qr_active' => true])
            ->assertStatus(403);

        // Dara CAN view attendances and toggle QR of daraClass (200)
        $this->actingAs($dara)->getJson("/api/classes/{$daraClass->id}/attendances")
            ->assertStatus(200);
        $this->actingAs($dara)->postJson("/api/classes/{$daraClass->id}/toggle-qr", ['is_qr_active' => true])
            ->assertStatus(200);
    }
}
