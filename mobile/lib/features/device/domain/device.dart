/// Device domain model
class Device {
  final int? id;
  final String name;
  final String? deviceId;
  final String? description;
  final String? deviceType;
  final String? location;
  final bool? isActive;
  final DateTime? lastSeen;
  final DateTime? createdAt;

  Device({
    this.id,
    required this.name,
    this.deviceId,
    this.description,
    this.deviceType,
    this.location,
    this.isActive,
    this.lastSeen,
    this.createdAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as int?,
      name: json['name'] as String,
      deviceId: json['deviceId'] as String?,
      description: json['description'] as String?,
      deviceType: json['deviceType'] as String?,
      location: json['location'] as String?,
      isActive: json['isActive'] as bool?,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (deviceId != null) 'deviceId': deviceId,
      if (description != null) 'description': description,
      if (deviceType != null) 'deviceType': deviceType,
      if (location != null) 'location': location,
      if (isActive != null) 'isActive': isActive,
      if (lastSeen != null) 'lastSeen': lastSeen!.toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  Device copyWith({
    int? id,
    String? name,
    String? deviceId,
    String? description,
    String? deviceType,
    String? location,
    bool? isActive,
    DateTime? lastSeen,
    DateTime? createdAt,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      deviceId: deviceId ?? this.deviceId,
      description: description ?? this.description,
      deviceType: deviceType ?? this.deviceType,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}