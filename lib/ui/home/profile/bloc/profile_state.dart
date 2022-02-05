import 'package:flutter_bloc_app/data/responses/auth/login.dart';

abstract class ProfileState {}

class ProfileInitialized extends ProfileState {}

class ProfileGetsSuccess extends ProfileState {
  final User user;

  ProfileGetsSuccess(this.user);
}

class ProfileFailure extends ProfileState {
  final String? error;

  ProfileFailure(this.error);
}

class ProfileSuccess extends ProfileState {
  final String? message;

  ProfileSuccess(this.message);
}
