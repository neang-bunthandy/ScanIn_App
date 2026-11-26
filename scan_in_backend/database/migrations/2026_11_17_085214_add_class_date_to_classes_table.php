<?php
// Database migration: 2026_11_17_085214_add_class_date_to_classes_table.php.

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{

    public function up(): void
    {
        Schema::table('classes', function (Blueprint $table) {
            $table->date('class_date')->nullable()->after('time')->index();
        });
    }

    public function down(): void
    {
        Schema::table('classes', function (Blueprint $table) {
            $table->dropIndex(['class_date']);
            $table->dropColumn('class_date');
        });
    }
};
