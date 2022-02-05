class User {
  int? id;
  String? name;
  String? username;
  String? email;
  String? emailVerifiedAt;
  String? image;
  String? createdAt;
  String? updatedAt;
  String? token;

  User(
      {this.id,
        this.name,
        this.username,
        this.email,
        this.emailVerifiedAt,
        this.image,
        this.createdAt,
        this.updatedAt,
        this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user']['id'],
      name: json['user']['name'],
      username: json['user']['username'],
      email: json['user']['email'],
      emailVerifiedAt: json['user']['email_verified_at'],
      image: json['user']['image'],
      createdAt: json['user']['created_att'],
      updatedAt: json['user']['updated_att'],
      token: json['token'],
    );
  }
}