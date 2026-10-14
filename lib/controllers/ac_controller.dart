import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ac_state.dart';
import '../protocols/gree_protocol.dart';
import '../protocols/midea_protocol.dart';
import '../services/ir_service.dart';

class AcController extends ChangeNotifier {
  final IrService _irService;
  final GreeProtocol _gree = GreeProtocol();
  final MideaProtocol _midea = MideaProtocol();

  AcState _state = const AcState();

  AcState get state => _state;

  AcController({IrService? irService}) : _irService = irService ?? IrService() {
    _init();
  }

  static const String _prefKey = 'walton_ac_state_v1';

  Future<void> _init() async {
    await _loadSavedState();
    await checkHardware();
  }

  Future<void> checkHardware() async {
    final hasEmitter = await _irService.hasIrEmitter();
    _state = _state.copyWith(hasIrEmitter: hasEmitter);
    notifyListeners();
  }

  Future<void> _loadSavedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw != null) {
        final Map<String, dynamic> data = jsonDecode(raw);
        _state = AcState.fromJson(data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load saved AC state: $e');
    }
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(_state.toJson());
      await prefs.setString(_prefKey, raw);
    } catch (e) {
      debugPrint('Failed to save AC state: $e');
    }
  }

  Future<void> _transmit() async {
    final protocol = _state.protocol == AcProtocol.gree ? _gree : _midea;
    final pattern = protocol.encode(_state);

    _state = _state.copyWith(isTransmitting: true);
    notifyListeners();

    await _irService.transmit(
      frequency: protocol.carrierFrequency,
      pattern: pattern,
    );

    // Keep the TX indicator visible for 250ms for visual satisfaction
    await Future.delayed(const Duration(milliseconds: 250));
    _state = _state.copyWith(isTransmitting: false);
    notifyListeners();

    _saveState();
  }

  void togglePower() {
    _state = _state.copyWith(power: !_state.power);
    notifyListeners();
    _transmit();
  }

  void tempUp() {
    if (!_state.power) return;
    if (_state.temperature < 30) {
      _state = _state.copyWith(temperature: _state.temperature + 1);
      notifyListeners();
      _transmit();
    }
  }

  void tempDown() {
    if (!_state.power) return;
    if (_state.temperature > 16) {
      _state = _state.copyWith(temperature: _state.temperature - 1);
      notifyListeners();
      _transmit();
    }
  }

  void cycleMode() {
    if (!_state.power) return;
    final nextIndex = (_state.mode.index + 1) % AcMode.values.length;
    _state = _state.copyWith(mode: AcMode.values[nextIndex]);
    notifyListeners();
    _transmit();
  }

  void cycleFanSpeed() {
    if (!_state.power) return;
    final nextIndex = (_state.fanSpeed.index + 1) % AcFanSpeed.values.length;
    _state = _state.copyWith(fanSpeed: AcFanSpeed.values[nextIndex]);
    notifyListeners();
    _transmit();
  }

  void toggleSwing() {
    if (!_state.power) return;
    final nextSwing = _state.swing == AcSwing.off ? AcSwing.vertical : AcSwing.off;
    _state = _state.copyWith(swing: nextSwing);
    notifyListeners();
    _transmit();
  }

  void toggleTurbo() {
    if (!_state.power) return;
    _state = _state.copyWith(turbo: !_state.turbo);
    notifyListeners();
    _transmit();
  }

  void toggleEco() {
    if (!_state.power) return;
    _state = _state.copyWith(eco: !_state.eco);
    notifyListeners();
    _transmit();
  }

  void switchProtocol(AcProtocol proto) {
    if (_state.protocol == proto) return;
    _state = _state.copyWith(protocol: proto);
    notifyListeners();
    _transmit();
  }
}
