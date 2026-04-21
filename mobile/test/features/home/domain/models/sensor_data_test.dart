import 'package:flutter_test/flutter_test.dart';
import 'package:diploma_mobile_app/features/home/domain/models/sensor_data.dart';

void main() {
  group('SensorData', () {
    test('fromJson parses scalar values and history collections', () {
      final model = SensorData.fromJson({
        'air_temperature': 23.5,
        'air_humidity': 60,
        'co2': 420,
        'ec': 1.5,
        'tds': 700,
        'ph_level': 6.2,
        'light_level': 1200,
        'turbidity': 3.1,
        'water_temperature': 21,
        'soil1': 11,
        'soil2': 12,
        'soil3': 13,
        'soil4': 14,
        'soil5': 15,
        'history_data': ['2026-04-20', '2026-04-21'],
        'temperature_data': [
          {'air_temperature': 23.5, 'timestamp': '2026-04-21T10:00:00Z'}
        ],
      });

      expect(model.airTemperature, 23.5);
      expect(model.airHumidity, 60.0);
      expect(model.waterTemperature, 21);
      expect(model.temperatureData.length, 1);
      expect(model.historyDates, ['2026-04-20', '2026-04-21']);
    });

    test('fromJson defaults missing collections to empty lists', () {
      final model = SensorData.fromJson({});

      expect(model.temperatureData, isEmpty);
      expect(model.humidityData, isEmpty);
      expect(model.co2Data, isEmpty);
      expect(model.ecData, isEmpty);
      expect(model.tdsData, isEmpty);
      expect(model.turbidityData, isEmpty);
      expect(model.historyDates, isEmpty);
      expect(model.airTemperature, 0.0);
    });
  });
}
