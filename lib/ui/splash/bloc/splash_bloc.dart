import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/data/helper/ext.dart';
import 'package:flutter_bloc_app/data/local/user_preferences.dart';
import 'package:flutter_bloc_app/data/responses/auth/login.dart';
import 'package:flutter_bloc_app/ui/splash/bloc/splash_event.dart';
import 'package:flutter_bloc_app/ui/splash/bloc/splash_state.dart';
import 'package:http/http.dart' as http;

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitialized()) {
    on<SplashSubmitted>(_mapSplashEventToState);
  }

  void _mapSplashEventToState(
      SplashSubmitted event, Emitter<SplashState> emit) async {
    try {
      emit(SplashLoading());

      String token = await getToken();
      final response = await http.get(Uri.parse(userURL), headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      });

      switch (response.statusCode) {
        case 200:
          emit(SplashSuccess(User.fromJson(jsonDecode(response.body))));
          break;
        case 401:
          emit(SplashFailure(unauthorized));
          break;
        default:
          emit(SplashFailure(somethingWentWrong));
          break;
      }
    } catch (e) {
      emit(SplashFailure(e.toString()));
    }
  }
}
