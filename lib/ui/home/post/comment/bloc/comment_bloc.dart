import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/data/helper/ext.dart';
import 'package:flutter_bloc_app/data/local/user_preferences.dart';
import 'package:flutter_bloc_app/data/responses/post/comment.dart';
import 'package:flutter_bloc_app/ui/home/post/comment/bloc/comment_event.dart';
import 'package:flutter_bloc_app/ui/home/post/comment/bloc/comment_state.dart';
import 'package:http/http.dart' as http;

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  CommentBloc() : super(CommentInitialized()) {
    on<CommentGetting>(_mapCommentGettingEventToState);
    on<CommentSubmitted>(_mapCommentSubmittedEventToState);
    on<CommentDeleted>(_mapCommentDeletedEventToState);
    on<CommentUpdated>(_mapCommentUpdatedEventToState);
  }

  void _mapCommentGettingEventToState(
      CommentGetting event, Emitter<CommentState> emit) async {
    try {
      String token = await getToken();
      final response = await http
          .get(Uri.parse('$commentsURL/${event.postId}/comments'), headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      });

      switch (response.statusCode) {
        case 200:
          final json = jsonDecode(response.body)['comments'] as List<dynamic>;
          final posts = json.map((p) => Comment.fromJson(p)).toList();
          emit(CommentGetsSuccess(posts));
          break;
        case 403:
          emit(CommentFailure(jsonDecode(response.body)['message']));
          break;
        case 401:
          emit(CommentFailure(unauthorized));
          break;
        default:
          emit(CommentFailure(somethingWentWrong));
          break;
      }
    } catch (e) {
      emit(CommentFailure(e.toString()));
    }
  }

  void _mapCommentSubmittedEventToState(
      CommentSubmitted event, Emitter<CommentState> emit) async {
    try {
      String token = await getToken();
      final response = await http
          .post(Uri.parse('$commentsURL/${event.postId}/comments'), headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      }, body: {
        'comment': event.comment
      });

      switch (response.statusCode) {
        case 200:
          emit(CommentSuccess(jsonDecode(response.body)['message']));
          break;
        case 403:
          emit(CommentFailure(jsonDecode(response.body)['message']));
          break;
        case 401:
          emit(CommentFailure(unauthorized));
          break;
        default:
          emit(CommentFailure(somethingWentWrong));
          break;
      }
    } catch (e) {
      emit(CommentFailure(e.toString()));
    }
  }

  void _mapCommentDeletedEventToState(
      CommentDeleted event, Emitter<CommentState> emit) async {
    try {
      String token = await getToken();
      final response = await http.delete(
          Uri.parse('$commentsURL/comments/${event.commentId}'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
          });

      switch (response.statusCode) {
        case 200:
          emit(CommentSuccess(jsonDecode(response.body)['message']));
          break;
        case 403:
          emit(CommentFailure(jsonDecode(response.body)['message']));
          break;
        case 401:
          emit(CommentFailure(unauthorized));
          break;
        default:
          emit(CommentFailure(somethingWentWrong));
          break;
      }
    } catch (e) {
      emit(CommentFailure(e.toString()));
    }
  }

  void _mapCommentUpdatedEventToState(
      CommentUpdated event, Emitter<CommentState> emit) async {
    try {
      String token = await getToken();
      final response = await http
          .put(Uri.parse('$commentsURL/comments/${event.postId}'), headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      }, body: {
        'comment': event.comment
      });

      switch (response.statusCode) {
        case 200:
          emit(CommentSuccess(jsonDecode(response.body)['message']));
          break;
        case 403:
          emit(CommentFailure(jsonDecode(response.body)['message']));
          break;
        case 401:
          emit(CommentFailure(unauthorized));
          break;
        default:
          emit(CommentFailure(somethingWentWrong));
          break;
      }
    } catch (e) {
      emit(CommentFailure(e.toString()));
    }
  }

}
