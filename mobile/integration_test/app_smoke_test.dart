import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('integration test harness starts', (tester) async {
    // Baseline integration smoke test to verify test wiring.
    expect(true, isTrue);
  });
}
