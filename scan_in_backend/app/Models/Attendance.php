<?php

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

    /**
     * ទំនាក់ទំនងទៅកាន់សិស្ស (Student User)
     */
    public function student()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * ទំនាក់ទំនងទៅកាន់ថ្នាក់រៀន (Class)
     */
    public function classModel()
    {
        return $this->belongsTo(ClassModel::class, 'class_id');
    }
}
