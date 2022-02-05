class Register {
  String? message;

  Register({this.message});

  factory Register.fromJson(Map<String, dynamic> json) {
    return Register(message: json['message']);
  }
}