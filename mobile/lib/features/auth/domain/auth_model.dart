import 'package:equatable/equatable.dart';

class AuthModel extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? token;
  final String? role;
  final String? message;
  final String? accountStatus;
  final bool? emailVerified;

  const AuthModel({
    required this.id,
    required this.email,
    this.name,
    this.token,
    this.role,
    this.message,
    this.accountStatus,
    this.emailVerified,
  });

  bool get hasUsableToken => token != null && token!.isNotEmpty;

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      token: json['token'] ?? json['accessToken'],
      role: json['role'],
      message: json['message']?.toString(),
      accountStatus: json['accountStatus']?.toString(),
      emailVerified: json['emailVerified'] is bool ? json['emailVerified'] as bool : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'token': token,
      'role': role,
      if (message != null) 'message': message,
      if (accountStatus != null) 'accountStatus': accountStatus,
      if (emailVerified != null) 'emailVerified': emailVerified,
    };
  }

  AuthModel copyWith({
    String? id,
    String? email,
    String? name,
    String? token,
    String? role,
    String? message,
    String? accountStatus,
    bool? emailVerified,
  }) {
    return AuthModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      token: token ?? this.token,
      role: role ?? this.role,
      message: message ?? this.message,
      accountStatus: accountStatus ?? this.accountStatus,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  @override
  List<Object?> get props =>
      [id, email, name, token, role, message, accountStatus, emailVerified];
}

