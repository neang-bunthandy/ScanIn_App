<?php

namespace Database\Seeders;

use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. គណនីគ្រូបង្រៀន (Lecturer)
        $lecturer = User::updateOrCreate(
            ['email' => 'dara@scanin.app'],
            [
                'name' => 'លោកគ្រូ ចាន់ ដារ៉ា',
                'password' => bcrypt('223232323'),
                'role' => 'lecturer',
                'staff_id' => 'STF001',
                'department' => 'វិទ្យាសាស្ត្រកុំព្យូទ័រ (CS)',
                'phone' => '012 345 678',
            ]
        );

        // បង្កើតថ្នាក់រៀនគំរូសម្រាប់គ្រូ (Sample Classes)
        \App\Models\ClassModel::updateOrCreate(
            ['subject_code' => 'CS101', 'user_id' => $lecturer->id],
            [
                'subject_name' => 'Mobile Application Development',
                'room' => 'Lab 3 (អគារ A)',
                'day_of_week' => 'ចន្ទ',
                'time' => '08:00 - 10:30',
                'semester' => 'ឆមាសទី ១',
                'academic_year' => '2026-2027',
                'student_count' => 32,
                'completed_sessions' => 6,
                'total_sessions' => 15,
                'description' => 'សិក្សាអំពីការអភិវឌ្ឍន៍កម្មវិធីទូរស័ព្ទដោយប្រើប្រាស់ Flutter & Dart',
                'is_qr_active' => true,
                'qr_token' => 'SCANIN-CS101-W06',
            ]
        );

        \App\Models\ClassModel::updateOrCreate(
            ['subject_code' => 'CS202', 'user_id' => $lecturer->id],
            [
                'subject_name' => 'Database Management Systems',
                'room' => 'Room 402 (អគារ B)',
                'day_of_week' => 'ពុធ',
                'time' => '13:30 - 16:00',
                'semester' => 'ឆមាសទី ១',
                'academic_year' => '2026-2027',
                'student_count' => 28,
                'completed_sessions' => 5,
                'total_sessions' => 15,
                'description' => 'សិក្សាអំពីប្រព័ន្ធគ្រប់គ្រងមូលដ្ឋានទិន្នន័យ MySQL និង Relational Design',
                'is_qr_active' => false,
                'qr_token' => 'SCANIN-CS202-W05',
            ]
        );

        // 2. គណនីនិស្សិត (Student)
        User::updateOrCreate(
            ['email' => 'student@scanin.app'],
            [
                'name' => 'សុខា ម៉េង',
                'password' => bcrypt('12345678'),
                'role' => 'student',
                'student_code' => 'STU001',
                'department' => 'ព័ត៌មានវិទ្យា (IT)',
                'phone' => '098 765 432',
            ]
        );

        // 3. គណនី Admin
        User::updateOrCreate(
            ['email' => 'admin@scanin.app'],
            [
                'name' => 'Admin System',
                'password' => bcrypt('password123'),
                'role' => 'admin',
                'staff_id' => 'ADM001',
                'department' => 'Academic Affairs',
                'phone' => '011 223 344',
            ]
        );
    }
}
