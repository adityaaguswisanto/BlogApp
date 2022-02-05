class Forgot {
  String? message;

  Forgot({this.message});

  factory Forgot.fromJson(Map<String, dynamic> json) {
    return Forgot(message: json['message']);
  }
}