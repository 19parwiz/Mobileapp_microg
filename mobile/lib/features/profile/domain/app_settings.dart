import 'package:equatable/equatable.dart';

/// App settings domain model
class AppSettings extends Equatable {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final String language;
  final String temperatureUnit; // 'C' or 'F'
  final bool autoRefresh;

  const AppSettings({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.language = 'en',
    this.temperatureUnit = 'C',
    this.autoRefresh = true,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      emailNotifications: json['emailNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      language: json['language'] ?? 'en',
      temperatureUnit: json['temperatureUnit'] ?? 'C',
      autoRefresh: json['autoRefresh'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'language': language,
      'temperatureUnit': temperatureUnit,
      'autoRefresh': autoRefresh,
    };
  }

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    String? language,
    String? temperatureUnit,
    bool? autoRefresh,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      language: language ?? this.language,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      autoRefresh: autoRefresh ?? this.autoRefresh,
    );
  }

  @override
  List<Object?> get props => [
        notificationsEnabled,
        emailNotifications,
        pushNotifications,
        language,
        temperatureUnit,
        autoRefresh,
      ];
}
