<?php
// Defines web routes.

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});
