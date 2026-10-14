import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walton_ac_remote/controllers/ac_controller.dart';
import 'package:walton_ac_remote/models/ac_state.dart';
import 'package:walton_ac_remote/services/ir_service.dart';

class MockIrService extends IrService {
  bool hasEmitterValue = true;
  int transmitCount = 0;
  int? lastFrequency;
  List<int>? lastPattern;

  @override
  Future<bool> hasIrEmitter() async => hasEmitterValue;

  @override
  Future<bool> transmit({required int frequency, required List<int> pattern}) async {
    transmitCount++;
    lastFrequency = frequency;
    lastPattern = pattern;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AcController Logic Tests', () {
    test('Toggle power changes power state', () async {
      final mockIr = MockIrService();
      final controller = AcController(irService: mockIr);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.state.power, isFalse);

      controller.togglePower();
      expect(controller.state.power, isTrue);

      controller.togglePower();
      expect(controller.state.power, isFalse);
    });

    test('Temperature adjustments strictly bounded (16..30)', () async {
      final mockIr = MockIrService();
      final controller = AcController(irService: mockIr);
      await Future.delayed(const Duration(milliseconds: 50));

      controller.togglePower(); // Turn on to allow temp changes

      // Max test
      for (int i = 0; i < 20; i++) {
        controller.tempUp();
      }
      expect(controller.state.temperature, 30);

      // Min test
      for (int i = 0; i < 20; i++) {
        controller.tempDown();
      }
      expect(controller.state.temperature, 16);
    });

    test('Switch protocol updates active chipset', () async {
      final mockIr = MockIrService();
      final controller = AcController(irService: mockIr);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.state.protocol, AcProtocol.gree);

      controller.switchProtocol(AcProtocol.midea);
      expect(controller.state.protocol, AcProtocol.midea);
    });
  });
}
