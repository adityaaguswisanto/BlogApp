abstract class CommentEvent{}

class CommentSubmitted extends CommentEvent{
  final int? postId;
  final String? comment;

  CommentSubmitted(this.postId, this.comment);
}

class CommentUpdated extends CommentEvent{
  final int? postId;
  final String? comment;

  CommentUpdated(this.postId, this.comment);
}

class CommentDeleted extends CommentEvent{
  final int? commentId;

  CommentDeleted(this.commentId);
}

class CommentGetting extends CommentEvent{
  final int? postId;

  CommentGetting(this.postId);
}