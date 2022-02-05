import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/data/helper/ext.dart';
import 'package:flutter_bloc_app/data/responses/auth/login.dart';
import 'package:flutter_bloc_app/ui/auth/login/bloc/login_event.dart';
import 'package:flutter_bloc_app/ui/auth/login/bloc/login_state.dart';
import 'package:http/http.dart' as http;

class LoginBloc extends Bloc<LoginEvent, LoginState> {

  LoginBloc() : super(LoginInitialized()) {
    on<LoginSubmitted>(_mapLoginEventToState);
  }

  void _mapLoginEventToState(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    try {
      final response = await http.post(Uri.parse(loginURL), headers: {
        'Accept': 'application/json'
      }, body: {
        'email': event.email,
        'password': event.password,
      });

      switch (response.statusCode) {
        case 200:
          emit(LoginSuccess(User.fromJson(jsonDecode(response.body))));
          break;
        case 422:
          final errors = jsonDecode(response.body)['errors'];
          emit(LoginFailure(errors[errors.keys.elementAt(0)][0]));
          break;
        case 403:
          emit(LoginFailure(jsonDecode(response.body)['message']));
          break;
        default:
          emit(LoginFailure(somethingWentWrong));
          break;
      }
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
