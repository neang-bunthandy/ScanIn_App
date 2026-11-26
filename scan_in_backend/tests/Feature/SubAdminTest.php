<?php
// Automated test suite: SubAdminTest.php.

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Tests\TestCase;

class SubAdminTest extends TestCase
{
    use DatabaseTransactions;

    private function createMasterAdmin(): User
    {
        return User::create([
            'name' => 'Master Admin Test',
            'email' => 'master_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'admin',
            'status' => 'active',
        ]);
    }

    private function createSubAdmin(): User
    {
        return User::create([
            'name' => 'Sub Admin Test',
            'latin_name' => 'Sub Admin Test',
            'email' => 'subadmin_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'sub_admin',
            'department' => 'Academic Affairs',
            'status' => 'active',
        ]);
    }

    public function test_master_admin_can_create_sub_admin(): void
    {
        $master = $this->createMasterAdmin();

        $response = $this->actingAs($master)->postJson('/api/sub-admins', [
            'name' => 'ស៊ុន ចាន់ដា',
            'latin_name' => 'Sun Chanda',
            'email' => 'chanda_' . Str::random(6) . '@scanin.test',
            'password' => 'password123',
            'department' => 'ការិយាល័យសិក្សា (Academic Affairs)',
            'phone' => '012 999 888',
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'status' => true,
                'data' => [
                    'name' => 'ស៊ុន ចាន់ដា',
                    'latin_name' => 'Sun Chanda',
                    'role' => 'sub_admin',
                    'department' => 'ការិយាល័យសិក្សា (Academic Affairs)',
                ],
            ]);

        $this->assertDatabaseHas('users', [
            'name' => 'ស៊ុន ចាន់ដា',
            'role' => 'sub_admin',
        ]);
    }

    public function test_master_admin_can_list_and_update_sub_admins(): void
    {
        $master = $this->createMasterAdmin();
        $sub = $this->createSubAdmin();

        $listResponse = $this->actingAs($master)->getJson('/api/sub-admins');
        $listResponse->assertStatus(200)
            ->assertJson(['status' => true]);

        $subAdminIds = collect($listResponse->json('data'))->pluck('id')->all();
        $this->assertContains($sub->id, $subAdminIds);

        $updateResponse = $this->actingAs($master)->putJson("/api/sub-admins/{$sub->id}", [
            'name' => 'Sub Admin Updated',
            'phone' => '099 111 222',
        ]);

        $updateResponse->assertStatus(200)
            ->assertJson([
                'status' => true,
                'data' => [
                    'id' => $sub->id,
                    'name' => 'Sub Admin Updated',
                    'phone' => '099 111 222',
                ],
            ]);
    }

    public function test_master_admin_can_delete_sub_admin(): void
    {
        $master = $this->createMasterAdmin();
        $sub = $this->createSubAdmin();

        $deleteResponse = $this->actingAs($master)->deleteJson("/api/sub-admins/{$sub->id}");
        $deleteResponse->assertStatus(200)
            ->assertJson(['status' => true]);

        $this->assertDatabaseMissing('users', ['id' => $sub->id]);
    }

    public function test_master_admin_cannot_delete_self_or_other_master_admin(): void
    {
        $master1 = $this->createMasterAdmin();
        $master2 = $this->createMasterAdmin();

        $response1 = $this->actingAs($master1)->deleteJson("/api/sub-admins/{$master1->id}");
        $response1->assertStatus(400);

        $response2 = $this->actingAs($master1)->deleteJson("/api/sub-admins/{$master2->id}");
        $response2->assertStatus(403);
    }

    public function test_sub_admin_cannot_access_sub_admin_management(): void
    {
        $sub = $this->createSubAdmin();

        $getResponse = $this->actingAs($sub)->getJson('/api/sub-admins');
        $getResponse->assertStatus(403);

        $postResponse = $this->actingAs($sub)->postJson('/api/sub-admins', [
            'name' => 'Hacker Sub',
            'email' => 'hacker@scanin.test',
            'password' => 'secret123',
        ]);
        $postResponse->assertStatus(403);
    }

    public function test_sub_admin_can_manage_classes_and_students(): void
    {
        $sub = $this->createSubAdmin();
        $lecturer = User::create([
            'name' => 'Teacher One',
            'email' => 'teacher_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'lecturer',
            'status' => 'active',
        ]);

        $createClassResponse = $this->actingAs($sub)->postJson('/api/classes', [
            'subject_name' => 'Computer Networks',
            'subject_code' => 'CN101',
            'lecturer_id' => $lecturer->id,
            'room' => 'Room 303',
            'day_of_week' => 'សៅរ៍ (Sat)',
            'time' => '07:00 - 08:30',
            'total_sessions' => 15,
        ]);
        $createClassResponse->assertStatus(201);

        $classId = $createClassResponse->json('data.id');

        $createStudentResponse = $this->actingAs($sub)->postJson('/api/students', [
            'name' => 'សិស្ស តេស្ត',
            'email' => 'stu_' . Str::random(6) . '@scanin.test',
            'password' => 'password123',
            'student_code' => 'STU-' . rand(1000, 9999),
        ]);
        $createStudentResponse->assertStatus(201);

        $deleteClassResponse = $this->actingAs($sub)->deleteJson("/api/classes/{$classId}");
        $deleteClassResponse->assertStatus(200);
    }

    public function test_sub_admin_can_create_and_manage_lecturers(): void
    {
        $sub = $this->createSubAdmin();
        $email = strtolower('lecturer_' . Str::random(6) . '@scanin.test');

        $createResponse = $this->actingAs($sub)->postJson('/api/lecturers', [
            'name' => 'លោកគ្រូ តេស្ត សាប់អាដមីន',
            'latin_name' => 'Test Lecturer SubAdmin',
            'email' => $email,
            'password' => 'password123',
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'staff_id' => 'LEC-999',
            'phone' => '012 333 444',
        ]);

        $createResponse->assertStatus(201)
            ->assertJson([
                'status' => true,
                'data' => [
                    'name' => 'លោកគ្រូ តេស្ត សាប់អាដមីន',
                    'email' => $email,
                    'role' => 'lecturer',
                ],
            ]);

        $lecturerId = $createResponse->json('data.id');
        $this->assertDatabaseHas('users', ['id' => $lecturerId, 'role' => 'lecturer']);

        $listResponse = $this->actingAs($sub)->getJson('/api/lecturers');
        $listResponse->assertStatus(200);
        $ids = collect($listResponse->json('data'))->pluck('id')->all();
        $this->assertContains($lecturerId, $ids);

        $updateResponse = $this->actingAs($sub)->putJson("/api/lecturers/{$lecturerId}", [
            'name' => 'លោកគ្រូ តេស្ត កែប្រែ',
            'phone' => '099 888 777',
        ]);
        $updateResponse->assertStatus(200);
        $this->assertDatabaseHas('users', ['id' => $lecturerId, 'name' => 'លោកគ្រូ តេស្ត កែប្រែ']);

        $deleteResponse = $this->actingAs($sub)->deleteJson("/api/lecturers/{$lecturerId}");
        $deleteResponse->assertStatus(200);
        $this->assertDatabaseMissing('users', ['id' => $lecturerId]);
    }
}
