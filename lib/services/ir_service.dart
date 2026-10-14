import 'dart:developer' as developer;
import 'package:flutter/services.dart';

class IrService {
  static const MethodChannel _channel = MethodChannel('com.walton.acremote/ir');

  Future<bool> hasIrEmitter() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('hasIrEmitter');
      return result ?? false;
    } on PlatformException catch (e) {
      developer.log('Failed to check IR emitter: ${e.message}');
      return false;
    } on MissingPluginException {
      developer.log('IR plugin not available on this platform (desktop/test)');
      return false;
    }
  }

  Future<List<Map<String, int>>> getCarrierFrequencies() async {
    try {
      final List<dynamic>? rawList =
          await _channel.invokeMethod<List<dynamic>>('getCarrierFrequencies');
      if (rawList == null) return [];
      return rawList.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return {
          'min': map['min'] as int? ?? 0,
          'max': map['max'] as int? ?? 0,
        };
      }).toList();
    } catch (e) {
      developer.log('Error reading carrier frequencies: $e');
      return [];
    }
  }

  Future<bool> transmit({
    required int frequency,
    required List<int> pattern,
  }) async {
    try {
      final bool? success = await _channel.invokeMethod<bool>('transmit', {
        'frequency': frequency,
        'pattern': pattern,
      });
      return success ?? false;
    } on PlatformException catch (e) {
      developer.log('Transmission error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      developer.log('Unexpected transmit error: $e');
      return false;
    }
  }
}
