<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Password;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request, User $user)
    {
        $request->validate([
            'name'      => 'required|min:3',
            'username'  => 'required|min:3|max:50|unique:users|string|regex:/^\S*$/u',
            'email'     => 'required|email|unique:users',
            'password'  => 'required|min:6|regex:/^.*(?=.{3,})(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[\d\x])(?=.*[!$#%]).*$/|confirmed'
        ]);

        $user->create([
            'name'      => $request->name,
            'username'  => $request->username,
            'email'     => $request->email,
            'password'  => bcrypt($request->password),
        ]);

        return response()->json([
            'message' => 'New account creation successful'
        ], 201);
    }

    public function login(Request $request, User $user)
    {
        $request->validate([
            'email'     => 'required',
            'password'  => 'required',
        ]);

        $login_type = filter_var($request->input('email'), FILTER_VALIDATE_EMAIL) ? 'email' : 'username';

        $request->merge([
            $login_type => $request->input('email')
        ]);

        if (!Auth::attempt($request->only($login_type, 'password'))) {
            return response()->json([
                'message'   => 'Invalid email or password',
            ], 403);
        }

        $user = $request->user();
        $token = $user->createToken('bloc-secret')->plainTextToken;

        return response()->json([
            'user'      => $user,
            'token'     => $token,
        ], 200);
    }

    public function user()
    {
        return response([
            'user' => auth()->user()
        ], 200);
    }

    // update user
    public function update(Request $request)
    {
        $attrs = $request->validate([
            'name' => 'required|string'
        ]);

        $image = $this->saveImage($request->image);

        auth()->user()->update([
            'name' => $attrs['name'],
            'image' => $image
        ]);

        return response([
            'message' => 'User updated.',
            'user' => auth()->user()
        ], 200);
    }
}
