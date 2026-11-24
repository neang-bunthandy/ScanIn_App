<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AvatarUploadTest extends TestCase
{
    use DatabaseTransactions;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('public');
    }

    /**
     * Helper to create a valid 1x1 PNG file without requiring GD extension
     */
    private function createFakeImage(string $name = 'avatar.png'): UploadedFile
    {
        $pngContent = base64_decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');
        return UploadedFile::fake()->createWithContent($name, $pngContent);
    }

    public function test_authenticated_student_can_upload_avatar(): void
    {
        $student = User::create([
            'name' => 'Student Test Avatar',
            'email' => 'student_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'student',
            'student_code' => 'STU-' . rand(100, 999),
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'status' => 'active',
        ]);

        Sanctum::actingAs($student);

        $file = $this->createFakeImage('profile.png');

        $response = $this->postJson('/api/profile/avatar', [
            'avatar' => $file,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
                'message' => 'បានផ្លាស់ប្តូររូបថត Profile ដោយជោគជ័យ',
            ])
            ->assertJsonStructure([
                'status',
                'message',
                'avatar_url',
                'user' => [
                    'id',
                    'name',
                    'email',
                    'avatar_url',
                ],
            ]);

        $student->refresh();
        $this->assertNotNull($student->avatar_url);
        $this->assertStringStartsWith('/storage/avatars/', $student->avatar_url);

        $relativePath = str_replace('/storage/', '', $student->avatar_url);
        Storage::disk('public')->assertExists($relativePath);
    }

    public function test_authenticated_lecturer_can_upload_avatar(): void
    {
        $lecturer = User::create([
            'name' => 'Lecturer Test Avatar',
            'email' => 'lecturer_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'lecturer',
            'staff_id' => 'STF-' . rand(100, 999),
            'department' => 'ព័ត៌មានវិទ្យា (IT)',
            'status' => 'active',
        ]);

        Sanctum::actingAs($lecturer);

        $file = $this->createFakeImage('lecturer_avatar.png');

        $response = $this->postJson('/api/profile/avatar', [
            'avatar' => $file,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
            ]);

        $lecturer->refresh();
        $this->assertNotNull($lecturer->avatar_url);
    }

    public function test_upload_avatar_validates_image_file(): void
    {
        $user = User::create([
            'name' => 'User Non Image',
            'email' => 'non_image_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'student',
        ]);

        Sanctum::actingAs($user);

        $file = UploadedFile::fake()->create('document.pdf', 100, 'application/pdf');

        $response = $this->postJson('/api/profile/avatar', [
            'avatar' => $file,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['avatar']);
    }

    public function test_unauthenticated_request_is_rejected(): void
    {
        $file = $this->createFakeImage('guest.png');

        $response = $this->postJson('/api/profile/avatar', [
            'avatar' => $file,
        ]);

        $response->assertStatus(401);
    }

    public function test_previous_avatar_file_is_cleaned_up_on_new_upload(): void
    {
        $user = User::create([
            'name' => 'User Replace Avatar',
            'email' => 'replace_' . Str::random(6) . '@scanin.test',
            'password' => Hash::make('password123'),
            'role' => 'student',
        ]);

        Sanctum::actingAs($user);

        // Upload first avatar
        $firstFile = $this->createFakeImage('first.png');
        $this->postJson('/api/profile/avatar', ['avatar' => $firstFile]);

        $user->refresh();
        $firstAvatarPath = str_replace('/storage/', '', $user->avatar_url);
        Storage::disk('public')->assertExists($firstAvatarPath);

        // Upload second avatar
        $secondFile = $this->createFakeImage('second.png');
        $this->postJson('/api/profile/avatar', ['avatar' => $secondFile]);

        $user->refresh();
        $secondAvatarPath = str_replace('/storage/', '', $user->avatar_url);
        Storage::disk('public')->assertExists($secondAvatarPath);

        // The first file should have been deleted
        Storage::disk('public')->assertMissing($firstAvatarPath);
    }
}
