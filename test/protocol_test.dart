import 'package:flutter_test/flutter_test.dart';
import 'package:walton_ac_remote/models/ac_state.dart';
import 'package:walton_ac_remote/protocols/gree_protocol.dart';
import 'package:walton_ac_remote/protocols/midea_protocol.dart';

void main() {
  group('AcState Model Tests', () {
    test('Default values are valid', () {
      const state = AcState();
      expect(state.power, isFalse);
      expect(state.temperature, 24);
      expect(state.mode, AcMode.cool);
      expect(state.fanSpeed, AcFanSpeed.auto);
      expect(state.swing, AcSwing.off);
      expect(state.protocol, AcProtocol.gree);
    });

    test('Temperature is clamped between 16 and 30', () {
      final coldState = const AcState().copyWith(temperature: 10);
      expect(coldState.temperature, 16);

      final hotState = const AcState().copyWith(temperature: 45);
      expect(hotState.temperature, 30);
    });

    test('JSON serialization roundtrip works cleanly', () {
      const state = AcState(
        power: true,
        temperature: 21,
        mode: AcMode.dry,
        fanSpeed: AcFanSpeed.high,
        swing: AcSwing.vertical,
        turbo: true,
        eco: true,
        protocol: AcProtocol.midea,
      );
      final json = state.toJson();
      final restored = AcState.fromJson(json);

      expect(restored.power, state.power);
      expect(restored.temperature, state.temperature);
      expect(restored.mode, state.mode);
      expect(restored.fanSpeed, state.fanSpeed);
      expect(restored.swing, state.swing);
      expect(restored.turbo, state.turbo);
      expect(restored.eco, state.eco);
      expect(restored.protocol, state.protocol);
    });
  });

  group('GreeProtocol Tests', () {
    final gree = GreeProtocol();

    test('Carrier frequency is 38 kHz', () {
      expect(gree.carrierFrequency, 38000);
    });

    test('Encodes pattern with correct header and trailer', () {
      const state = AcState(power: true, temperature: 24, mode: AcMode.cool);
      final pattern = gree.encode(state);

      // Leader mark & space
      expect(pattern[0], GreeProtocol.headerMark);
      expect(pattern[1], GreeProtocol.headerSpace);

      // Separator mark & space should exist in the pattern
      expect(pattern.contains(GreeProtocol.separatorSpace), isTrue);

      // Total items: 2 (header) + 32*2 (block 1) + 2 (separator) + 32*2 (block 2) + 2 (trailer) = 136 timings
      expect(pattern.length, 136);
    });
  });

  group('MideaProtocol Tests', () {
    final midea = MideaProtocol();

    test('Carrier frequency is 38 kHz', () {
      expect(midea.carrierFrequency, 38000);
    });

    test('Encodes 48-bit frame with header and stop pulse', () {
      const state = AcState(power: true, temperature: 22, mode: AcMode.cool);
      final pattern = midea.encode(state);

      expect(pattern[0], MideaProtocol.headerMark);
      expect(pattern[1], MideaProtocol.headerSpace);

      // Total items: 2 (header) + 48*2 (bits) + 2 (stop) = 100 timings
      expect(pattern.length, 100);
    });
  });
}
