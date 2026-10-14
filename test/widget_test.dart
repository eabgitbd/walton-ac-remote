import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walton_ac_remote/controllers/ac_controller.dart';
import 'package:walton_ac_remote/main.dart';
import 'package:walton_ac_remote/services/ir_service.dart';

class MockIrService extends IrService {
  @override
  Future<bool> hasIrEmitter() async => true;

  @override
  Future<bool> transmit({required int frequency, required List<int> pattern}) async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Walton AC Remote UI renders correctly', (WidgetTester tester) async {
    final mockIr = MockIrService();
    final controller = AcController(irService: mockIr);

    await tester.pumpWidget(WaltonAcRemoteApp(controller: controller));
    await tester.pumpAndSettle();

    // Verify brand title
    expect(find.text('WALTON'), findsOneWidget);
    expect(find.text('INVERTER AC CONTROLLER'), findsOneWidget);

    // Verify initial screen state shows STANDBY when power is off
    expect(find.text('STANDBY'), findsOneWidget);

    // Tap Power Button
    final powerButton = find.byIcon(Icons.power_settings_new);
    expect(powerButton, findsOneWidget);
    await tester.tap(powerButton);
    await tester.pumpAndSettle();

    // Power is ON: STANDBY should disappear
    expect(find.text('STANDBY'), findsNothing);
  });
}
