<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;

class MakeAdmin extends Command
{
    /**
     * The name and signature of the console command.
     */
    protected $signature = 'make:admin';

    /**
     * The console command description.
     */
    protected $description = 'Create a new Master Admin account for ScanIn system';

    public function handle()
    {
        $this->info("==================================================");
        $this->info("       CREATE MASTER ADMIN (SCANIN SYSTEM)        ");
        $this->info("==================================================");

        // 1. Ask for Admin Name
        $name = $this->ask('Enter Admin Full Name');
        while (empty(trim($name))) {
            $this->error('Admin name cannot be empty!');
            $name = $this->ask('Enter Admin Full Name');
        }

        // 2. Ask for Admin Email
        $email = strtolower(trim($this->ask('Enter Admin Email Address')));
        while (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $this->error('Invalid email format! (e.g. admin@school.edu.kh)');
            $email = strtolower(trim($this->ask('Enter Admin Email Address')));
        }

        // Check if email already exists
        if (User::where('email', $email)->exists()) {
            if (!$this->confirm("User with email [$email] already exists. Do you want to update their password and promote to Admin?")) {
                $this->warn('Operation cancelled by user.');
                return 0;
            }
        }

        // 3. Ask for Password (hidden typing)
        $password = $this->secret('Enter Password (minimum 6 characters)');
        while (strlen($password) < 6) {
            $this->error('Password must be at least 6 characters long!');
            $password = $this->secret('Enter Password (minimum 6 characters)');
        }

        // 4. Confirm Password
        $confirmPassword = $this->secret('Confirm Password');
        if ($password !== $confirmPassword) {
            $this->error('Passwords do not match! Please try again.');
            return 1;
        }

        // 5. Save to MySQL Database
        $user = User::updateOrCreate(
            ['email' => $email],
            [
                'name' => trim($name),
                'password' => Hash::make($password),
                'role' => 'admin',
                'status' => 'active',
            ]
        );

        $this->newLine();
        $this->info("--------------------------------------------------");
        $this->info("SUCCESS: Master Admin account created successfully!");
        $this->info("Email: " . $user->email);
        $this->info("Name:  " . $user->name);
        $this->info("Role:  " . $user->role);
        $this->info("--------------------------------------------------");
        $this->info("You can now log in to the Web Admin Portal using these credentials.");

        return 0;
    }
}
