<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('device_id', 191)->nullable()->after('avatar_url');
        });

        Schema::table('campus_settings', function (Blueprint $table) {
            $table->boolean('allow_face_id_checkin')->default(true)->after('enforce_gps');
        });

        Schema::table('attendances', function (Blueprint $table) {
            $table->string('check_in_method', 32)->default('qr')->after('status');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('device_id');
        });

        Schema::table('campus_settings', function (Blueprint $table) {
            $table->dropColumn('allow_face_id_checkin');
        });

        Schema::table('attendances', function (Blueprint $table) {
            $table->dropColumn('check_in_method');
        });
    }
};
