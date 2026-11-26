<?php
// Generates student statistics and attendance Excel/JSON exports.

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\ClassModel;
use App\Models\User;
use Illuminate\Http\Request;

class ReportController extends Controller
{

    public function studentStats(Request $request)
    {
        if (!$request->user() || !$request->user()->isAcademicAdmin()) {
            return response()->json([
                'status' => false,
                'message' => 'មានតែអ្នកគ្រប់គ្រង (Admin) ប៉ុណ្ណោះដែលអាចមើលរបាយការណ៍ស្ថិតិនេះបាន។',
            ], 403);
        }

        $allStudents = User::where('role', 'student')
            ->select('id', 'name', 'latin_name', 'student_code', 'gender', 'department', 'generation', 'intake_year', 'year_level', 'status', 'created_at')
            ->get();

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

        $filtered = $allStudents->filter(function ($s) use ($request) {
            if ($request->filled('intake_year') && trim((string)$s->intake_year) !== trim((string)$request->intake_year)) {
                return false;
            }
            if ($request->filled('department') && trim((string)$s->department) !== trim((string)$request->department)) {
                return false;
            }
            if ($request->filled('generation') && !\App\Models\ClassModel::matchesGeneration($s->generation, $request->generation)) {
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

    public function exportAttendance(Request $request)
    {
        $user = $request->user();
        if (!$user || (!$user->isAcademicAdmin() && $user->role !== 'lecturer')) {
            return response()->json([
                'status' => false,
                'message' => 'មានតែអ្នកគ្រប់គ្រង ឬគ្រូបង្រៀនប៉ុណ្ណោះដែលអាចទាញរបាយការណ៍វត្តមានបាន។',
            ], 403);
        }

        if ($request->filled('class_id')) {
            $class = ClassModel::find($request->class_id);
            if (!$class) {
                return response()->json([
                    'status' => false,
                    'message' => 'រកមិនឃើញថ្នាក់រៀននេះទេ។',
                ], 404);
            }
            if ($user->role === 'lecturer' && (int)$class->user_id !== (int)$user->id) {
                return response()->json([
                    'status' => false,
                    'message' => 'អ្នកមិនមានសិទ្ធិទាញរបាយការណ៍សម្រាប់ថ្នាក់របស់គ្រូផ្សេងឡើយ។',
                ], 403);
            }
        }

        $query = Attendance::with(['student', 'classModel'])
            ->whereHas('classModel', function ($q) use ($user, $request) {
                if ($user->role === 'lecturer') {
                    $q->where('user_id', $user->id);
                }
                if ($request->filled('subject_code')) {
                    $q->where('subject_code', trim((string)$request->subject_code));
                }
                if ($request->filled('department')) {
                    $q->where('department', trim((string)$request->department));
                }
            });

        if ($request->filled('class_id')) {
            $query->where('class_id', (int)$request->class_id);
        }
        if ($request->filled('date_from')) {
            $query->whereDate('date', '>=', trim((string)$request->date_from));
        }
        if ($request->filled('date_to')) {
            $query->whereDate('date', '<=', trim((string)$request->date_to));
        }
        if ($request->filled('status')) {
            $query->where('status', strtolower(trim((string)$request->status)));
        }

        $records = $query->orderBy('date', 'desc')->orderBy('id', 'desc')->get();

        $statusLabels = [
            'present' => 'មករៀន (Present)',
            'late' => 'មកយឺត (Late)',
            'absent' => 'អវត្តមាន (Absent)',
            'excused' => 'ច្បាប់ (Excused)',
        ];

        $format = strtolower(trim((string)$request->query('format', 'csv')));

        if ($format === 'json') {
            $total = $records->count();
            $present = $records->where('status', 'present')->count();
            $late = $records->where('status', 'late')->count();
            $absent = $records->where('status', 'absent')->count();
            $excused = $records->where('status', 'excused')->count();

            $formatted = $records->map(function ($a) use ($statusLabels) {
                $st = strtolower((string)$a->status);
                return [
                    'id' => $a->id,
                    'student_code' => $a->student?->student_code ?? '-',
                    'student_name' => $a->student?->name ?? '-',
                    'latin_name' => $a->student?->latin_name ?? '',
                    'department' => $a->student?->department ?? ($a->classModel?->department ?? '-'),
                    'subject_code' => $a->classModel?->subject_code ?? '-',
                    'subject_name' => $a->classModel?->subject_name ?? '-',
                    'date' => $a->date ? $a->date->format('Y-m-d') : '-',
                    'scanned_at' => $a->scanned_at ? $a->scanned_at->format('H:i') : '-',
                    'status' => $st,
                    'status_label' => $statusLabels[$st] ?? $st,
                    'note' => $a->note ?? '',
                ];
            })->values();

            return response()->json([
                'status' => true,
                'summary' => [
                    'total' => $total,
                    'present' => $present,
                    'late' => $late,
                    'absent' => $absent,
                    'excused' => $excused,
                    'attendance_rate' => $total > 0 ? round((($present + $late) / $total) * 100) : 0,
                ],
                'data' => $formatted,
            ], 200);
        }

        $escapeCsv = function (?string $val): string {
            $v = str_replace('"', '""', (string)($val ?? ''));
            return '"' . $v . '"';
        };

        $lines = [];
        $lines[] = implode(',', [
            '#',
            'Student Code',
            'Student Name (KH)',
            'Student Name (Latin)',
            'Department',
            'Subject Code',
            'Subject Name',
            'Date',
            'Scanned Time',
            'Status',
            'Note',
        ]);

        foreach ($records as $index => $a) {
            $st = strtolower((string)$a->status);
            $lines[] = implode(',', [
                $index + 1,
                $escapeCsv($a->student?->student_code ?? '-'),
                $escapeCsv($a->student?->name ?? '-'),
                $escapeCsv($a->student?->latin_name ?? ''),
                $escapeCsv($a->student?->department ?? ($a->classModel?->department ?? '-')),
                $escapeCsv($a->classModel?->subject_code ?? '-'),
                $escapeCsv($a->classModel?->subject_name ?? '-'),
                $escapeCsv($a->date ? $a->date->format('Y-m-d') : '-'),
                $escapeCsv($a->scanned_at ? $a->scanned_at->format('H:i') : '-'),
                $escapeCsv($statusLabels[$st] ?? $st),
                $escapeCsv($a->note ?? ''),
            ]);
        }

        $csvContent = "\xEF\xBB\xBF" . implode("\r\n", $lines);
        $filename = 'attendance_report_' . date('Y-m-d') . '.csv';

        return response($csvContent, 200, [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
        ]);
    }
}
