<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ClassController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Public Routes
|--------------------------------------------------------------------------
*/
Route::post('/login', [AuthController::class, 'login']);
Route::get('/classes', [ClassController::class, 'index']);

/*
|--------------------------------------------------------------------------
| Protected Routes (Requires Bearer Token)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/student/classes', [ClassController::class, 'index']);
});

