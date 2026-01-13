class Device {
  final String? id;
  final String name;
  final String? type;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Device({
    this.id,
    required this.name,
    this.type,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  Device copyWith({
    String? id,
    String? name,
    String? type,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return Device(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString(),
      userId: json['userId']?.toString(),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (type != null) 'type': type,
      if (userId != null) 'userId': userId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
