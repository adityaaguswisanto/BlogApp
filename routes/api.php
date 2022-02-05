<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CommentController;
use App\Http\Controllers\Api\LikeController;
use App\Http\Controllers\Api\PostController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

Route::namespace('Api')->group(function () {
    Route::prefix('auth')->group(function () {
        Route::post('register', [AuthController::class, 'register']);
        Route::post('login', [AuthController::class, 'login']);
        Route::post('forgot', [AuthController::class, 'forgot']);
    });
    Route::group(['prefix' => 'auth', 'middleware' => 'auth:sanctum'], function () {
        Route::get('user', [AuthController::class, 'user']);
        Route::put('user', [AuthController::class, 'update']);
    });
    Route::group(['prefix' => 'post', 'middleware' => 'auth:sanctum'], function () {
        Route::get('', [PostController::class, 'index']); // all posts
        Route::post('', [PostController::class, 'store']); // create post
        Route::get('/{id}', [PostController::class, 'show']); // get single post
        Route::put('/{id}', [PostController::class, 'update']); // update post
        Route::delete('/{id}', [PostController::class, 'destroy']); // delete post
        // Like
        Route::post('/{id}/likes', [LikeController::class, 'likeOrUnlike']); // like or dislike back a post
    });
    Route::group(['prefix' => 'comment', 'middleware' => 'auth:sanctum'], function () {
        // Comment
        Route::get('/{id}/comments', [CommentController::class, 'index']); // all comments of a post
        Route::post('/{id}/comments', [CommentController::class, 'store']); // create comment on a post
        Route::put('/comments/{id}', [CommentController::class, 'update']); // update a comment
        Route::delete('/comments/{id}', [CommentController::class, 'destroy']); // delete a comment
    });
});