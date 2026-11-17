<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     *
     * In Production, the initial Master Admin is provisioned via:
     *   php artisan make:admin
     *
     * Subsequent lecturers, classes, and students are provisioned by
     * the Master Admin via the Web Admin Portal.
     */
    public function run(): void
    {
        // Clean production: No hardcoded demo seed accounts.
    }
}
