<?php
// Attendance Eloquent model.

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Attendance extends Model
{
    use HasFactory;

    protected $table = 'attendances';

    protected $fillable = [
        'class_id',
        'user_id',
        'status',
        'check_in_method',
        'date',
        'scanned_at',
        'note',
        'scan_lat',
        'scan_lng',
        'distance_meters',
    ];

    protected $casts = [
        'scanned_at' => 'datetime',
        'date' => 'date:Y-m-d',
        'scan_lat' => 'float',
        'scan_lng' => 'float',
        'distance_meters' => 'integer',
    ];

    public function student()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function classModel()
    {
        return $this->belongsTo(ClassModel::class, 'class_id');
    }
}
