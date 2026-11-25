<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CampusSetting;
use Illuminate\Http\Request;

class CampusSettingController extends Controller
{
    /**
     * មើលការកំណត់ទីតាំង GPS សាលាបច្ចុប្បន្ន
     */
    public function show()
    {
        return response()->json([
            'status' => true,
            'data' => CampusSetting::current(),
        ], 200);
    }

    /**
     * កែប្រែការកំណត់ទីតាំង GPS សាលា (Admin / Sub-Admin Only)
     */
    public function update(Request $request)
    {
        if (!$request->user() || !$request->user()->isAcademicAdmin()) {
            return response()->json([
                'status' => false,
                'message' => 'មានតែអ្នកគ្រប់គ្រង (Admin) ប៉ុណ្ណោះដែលអាចកំណត់ទីតាំង GPS សាលាបាន។',
            ], 403);
        }

        $validated = $request->validate([
            'campus_name' => 'nullable|string|max:255',
            'campus_lat' => 'nullable|numeric|between:-90,90',
            'campus_lng' => 'nullable|numeric|between:-180,180',
            'allowed_radius_meters' => 'required|integer|min:10|max:5000',
            'enforce_gps' => 'required|boolean',
        ]);

        if (!empty($validated['enforce_gps']) && ($validated['campus_lat'] === null || $validated['campus_lng'] === null)) {
            return response()->json([
                'status' => false,
                'message' => 'សូមបញ្ចូល Latitude និង Longitude របស់សាលាជាមុនសិន មុននឹងបើកដំណើរការ GPS Geofencing។',
            ], 422);
        }

        $setting = CampusSetting::current();
        $setting->update([
            'campus_name' => $validated['campus_name'] ?? $setting->campus_name,
            'campus_lat' => $validated['campus_lat'] ?? $setting->campus_lat,
            'campus_lng' => $validated['campus_lng'] ?? $setting->campus_lng,
            'allowed_radius_meters' => (int)$validated['allowed_radius_meters'],
            'enforce_gps' => (bool)$validated['enforce_gps'],
        ]);

        return response()->json([
            'status' => true,
            'message' => 'បានរក្សាទុកការកំណត់ទីតាំង GPS សាលាដោយជោគជ័យ!',
            'data' => $setting->fresh(),
        ], 200);
    }
}
