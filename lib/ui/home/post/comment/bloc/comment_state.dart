import 'package:flutter_bloc_app/data/responses/post/comment.dart';

abstract class CommentState{}

class CommentInitialized extends CommentState{}

class CommentGetsSuccess extends CommentState{
  final List<Comment> comment;

  CommentGetsSuccess(this.comment);
}

class CommentSuccess extends CommentState{
  final String message;

  CommentSuccess(this.message);
}

class CommentFailure extends CommentState{
  final String? error;

  CommentFailure(this.error);
}