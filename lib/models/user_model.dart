class User {
  final String id;
  final String phoneNumber;
  final String name;
  final DateTime createdAt;

  User({
    required this.id,
    required this.phoneNumber,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phoneNumber: json['phone_number'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  User copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
