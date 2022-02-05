import 'package:flutter_bloc_app/data/responses/auth/login.dart';

abstract class LoginState{

}

class LoginInitialized extends LoginState{}

class LoginSuccess extends LoginState{
  final User user;

  LoginSuccess(this.user);
}

class LoginFailure extends LoginState{
  final String error;

  LoginFailure(this.error);
}