import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/data/helper/ext.dart';
import 'package:flutter_bloc_app/data/local/user_preferences.dart';
import 'package:flutter_bloc_app/data/responses/post/post.dart';
import 'package:flutter_bloc_app/ui/home/post/bloc/post_event.dart';
import 'package:flutter_bloc_app/ui/home/post/bloc/post_state.dart';
import 'package:http/http.dart' as http;

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc() : super(PostInitialized()) {
    on<PostSubmitted>(_mapPostSubmittedEventToState);
    on<PostGetting>(_mapPostGettingEventToState);
    on<PostLiked>(_mapPostLikedEventToState);
    on<PostDeleted>(_mapPostDeletedEventToState);
    on<PostUpdated>(_mapPostUpdatedEventToState);
  }

  void _mapPostSubmittedEventToState(
      PostSubmitted event, Emitter<PostState> emit) async {
    try {
      String token = await getToken();
      final response = await http.post(Uri.parse(postsURL),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: event.image != null
              ? {'body': event.body, 'image': event.image}
              : {
                  'body': event.body,
                });

      switch (response.statusCode) {
        case 200:
          emit(PostSuccess(jsonDecode(response.body)['message']));
          break;
        case 422:
          final errors = jsonDecode(response.body)['errors'];
          emit(PostFailure(errors[errors.keys.elementAt(0)[0]]));
          break;
        case 401:
          emit(PostFailure(unauthorized));
          break;
        default:
          emit(PostFailure(somethingWentWrong));
          break;
      }
    } catch (e) {
      emit(PostFailure(e.toString()));
    }
  }

  void _mapPostGettingEventToState(
      PostGetting event, Emitter<PostState> emit) async {
    try {
      String token = await getToken();
      final response = await http.get(Uri.parse(postsURL), headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      });

      switch (response.statusCode) {
        case 200:
          final json = jsonDecode(response.body)['posts'] as List<dynamic>;
          final posts = json.map((p) => Post.fromJson(p)).toList();
          emit(PostGetsSuccess(posts));
          break;
        case 401:
          emit(PostFailure(unauthorized));
          break;
        default:
          emit(PostFailure(somethingWentWrong));
          break;
      }
    } catch (e) {
      emit(PostFailure(e.toString()));
    }
  }

  void _mapPostLikedEventToState(
      PostLiked event, Emitter<PostState> emit) async {
    try {
      String token = await getToken();
      final response = await http.post(Uri.parse('$postsURL/${event.id}/likes'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
          });

      switch (response.statusCode) {
        case 200:
          emit(PostSuccess(jsonDecode(response.body)['message']));
          break;
        case 403:
          emit(PostFailure(jsonDecode(response.body)['message']));
          break;
        case 401:
          emit(PostFailure(unauthorized));
          break;
        default:
          emit(PostFailure(somethingWentWrong));
          break;
      }
    } catch (e) {
      emit(PostFailure(e.toString()));
    }
  }

  void _mapPostDeletedEventToState(
      PostDeleted event, Emitter<PostState> emit) async {
    try {
      String token = await getToken();
      final response = await http.delete(Uri.parse('$postsURL/${event.postId}'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
          });

      switch (response.statusCode) {
        case 200:
          emit(PostSuccess(jsonDecode(response.body)['message']));
          break;
        case 403:
          emit(PostFailure(jsonDecode(response.body)['message']));
          break;
        case 401:
          emit(PostFailure(unauthorized));
          break;
        default:
          emit(PostFailure(somethingWentWrong));
          break;
      }
    } catch (e) {
      emit(PostFailure(e.toString()));
    }
  }

  void _mapPostUpdatedEventToState(
      PostUpdated event, Emitter<PostState> emit) async {
    try {
      String token = await getToken();
      final response =
          await http.put(Uri.parse('$postsURL/${event.postId}'), headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      }, body: {
        'body': event.body,
      });

      switch (response.statusCode) {
        case 200:
          emit(PostSuccess(jsonDecode(response.body)['message']));
          break;
        case 403:
          emit(PostFailure(jsonDecode(response.body)['message']));
          break;
        case 401:
          emit(PostFailure(unauthorized));
          break;
        default:
          emit(PostFailure(somethingWentWrong));
          break;
      }
    } catch (e) {
      emit(PostFailure(e.toString()));
    }
  }
}
