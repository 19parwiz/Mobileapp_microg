/// Plant entity representing a microgreen plant
class Plant {
  final int? id;
  final String name;
  final String type; // e.g., "Basil", "Arugula", "Mint", "Cilantro"
  final String? description;
  final DateTime? plantingDate;
  final String growthStage; // e.g., "Seedling", "Growing", "Ready to Harvest", "Harvested"
  final String? healthStatus; // e.g., "Healthy", "Needs Water", "Warning"
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Plant({
    this.id,
    required this.name,
    required this.type,
    this.description,
    this.plantingDate,
    this.growthStage = 'Seedling',
    this.healthStatus,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor to convert JSON from backend
  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] as int?,
      name: json['name'] as String,
      type: json['type'] as String? ?? json['plantType'] as String? ?? 'Unknown',
      description: json['description'] as String?,
      plantingDate: json['plantingDate'] != null
          ? DateTime.parse(json['plantingDate'] as String)
          : null,
      growthStage: json['growthStage'] as String? ?? 'Seedling',
      healthStatus: json['healthStatus'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON to send to backend
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'plantType': type, // Backend uses 'plantType' field name
      if (description != null) 'description': description,
      if (plantingDate != null) 'plantingDate': plantingDate!.toIso8601String().split('T')[0], // Send as date only (YYYY-MM-DD)
      'growthStage': growthStage,
      if (healthStatus != null) 'healthStatus': healthStatus,
      if (notes != null) 'notes': notes,
    };
  }

  /// Create a copy with updated fields
  Plant copyWith({
    int? id,
    String? name,
    String? type,
    String? description,
    DateTime? plantingDate,
    String? growthStage,
    String? healthStatus,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      plantingDate: plantingDate ?? this.plantingDate,
      growthStage: growthStage ?? this.growthStage,
      healthStatus: healthStatus ?? this.healthStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get days since planting
  int? get daysSincePlanting {
    if (plantingDate == null) return null;
    return DateTime.now().difference(plantingDate!).inDays;
  }

  /// Get plant icon based on type
  String get iconEmoji {
    switch (type.toLowerCase()) {
      case 'basil':
        return '🌿';
      case 'arugula':
        return '🥬';
      case 'mint':
        return '🌱';
      case 'cilantro':
        return '🌿';
      case 'lettuce':
        return '🥗';
      case 'spinach':
        return '🥬';
      default:
        return '🌱';
    }
  }
}
