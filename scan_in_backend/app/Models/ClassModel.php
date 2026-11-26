<?php
// ClassModel Eloquent model and generation matching helpers.

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ClassModel extends Model
{
    use HasFactory;

    protected $table = 'classes';

    protected $fillable = [
        'user_id',
        'subject_name',
        'subject_code',
        'department',
        'generation',
        'year_level',
        'room',
        'day_of_week',
        'time',
        'class_date',
        'semester',
        'academic_year',
        'student_count',
        'completed_sessions',
        'total_sessions',
        'description',
        'is_qr_active',
        'qr_token',
    ];

    protected $casts = [
        'is_qr_active' => 'boolean',
        'class_date' => 'date:Y-m-d',
        'student_count' => 'integer',
        'completed_sessions' => 'integer',
        'total_sessions' => 'integer',
    ];

    public function lecturer()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public static function extractGenNumber(?string $gen): ?int
    {
        if (!$gen) return null;
        $khmer = ['០', '១', '២', '៣', '៤', '៥', '៦', '៧', '៨', '៩'];
        $arabic = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
        $arabicStr = str_replace($khmer, $arabic, $gen);
        if (preg_match('/\b(\d+)\b/', $arabicStr, $m)) {
            return (int)$m[1];
        }
        return null;
    }

    public static function matchesGeneration(?string $genA, ?string $genB): bool
    {
        $a = trim((string)($genA ?? ''));
        $b = trim((string)($genB ?? ''));
        if ($a === '' || $b === '') return true;
        if ($a === $b) return true;
        $numA = self::extractGenNumber($a);
        $numB = self::extractGenNumber($b);
        if ($numA !== null && $numB !== null) {
            return $numA === $numB;
        }
        return false;
    }

    public function attendances()
    {
        return $this->hasMany(Attendance::class, 'class_id');
    }
}
