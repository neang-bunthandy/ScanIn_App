<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    /**
     * ស្ថិតិនិស្សិត និងប្រវត្តិតាមឆ្នាំចូលរៀន ជំនាន់ និងដេប៉ាតឺម៉ង់ (Admin Only)
     * រក្សាទុក និងរាប់សិស្សទាំងអស់ (active + graduated + inactive) ដើម្បីកុំឱ្យបាត់ទិន្នន័យប្រវត្តិសាស្ត្រ
     */
    public function studentStats(Request $request)
    {
        if (!$request->user() || $request->user()->role !== 'admin') {
            return response()->json([
                'status' => false,
                'message' => 'មានតែអ្នកគ្រប់គ្រង (Admin) ប៉ុណ្ណោះដែលអាចមើលរបាយការណ៍ស្ថិតិនេះបាន។',
            ], 403);
        }

        $allStudents = User::where('role', 'student')
            ->select('id', 'name', 'latin_name', 'student_code', 'gender', 'department', 'generation', 'intake_year', 'year_level', 'status', 'created_at')
            ->get();

        // Collect unfiltered options for dropdowns
        $allIntakeYears = $allStudents->pluck('intake_year')
            ->map(fn ($v) => trim((string)$v))
            ->filter(fn ($v) => $v !== '')
            ->unique()
            ->sortDesc()
            ->values()
            ->all();

        $allDepartments = $allStudents->pluck('department')
            ->map(fn ($v) => trim((string)$v))
            ->filter(fn ($v) => $v !== '')
            ->unique()
            ->sort()
            ->values()
            ->all();

        $allGenerations = $allStudents->pluck('generation')
            ->map(fn ($v) => trim((string)$v))
            ->filter(fn ($v) => $v !== '')
            ->unique()
            ->sortDesc()
            ->values()
            ->all();

        // Apply optional filters
        $filtered = $allStudents->filter(function ($s) use ($request) {
            if ($request->filled('intake_year') && trim((string)$s->intake_year) !== trim((string)$request->intake_year)) {
                return false;
            }
            if ($request->filled('department') && trim((string)$s->department) !== trim((string)$request->department)) {
                return false;
            }
            if ($request->filled('generation') && trim((string)$s->generation) !== trim((string)$request->generation)) {
                return false;
            }
            if ($request->filled('status')) {
                $st = strtolower(trim((string)($s->status ?? 'active')));
                if ($st !== strtolower(trim((string)$request->status))) {
                    return false;
                }
            }
            return true;
        })->values();

        $isFemale = function ($s): bool {
            $g = strtolower(trim((string)($s->gender ?? '')));
            return str_contains($g, 'ស្រី') || str_contains($g, 'female') || $g === 'f';
        };
        $getStatus = function ($s): string {
            $st = strtolower(trim((string)($s->status ?? 'active')));
            return in_array($st, ['active', 'graduated', 'inactive'], true) ? $st : 'active';
        };

        $activeCount = $filtered->filter(fn ($s) => $getStatus($s) === 'active')->count();
        $graduatedCount = $filtered->filter(fn ($s) => $getStatus($s) === 'graduated')->count();
        $inactiveCount = $filtered->filter(fn ($s) => $getStatus($s) === 'inactive')->count();
        $femaleCount = $filtered->filter($isFemale)->count();
        $maleCount = $filtered->count() - $femaleCount;

        // 1. Group by intake_year (ចាប់ពីឆ្នាំ)
        $byIntakeYear = $filtered->groupBy(function ($s) {
            $y = trim((string)($s->intake_year ?? ''));
            return $y !== '' ? $y : 'មិនទាន់កំណត់';
        })->map(function ($group, $year) use ($isFemale, $getStatus) {
            $deptBreakdown = [];
            foreach ($group as $s) {
                $d = trim((string)($s->department ?? ''));
                $deptKey = $d !== '' ? $d : 'មិនទាន់កំណត់';
                $deptBreakdown[$deptKey] = ($deptBreakdown[$deptKey] ?? 0) + 1;
            }
            arsort($deptBreakdown);

            $females = $group->filter($isFemale)->count();
            return [
                'intake_year' => (string)$year,
                'total' => $group->count(),
                'active' => $group->filter(fn ($s) => $getStatus($s) === 'active')->count(),
                'graduated' => $group->filter(fn ($s) => $getStatus($s) === 'graduated')->count(),
                'inactive' => $group->filter(fn ($s) => $getStatus($s) === 'inactive')->count(),
                'male' => $group->count() - $females,
                'female' => $females,
                'generations' => $group->pluck('generation')
                    ->map(fn ($v) => trim((string)$v))
                    ->filter(fn ($v) => $v !== '')
                    ->unique()
                    ->values()
                    ->all(),
                'departments' => $deptBreakdown,
            ];
        })->sortByDesc(function ($row) {
            return $row['intake_year'] === 'មិនទាន់កំណត់' ? '' : $row['intake_year'];
        })->values()->all();

        // 2. Group by department (គ្រប់ជំនាញ)
        $byDepartment = $filtered->groupBy(function ($s) {
            $d = trim((string)($s->department ?? ''));
            return $d !== '' ? $d : 'មិនទាន់កំណត់';
        })->map(function ($group, $dept) use ($isFemale, $getStatus) {
            $yearBreakdown = [];
            foreach ($group as $s) {
                $y = trim((string)($s->intake_year ?? ''));
                $yearKey = $y !== '' ? $y : 'មិនទាន់កំណត់';
                $yearBreakdown[$yearKey] = ($yearBreakdown[$yearKey] ?? 0) + 1;
            }
            krsort($yearBreakdown);

            $females = $group->filter($isFemale)->count();
            return [
                'department' => (string)$dept,
                'total' => $group->count(),
                'active' => $group->filter(fn ($s) => $getStatus($s) === 'active')->count(),
                'graduated' => $group->filter(fn ($s) => $getStatus($s) === 'graduated')->count(),
                'inactive' => $group->filter(fn ($s) => $getStatus($s) === 'inactive')->count(),
                'male' => $group->count() - $females,
                'female' => $females,
                'by_intake_year' => $yearBreakdown,
            ];
        })->sortByDesc('total')->values()->all();

        // 3. Group by generation (តាមជំនាន់)
        $byGeneration = $filtered->groupBy(function ($s) {
            $g = trim((string)($s->generation ?? ''));
            return $g !== '' ? $g : 'មិនទាន់កំណត់';
        })->map(function ($group, $gen) use ($isFemale, $getStatus) {
            $females = $group->filter($isFemale)->count();
            return [
                'generation' => (string)$gen,
                'intake_years' => $group->pluck('intake_year')
                    ->map(fn ($v) => trim((string)$v))
                    ->filter(fn ($v) => $v !== '')
                    ->unique()
                    ->sortDesc()
                    ->values()
                    ->all(),
                'total' => $group->count(),
                'active' => $group->filter(fn ($s) => $getStatus($s) === 'active')->count(),
                'graduated' => $group->filter(fn ($s) => $getStatus($s) === 'graduated')->count(),
                'inactive' => $group->filter(fn ($s) => $getStatus($s) === 'inactive')->count(),
                'male' => $group->count() - $females,
                'female' => $females,
            ];
        })->sortByDesc(function ($row) {
            return $row['generation'] === 'មិនទាន់កំណត់' ? '' : $row['generation'];
        })->values()->all();

        // Department list appearing in filtered result for pivot columns
        $activeDepartmentsInResult = $filtered->pluck('department')
            ->map(function ($v) {
                $t = trim((string)$v);
                return $t !== '' ? $t : 'មិនទាន់កំណត់';
            })
            ->unique()
            ->sort()
            ->values()
            ->all();

        return response()->json([
            'status' => true,
            'message' => 'ទាញយករបាយការណ៍ស្ថិតិនិស្សិតបានជោគជ័យ',
            'data' => [
                'summary' => [
                    'total_students' => $filtered->count(),
                    'active_count' => $activeCount,
                    'graduated_count' => $graduatedCount,
                    'inactive_count' => $inactiveCount,
                    'male_count' => $maleCount,
                    'female_count' => $femaleCount,
                    'departments_count' => count($activeDepartmentsInResult),
                    'intake_years_count' => count($byIntakeYear),
                ],
                'by_intake_year' => $byIntakeYear,
                'by_department' => $byDepartment,
                'by_generation' => $byGeneration,
                'departments' => $activeDepartmentsInResult,
                'filters' => [
                    'intake_years' => $allIntakeYears,
                    'departments' => $allDepartments,
                    'generations' => $allGenerations,
                ],
            ],
        ], 200);
    }
}

