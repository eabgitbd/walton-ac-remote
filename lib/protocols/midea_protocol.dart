import '../models/ac_state.dart';
import 'ir_protocol.dart';

class MideaProtocol implements IrProtocol {
  @override
  int get carrierFrequency => 38000;

  static const int headerMark = 4400;
  static const int headerSpace = 4400;
  static const int bitMark = 540;
  static const int zeroSpace = 540;
  static const int oneSpace = 1620;
  static const int stopMark = 540;
  static const int stopSpace = 10000;

  @override
  List<int> encode(AcState state) {
    final List<int> pattern = [];

    // Midea format: 3 bytes + 3 inverted complement bytes (total 6 bytes / 48 bits)
    // Byte 0: Appliance identifier (0xB2)
    final int b0 = 0xB2;
    final int b1 = (~b0) & 0xFF;

    // Byte 2: Temp & Mode
    // Midea Temp mapping: 17°C = 0, 18°C = 1, ... 30°C = 13
    final int tempCode = (state.temperature - 17).clamp(0, 13);
    int modeCode = 0; // Cool
    switch (state.mode) {
      case AcMode.cool:
        modeCode = 0x00;
        break;
      case AcMode.dry:
        modeCode = 0x04;
        break;
      case AcMode.auto:
        modeCode = 0x08;
        break;
      case AcMode.heat:
        modeCode = 0x0C;
        break;
      case AcMode.fan:
        modeCode = 0x04; // Fan/Dry shared
        break;
    }

    final int b2 = (tempCode << 4) | (modeCode & 0x0F);
    final int b3 = (~b2) & 0xFF;

    // Byte 4: Fan & Power & Extras
    int fanCode = 0x00; // Auto
    switch (state.fanSpeed) {
      case AcFanSpeed.auto:
        fanCode = 0x00;
        break;
      case AcFanSpeed.low:
        fanCode = 0x04;
        break;
      case AcFanSpeed.medium:
        fanCode = 0x02;
        break;
      case AcFanSpeed.high:
        fanCode = 0x01;
        break;
    }

    final int powerCode = state.power ? 0x00 : 0x40; // Power bit
    final int b4 = powerCode | (fanCode << 2);
    final int b5 = (~b4) & 0xFF;

    final bytes = [b0, b1, b2, b3, b4, b5];

    // Encode
    pattern.add(headerMark);
    pattern.add(headerSpace);

    for (int b in bytes) {
      for (int bit = 7; bit >= 0; bit--) {
        pattern.add(bitMark);
        if (((b >> bit) & 0x01) == 1) {
          pattern.add(oneSpace);
        } else {
          pattern.add(zeroSpace);
        }
      }
    }

    pattern.add(stopMark);
    pattern.add(stopSpace);

    return pattern;
  }
}
