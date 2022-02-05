abstract class PostEvent {}

class PostSubmitted extends PostEvent {
  final String body;
  final String? image;

  PostSubmitted(this.body, this.image);
}

class PostUpdated extends PostEvent{
  final int? postId;
  final String? body;

  PostUpdated(this.postId, this.body);
}

class PostGetting extends PostEvent{}

class PostDeleted extends PostEvent{
  final int? postId;

  PostDeleted(this.postId);
}

class PostLiked extends PostEvent{
  final int id;

  PostLiked(this.id);
}