class User {
  final String email;
  final String id;

  User({required this.email, required this.id});

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'id': id,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'],
      id: map['id'],
    );
  }
}
