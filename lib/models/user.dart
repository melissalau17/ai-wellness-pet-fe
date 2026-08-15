/// Mirrors the `user` object returned by POST /api/v1/user/register.
class AppUser {
  final String id;
  final String name;
  final String email;
  final DateTime? createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
