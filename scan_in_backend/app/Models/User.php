<?php
// User Eloquent model (Admin, Sub-Admin, Lecturer, Student).

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{

    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'latin_name',
        'email',
        'password',
        'role',
        'student_code',
        'gender',
        'date_of_birth',
        'staff_id',
        'department',
        'generation',
        'intake_year',
        'year_level',
        'status',
        'phone',
        'avatar_url',
        'device_id',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function classes()
    {
        return $this->hasMany(ClassModel::class, 'user_id');
    }

    public function attendances()
    {
        return $this->hasMany(Attendance::class, 'user_id');
    }

    public function isMasterAdmin(): bool
    {
        return $this->role === 'admin';
    }

    public function isSubAdmin(): bool
    {
        return $this->role === 'sub_admin';
    }

    public function isAcademicAdmin(): bool
    {
        return in_array($this->role, ['admin', 'sub_admin']);
    }
}
