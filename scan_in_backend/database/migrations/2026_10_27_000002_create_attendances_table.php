<?php
// Database migration: 2026_10_27_000002_create_attendances_table.php.

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{

    public function up(): void
    {
        Schema::create('attendances', function (Blueprint $table) {
            $table->id();
            $table->foreignId('class_id')->constrained('classes')->onDelete('cascade');
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->enum('status', ['present', 'late', 'absent'])->default('present');
            $table->date('date');
            $table->timestamp('scanned_at')->nullable();
            $table->string('note')->nullable();
            $table->timestamps();

            $table->unique(['class_id', 'user_id', 'date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('attendances');
    }
};
