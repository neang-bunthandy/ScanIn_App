<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('campus_settings', function (Blueprint $table) {
            $table->id();
            $table->string('campus_name')->default('សាកលវិទ្យាល័យ (Main Campus)');
            $table->decimal('campus_lat', 10, 7)->nullable();
            $table->decimal('campus_lng', 10, 7)->nullable();
            $table->integer('allowed_radius_meters')->default(65);
            $table->boolean('enforce_gps')->default(false);
            $table->timestamps();
        });

        Schema::table('attendances', function (Blueprint $table) {
            $table->decimal('scan_lat', 10, 7)->nullable()->after('note');
            $table->decimal('scan_lng', 10, 7)->nullable()->after('scan_lat');
            $table->integer('distance_meters')->nullable()->after('scan_lng');
        });
    }

    public function down(): void
    {
        Schema::table('attendances', function (Blueprint $table) {
            $table->dropColumn(['scan_lat', 'scan_lng', 'distance_meters']);
        });

        Schema::dropIfExists('campus_settings');
    }
};
