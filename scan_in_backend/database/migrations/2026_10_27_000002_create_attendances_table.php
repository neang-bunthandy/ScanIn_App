<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('attendances', function (Blueprint $table) {
            $table->id();
            $table->foreignId('class_id')->constrained('classes')->onDelete('cascade');
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade'); // សិស្ស (Student)
            $table->enum('status', ['present', 'late', 'absent'])->default('present');
            $table->date('date');
            $table->timestamp('scanned_at')->nullable();
            $table->string('note')->nullable();
            $table->timestamps();

            // ការពារកុំឱ្យសិស្សម្នាក់ស្កេនវត្តមានជាន់គ្នាក្នុងថ្នាក់ដដែលក្នុងថ្ងៃតែមួយ
            $table->unique(['class_id', 'user_id', 'date']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('attendances');
    }
};
