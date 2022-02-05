import 'package:flutter_bloc_app/data/responses/post/post.dart';

abstract class PostState {}

class PostInitialized extends PostState {}

class PostSuccess extends PostState {
  final String? message;

  PostSuccess(this.message);
}

class PostFailure extends PostState {
  final String? error;

  PostFailure(this.error);
}

class PostGetsSuccess extends PostState {
  final List<Post> post;

  PostGetsSuccess(this.post);
}