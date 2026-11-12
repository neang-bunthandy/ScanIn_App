<?php

namespace Tests\Feature;

use App\Models\ClassModel;
use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class DualNameUsersTest extends TestCase
{
    use DatabaseTransactions;

    public function test_admin_can_create_and_update_lecturer_with_khmer_and_latin_names(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);

        $createRes = $this->actingAs($admin)->postJson('/api/lecturers', [
            'name' => 'លោកគ្រូ សុខ វិបុល',
            'latin_name' => 'Sok Vibol',
            'email' => 'vibol.dual@scanin.app',
            'password' => 'secret123',
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'staff_id' => 'LEC-DUAL1',
        ])->assertStatus(201)->json('data');

        $this->assertEquals('លោកគ្រូ សុខ វិបុល', $createRes['name']);
        $this->assertEquals('Sok Vibol', $createRes['latin_name']);

        // Update both names
        $this->actingAs($admin)->putJson("/api/lecturers/{$createRes['id']}", [
            'name' => 'សាស្ត្រាចារ្យ សុខ វិបុល',
            'latin_name' => 'Prof. Sok Vibol',
            'email' => 'vibol.dual@scanin.app',
        ])->assertStatus(200);

        $lecturers = $this->actingAs($admin)->getJson('/api/lecturers')
            ->assertStatus(200)
            ->json('data');
        $found = collect($lecturers)->firstWhere('id', $createRes['id']);
        $this->assertEquals('សាស្ត្រាចារ្យ សុខ វិបុល', $found['name']);
        $this->assertEquals('Prof. Sok Vibol', $found['latin_name']);

        // Auth me/login includes latin_name
        $loginRes = $this->postJson('/api/login', [
            'email' => 'vibol.dual@scanin.app',
            'password' => 'secret123',
        ])->assertStatus(200);
        $this->assertEquals('Prof. Sok Vibol', $loginRes->json('user.latin_name'));
    }

    public function test_admin_can_create_update_and_list_student_with_khmer_and_latin_names(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $lecturer = User::factory()->create([
            'role' => 'lecturer',
            'password' => Hash::make('secret123'),
        ]);

        $dept = 'ព័ត៌មានវិទ្យា (IT)';
        $class = ClassModel::create([
            'user_id' => $lecturer->id,
            'subject_name' => 'Khmer & Latin Test',
            'subject_code' => 'DUAL101',
            'department' => $dept,
        ]);

        $createRes = $this->actingAs($admin)->postJson('/api/students', [
            'name' => 'សិស្ស កែវ ចន្ទ្រា',
            'latin_name' => 'Keo Chantrea',
            'email' => 'chantrea.dual@scanin.app',
            'password' => 'secret123',
            'student_code' => 'STUDUAL01',
            'department' => $dept,
        ])->assertStatus(201)->json('data');

        $this->assertEquals('សិស្ស កែវ ចន្ទ្រា', $createRes['name']);
        $this->assertEquals('Keo Chantrea', $createRes['latin_name']);

        $this->actingAs($admin)->putJson("/api/students/{$createRes['id']}", [
            'name' => 'កែវ ចន្ទ្រា',
            'latin_name' => 'KEO CHANTREA',
            'email' => 'chantrea.dual@scanin.app',
            'student_code' => 'STUDUAL01',
            'department' => $dept,
        ])->assertStatus(200);

        $roster = $this->actingAs($lecturer)->getJson("/api/classes/{$class->id}/students")
            ->assertStatus(200)
            ->json('data');
        $found = collect($roster)->firstWhere('id', $createRes['id']);
        $this->assertEquals('កែវ ចន្ទ្រា', $found['name']);
        $this->assertEquals('KEO CHANTREA', $found['latin_name']);
    }
}

