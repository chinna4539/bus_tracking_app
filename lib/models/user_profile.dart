class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String phone;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'phone': phone};
  }
}
