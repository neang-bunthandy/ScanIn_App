<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ClassController;
use App\Http\Controllers\Api\AttendanceController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Public Routes
|--------------------------------------------------------------------------
*/
Route::post('/login', [AuthController::class, 'login']);
Route::get('/classes', [ClassController::class, 'index']);
Route::get('/classes/{id}/attendances', [AttendanceController::class, 'classAttendances']);
Route::put('/attendances/{id}', [AttendanceController::class, 'update']);

/*
|--------------------------------------------------------------------------
| Protected Routes (Requires Bearer Token)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/student/classes', [ClassController::class, 'index']);

    // Class routes for lecturers
    Route::post('/classes', [ClassController::class, 'store']);
    Route::post('/classes/{id}/toggle-qr', [ClassController::class, 'toggleQr']);

    // Attendance routes for students
    Route::post('/attendances/scan', [AttendanceController::class, 'scan']);
    Route::get('/student/attendances', [AttendanceController::class, 'studentHistory']);
});

