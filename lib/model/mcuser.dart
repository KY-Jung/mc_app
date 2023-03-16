
class McUser {
  late String email;
  late String signKey;

  McUser({required this.email, required this.signKey,});

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'signKey': signKey,
    };
  }

  McUser.fromMap(Map<dynamic, dynamic>? map) {
    email = map?['email'];
    signKey = map?['signKey'];
  }

  @override
  String toString() {
    return 'User{email: $email, signKey: $signKey}';
  }

}