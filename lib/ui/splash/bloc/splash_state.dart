import 'package:flutter_bloc_app/data/responses/auth/login.dart';

abstract class SplashState{

}

class SplashInitialized extends SplashState{}

class SplashLoading extends SplashState{}

class SplashSuccess extends SplashState{
  final User user;

  SplashSuccess(this.user);
}

class SplashFailure extends SplashState{
  final String? error;

  SplashFailure(this.error);
}