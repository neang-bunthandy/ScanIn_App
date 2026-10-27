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
        Schema::create('classes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('subject_name');
            $table->string('subject_code');
            $table->string('room')->nullable();
            $table->string('day_of_week')->nullable();
            $table->string('time')->nullable();
            $table->string('semester')->default('ឆមាសទី ១');
            $table->string('academic_year')->default('2026-2027');
            $table->integer('student_count')->default(0);
            $table->integer('completed_sessions')->default(0);
            $table->integer('total_sessions')->default(15);
            $table->text('description')->nullable();
            $table->boolean('is_qr_active')->default(false);
            $table->string('qr_token')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('classes');
    }
};
