<?php
// Database migration: 2026_11_12_000003_add_generation_and_year_level_to_users_and_classes.php.

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{

    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('generation')->nullable()->after('department');
            $table->string('intake_year', 20)->nullable()->after('generation');
            $table->unsignedTinyInteger('year_level')->nullable()->after('intake_year');
        });

        Schema::table('classes', function (Blueprint $table) {
            $table->string('generation')->nullable()->after('department');
            $table->unsignedTinyInteger('year_level')->nullable()->after('generation');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['generation', 'intake_year', 'year_level']);
        });

        Schema::table('classes', function (Blueprint $table) {
            $table->dropColumn(['generation', 'year_level']);
        });
    }
};
