<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CampusSetting extends Model
{
    protected $table = 'campus_settings';

    protected $fillable = [
        'campus_name',
        'campus_lat',
        'campus_lng',
        'allowed_radius_meters',
        'enforce_gps',
        'allow_face_id_checkin',
    ];

    protected $casts = [
        'campus_lat' => 'float',
        'campus_lng' => 'float',
        'allowed_radius_meters' => 'integer',
        'enforce_gps' => 'boolean',
        'allow_face_id_checkin' => 'boolean',
    ];

    /**
     * ទាញយកការកំណត់ទីតាំងសាលាបច្ចុប្បន្ន (Singleton Row)
     */
    public static function current(): self
    {
        $setting = self::first();
        if (!$setting) {
            $setting = self::create([
                'campus_name' => 'សាកលវិទ្យាល័យ (Main Campus)',
                'allowed_radius_meters' => 65,
                'enforce_gps' => false,
                'allow_face_id_checkin' => true,
            ]);
        }
        return $setting;
    }

    /**
     * គណនាចម្ងាយជាម៉ែត្ររវាងចំណុច GPS ទាំង ២ ដោយប្រើរូបមន្ត Haversine
     */
    public static function calculateDistanceMeters(
        float $lat1,
        float $lng1,
        float $lat2,
        float $lng2
    ): float {
        $earthRadiusMeters = 6371000.0;

        $dLat = deg2rad($lat2 - $lat1);
        $dLng = deg2rad($lng2 - $lng1);

        $a = sin($dLat / 2) * sin($dLat / 2)
            + cos(deg2rad($lat1)) * cos(deg2rad($lat2))
            * sin($dLng / 2) * sin($dLng / 2);

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return $earthRadiusMeters * $c;
    }
}
