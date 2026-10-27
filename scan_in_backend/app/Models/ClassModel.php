<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ClassModel extends Model
{
    use HasFactory;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'classes';

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'user_id',
        'subject_name',
        'subject_code',
        'room',
        'day_of_week',
        'time',
        'semester',
        'academic_year',
        'student_count',
        'completed_sessions',
        'total_sessions',
        'description',
        'is_qr_active',
        'qr_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'is_qr_active' => 'boolean',
        'student_count' => 'integer',
        'completed_sessions' => 'integer',
        'total_sessions' => 'integer',
    ];

    /**
     * ទំនាក់ទំនងទៅកាន់គ្រូបង្រៀន (User)
     */
    public function lecturer()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * បញ្ជីវត្តមានក្នុងថ្នាក់រៀននេះ
     */
    public function attendances()
    {
        return $this->hasMany(Attendance::class, 'class_id');
    }
}
