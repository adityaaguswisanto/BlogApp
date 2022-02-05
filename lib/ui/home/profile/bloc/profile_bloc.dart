import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/data/helper/ext.dart';
import 'package:flutter_bloc_app/data/local/user_preferences.dart';
import 'package:flutter_bloc_app/data/responses/auth/login.dart';
import 'package:flutter_bloc_app/ui/home/profile/bloc/profile_event.dart';
import 'package:flutter_bloc_app/ui/home/profile/bloc/profile_state.dart';
import 'package:http/http.dart' as http;

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitialized()) {
    on<ProfileGetting>(_mapProfileGettingEventToState);
    on<ProfileSubmitted>(_mapProfileSubmittedEventToState);
  }

  void _mapProfileGettingEventToState(
      ProfileGetting event, Emitter<ProfileState> emit) async {
    try {
      String token = await getToken();
      final response = await http.get(Uri.parse(userURL), headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      });

      switch (response.statusCode) {
        case 200:
          emit(ProfileGetsSuccess(User.fromJson(jsonDecode(response.body))));
          break;
        case 401:
          emit(ProfileFailure(unauthorized));
          break;
        default:
          emit(ProfileFailure(somethingWentWrong));
          break;
      }
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  void _mapProfileSubmittedEventToState(
      ProfileSubmitted event, Emitter<ProfileState> emit) async {
    try {
      String token = await getToken();
      final response = await http.put(Uri.parse(userURL),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: event.image == null
              ? {'name': event.name}
              : {'name': event.name, 'image': event.image});

      switch (response.statusCode) {
        case 200:
          emit(ProfileSuccess(jsonDecode(response.body)['message']));
          break;
        case 401:
          emit(ProfileFailure(unauthorized));
          break;
        default:
          emit(ProfileFailure(somethingWentWrong));
          break;
      }
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }
}
