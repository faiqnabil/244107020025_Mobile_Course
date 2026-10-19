import '../../domain/entities/auth_session.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.access,
    required super.refresh,
  });

  Map<String, dynamic> toJson() => {
        'access': access,
        'refresh': refresh,
      };

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      access: json['access'] as String? ?? '',
      refresh: json['refresh'] as String? ?? '',
    );
  }

  AuthSession toEntity() => AuthSession(
        access: access,
        refresh: refresh,
      );
}
