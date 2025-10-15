class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.timezone,
  });

  final String id;
  final String email;
  final String timezone;

  UserProfile copyWith({String? id, String? email, String? timezone}) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      timezone: timezone ?? this.timezone,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'timezone': timezone,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      timezone: json['timezone'] as String? ?? 'America/Denver',
    );
  }
}
