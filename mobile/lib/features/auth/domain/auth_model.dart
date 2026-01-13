import 'package:equatable/equatable.dart';

class AuthModel extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? token;
  final String? role;

  const AuthModel({
    required this.id,
    required this.email,
    this.name,
    this.token,
    this.role,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      token: json['token'] ?? json['accessToken'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'token': token,
      'role': role,
    };
  }

  AuthModel copyWith({
    String? id,
    String? email,
    String? name,
    String? token,
    String? role,
  }) {
    return AuthModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      token: token ?? this.token,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [id, email, name, token, role];
}

