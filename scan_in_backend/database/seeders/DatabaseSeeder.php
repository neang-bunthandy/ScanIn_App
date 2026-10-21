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
        User::updateOrCreate(
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
