/// Sensor data model representing live readings from the university server
class SensorData {
  // Current readings
  final double airTemperature;
  final double airHumidity;
  final double co2;
  final double ec;
  final double tds;
  final double phLevel;
  final double lightLevel;
  final double turbidity;
  final int waterTemperature;
  final double soil1;
  final double soil2;
  final double soil3;
  final double soil4;
  final double soil5;
  final String? weatherTemp;

  // Historical data (last 10 readings)
  final List<TemperatureReading> temperatureData;
  final List<HumidityReading> humidityData;
  final List<CO2Reading> co2Data;
  final List<ECReading> ecData;
  final List<TDSReading> tdsData;
  final List<TurbidityReading> turbidityData;
  final List<String> historyDates;

  SensorData({
    required this.airTemperature,
    required this.airHumidity,
    required this.co2,
    required this.ec,
    required this.tds,
    required this.phLevel,
    required this.lightLevel,
    required this.turbidity,
    required this.waterTemperature,
    required this.soil1,
    required this.soil2,
    required this.soil3,
    required this.soil4,
    required this.soil5,
    this.weatherTemp,
    required this.temperatureData,
    required this.humidityData,
    required this.co2Data,
    required this.ecData,
    required this.tdsData,
    required this.turbidityData,
    required this.historyDates,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      airTemperature: (json['air_temperature'] as num?)?.toDouble() ?? 0.0,
      airHumidity: (json['air_humidity'] as num?)?.toDouble() ?? 0.0,
      co2: (json['co2'] as num?)?.toDouble() ?? 0.0,
      ec: (json['ec'] as num?)?.toDouble() ?? 0.0,
      tds: (json['tds'] as num?)?.toDouble() ?? 0.0,
      phLevel: (json['ph_level'] as num?)?.toDouble() ?? 0.0,
      lightLevel: (json['light_level'] as num?)?.toDouble() ?? 0.0,
      turbidity: (json['turbidity'] as num?)?.toDouble() ?? 0.0,
      waterTemperature: (json['water_temperature'] as int?) ?? 0,
      soil1: (json['soil1'] as num?)?.toDouble() ?? 0.0,
      soil2: (json['soil2'] as num?)?.toDouble() ?? 0.0,
      soil3: (json['soil3'] as num?)?.toDouble() ?? 0.0,
      soil4: (json['soil4'] as num?)?.toDouble() ?? 0.0,
      soil5: (json['soil5'] as num?)?.toDouble() ?? 0.0,
      weatherTemp: json['weather_temp']?.toString(),
      temperatureData: _parseTemperatureData(json['temperature_data']),
      humidityData: _parseHumidityData(json['humidity_data']),
      co2Data: _parseCO2Data(json['co2_data']),
      ecData: _parseECData(json['ec_data']),
      tdsData: _parseTDSData(json['tds_data']),
      turbidityData: _parseTurbidityData(json['turbidity_data']),
        historyDates: (json['history_data'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'air_temperature': airTemperature,
        'air_humidity': airHumidity,
        'co2': co2,
        'ec': ec,
        'tds': tds,
        'ph_level': phLevel,
        'light_level': lightLevel,
        'turbidity': turbidity,
        'water_temperature': waterTemperature,
        'soil1': soil1,
        'soil2': soil2,
        'soil3': soil3,
        'soil4': soil4,
        'soil5': soil5,
        'weather_temp': weatherTemp,
        'temperature_data': temperatureData.map((x) => x.toJson()).toList(),
        'humidity_data': humidityData.map((x) => x.toJson()).toList(),
        'co2_data': co2Data.map((x) => x.toJson()).toList(),
        'ec_data': ecData.map((x) => x.toJson()).toList(),
        'tds_data': tdsData.map((x) => x.toJson()).toList(),
        'turbidity_data': turbidityData.map((x) => x.toJson()).toList(),
        'history_data': historyDates,
      };

  SensorData copyWith({
    double? airTemperature,
    double? airHumidity,
    double? co2,
    double? ec,
    double? tds,
    double? phLevel,
    double? lightLevel,
    double? turbidity,
    int? waterTemperature,
    double? soil1,
    double? soil2,
    double? soil3,
    double? soil4,
    double? soil5,
    String? weatherTemp,
    List<TemperatureReading>? temperatureData,
    List<HumidityReading>? humidityData,
    List<CO2Reading>? co2Data,
    List<ECReading>? ecData,
    List<TDSReading>? tdsData,
    List<TurbidityReading>? turbidityData,
    List<String>? historyDates,
  }) =>
      SensorData(
        airTemperature: airTemperature ?? this.airTemperature,
        airHumidity: airHumidity ?? this.airHumidity,
        co2: co2 ?? this.co2,
        ec: ec ?? this.ec,
        tds: tds ?? this.tds,
        phLevel: phLevel ?? this.phLevel,
        lightLevel: lightLevel ?? this.lightLevel,
        turbidity: turbidity ?? this.turbidity,
        waterTemperature: waterTemperature ?? this.waterTemperature,
        soil1: soil1 ?? this.soil1,
        soil2: soil2 ?? this.soil2,
        soil3: soil3 ?? this.soil3,
        soil4: soil4 ?? this.soil4,
        soil5: soil5 ?? this.soil5,
        weatherTemp: weatherTemp ?? this.weatherTemp,
        temperatureData: temperatureData ?? this.temperatureData,
        humidityData: humidityData ?? this.humidityData,
        co2Data: co2Data ?? this.co2Data,
        ecData: ecData ?? this.ecData,
        tdsData: tdsData ?? this.tdsData,
        turbidityData: turbidityData ?? this.turbidityData,
        historyDates: historyDates ?? this.historyDates,
      );
}

/// Temperature reading with timestamp
class TemperatureReading {
  final double temperature;
  final DateTime timestamp;

  TemperatureReading({
    required this.temperature,
    required this.timestamp,
  });

  factory TemperatureReading.fromJson(Map<String, dynamic> json) =>
      TemperatureReading(
        temperature:
            (json['air_temperature'] as num?)?.toDouble() ?? 0.0,
        timestamp: _parseTimestamp(json['timestamp']),
      );

  Map<String, dynamic> toJson() => {
        'air_temperature': temperature,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Humidity reading with timestamp
class HumidityReading {
  final double humidity;
  final DateTime timestamp;

  HumidityReading({
    required this.humidity,
    required this.timestamp,
  });

  factory HumidityReading.fromJson(Map<String, dynamic> json) =>
      HumidityReading(
        humidity: (json['air_humidity'] as num?)?.toDouble() ?? 0.0,
        timestamp: _parseTimestamp(json['timestamp']),
      );

  Map<String, dynamic> toJson() => {
        'air_humidity': humidity,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// CO2 reading with timestamp
class CO2Reading {
  final double co2;
  final DateTime timestamp;

  CO2Reading({
    required this.co2,
    required this.timestamp,
  });

  factory CO2Reading.fromJson(Map<String, dynamic> json) => CO2Reading(
        co2: (json['co2'] as num?)?.toDouble() ?? 0.0,
      timestamp: _parseTimestamp(json['timestamp']),
      );

  Map<String, dynamic> toJson() => {
        'co2': co2,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// EC (Electrical Conductivity) reading with timestamp
class ECReading {
  final double ec;
  final DateTime timestamp;

  ECReading({
    required this.ec,
    required this.timestamp,
  });

  factory ECReading.fromJson(Map<String, dynamic> json) => ECReading(
        ec: (json['ec'] as num?)?.toDouble() ?? 0.0,
      timestamp: _parseTimestamp(json['timestamp']),
      );

  Map<String, dynamic> toJson() => {
        'ec': ec,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// TDS (Total Dissolved Solids) reading with timestamp
class TDSReading {
  final double tds;
  final DateTime timestamp;

  TDSReading({
    required this.tds,
    required this.timestamp,
  });

  factory TDSReading.fromJson(Map<String, dynamic> json) => TDSReading(
        tds: (json['tds'] as num?)?.toDouble() ?? 0.0,
      timestamp: _parseTimestamp(json['timestamp']),
      );

  Map<String, dynamic> toJson() => {
        'tds': tds,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Turbidity reading with timestamp
class TurbidityReading {
  final double turbidity;
  final DateTime timestamp;

  TurbidityReading({
    required this.turbidity,
    required this.timestamp,
  });

  factory TurbidityReading.fromJson(Map<String, dynamic> json) =>
      TurbidityReading(
        turbidity: (json['turbidity'] as num?)?.toDouble() ?? 0.0,
        timestamp: _parseTimestamp(json['timestamp']),
      );

  Map<String, dynamic> toJson() => {
        'turbidity': turbidity,
        'timestamp': timestamp.toIso8601String(),
      };
}

// Parsing helper functions
List<TemperatureReading> _parseTemperatureData(dynamic data) {
  if (data == null || data is! List) return [];
  return (data as List)
      .map((x) => TemperatureReading.fromJson(x as Map<String, dynamic>))
      .toList();
}

List<HumidityReading> _parseHumidityData(dynamic data) {
  if (data == null || data is! List) return [];
  return (data as List)
      .map((x) => HumidityReading.fromJson(x as Map<String, dynamic>))
      .toList();
}

List<CO2Reading> _parseCO2Data(dynamic data) {
  if (data == null || data is! List) return [];
  return (data as List)
      .map((x) => CO2Reading.fromJson(x as Map<String, dynamic>))
      .toList();
}

List<ECReading> _parseECData(dynamic data) {
  if (data == null || data is! List) return [];
  return (data as List)
      .map((x) => ECReading.fromJson(x as Map<String, dynamic>))
      .toList();
}

List<TDSReading> _parseTDSData(dynamic data) {
  if (data == null || data is! List) return [];
  return (data as List)
      .map((x) => TDSReading.fromJson(x as Map<String, dynamic>))
      .toList();
}

List<TurbidityReading> _parseTurbidityData(dynamic data) {
  if (data == null || data is! List) return [];
  return (data as List)
      .map((x) => TurbidityReading.fromJson(x as Map<String, dynamic>))
      .toList();
}

DateTime _parseTimestamp(dynamic value) {
  if (value == null) return DateTime.now();
  return DateTime.tryParse(value.toString()) ?? DateTime.now();
}
