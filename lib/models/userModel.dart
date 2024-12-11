class User {
  final String username;
  final String password;

  User({required this.username, required this.password});

  // Metode untuk mengubah User menjadi Map untuk dikirim ke API
  Map<String, String> toMap() {
    return {
      'username': username,
      'password': password,
    };
  }

  // Metode untuk mem-parsing respons dari API
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      password: json['password'] ?? '',
    );
  }
}
