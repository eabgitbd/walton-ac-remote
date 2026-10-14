import '../models/ac_state.dart';
import 'ir_protocol.dart';

class GreeProtocol implements IrProtocol {
  @override
  int get carrierFrequency => 38000; // 38 kHz

  static const int headerMark = 9000;
  static const int headerSpace = 4500;
  static const int bitMark = 560;
  static const int zeroSpace = 560;
  static const int oneSpace = 1680;
  static const int separatorMark = 560;
  static const int separatorSpace = 20000;
  static const int trailerMark = 560;
  static const int trailerSpace = 40000;

  @override
  List<int> encode(AcState state) {
    final List<int> pattern = [];

    // Construct 8 data bytes
    final List<int> bytes = List.filled(8, 0);

    // Byte 0: Mode (3 bits) | Power (1 bit) | Fan (2 bits) | Swing (1 bit) | Sleep (1 bit)
    int modeBits = 0; // Auto
    switch (state.mode) {
      case AcMode.auto:
        modeBits = 0;
        break;
      case AcMode.cool:
        modeBits = 1;
        break;
      case AcMode.dry:
        modeBits = 2;
        break;
      case AcMode.fan:
        modeBits = 3;
        break;
      case AcMode.heat:
        modeBits = 4;
        break;
    }

    final int powerBit = state.power ? 1 : 0;

    int fanBits = 0; // Auto
    switch (state.fanSpeed) {
      case AcFanSpeed.auto:
        fanBits = 0;
        break;
      case AcFanSpeed.low:
        fanBits = 1;
        break;
      case AcFanSpeed.medium:
        fanBits = 2;
        break;
      case AcFanSpeed.high:
        fanBits = 3;
        break;
    }

    final int swingBit = state.swing == AcSwing.vertical ? 1 : 0;
    const int sleepBit = 0;

    bytes[0] = (modeBits & 0x07) |
        ((powerBit & 0x01) << 3) |
        ((fanBits & 0x03) << 4) |
        ((swingBit & 0x01) << 6) |
        ((sleepBit & 0x01) << 7);

    // Byte 1: Temperature (4 bits: temp - 16)
    final int tempVal = (state.temperature - 16).clamp(0, 14);
    bytes[1] = tempVal & 0x0F;

    // Byte 2: Timer/Options (default 0)
    bytes[2] = 0x00;

    // Byte 3: Model code (Gree standard model nibble: 0x50)
    bytes[3] = 0x50;

    // Byte 4: Turbo, Light, Health
    final int turboBit = state.turbo ? 1 : 0;
    const int lightBit = 1; // Display light on
    bytes[4] = ((turboBit & 0x01) << 4) | ((lightBit & 0x01) << 5);

    // Byte 5: Quiet / Timer
    bytes[5] = 0x00;

    // Byte 6: Energy saving / Eco
    final int ecoBit = state.eco ? 1 : 0;
    bytes[6] = (ecoBit & 0x01) << 2;

    // Byte 7: Checksum
    // Gree checksum calculation:
    // (Byte 0 + Byte 1 + Byte 2 + Byte 3 + Byte 4 + Byte 5 + Byte 6 + checksum_offset) & 0x0F
    int sum = 0;
    for (int i = 0; i < 7; i++) {
      sum += (bytes[i] & 0x0F) + ((bytes[i] >> 4) & 0x0F);
    }
    // Gree checksum offset is typically 0x0A for YAA1FB
    final int checksum = (sum + 0x0A) & 0x0F;
    bytes[7] = (checksum << 4);

    // Encode to pulse timings
    // 1. Leader
    pattern.add(headerMark);
    pattern.add(headerSpace);

    // 2. Block 1 (bytes 0..3), LSB first
    for (int b = 0; b < 4; b++) {
      _appendByte(pattern, bytes[b]);
    }

    // 3. Separator between blocks
    pattern.add(separatorMark);
    pattern.add(separatorSpace);

    // 4. Block 2 (bytes 4..7), LSB first
    for (int b = 4; b < 8; b++) {
      _appendByte(pattern, bytes[b]);
    }

    // 5. Trailer pulse
    pattern.add(trailerMark);
    pattern.add(trailerSpace);

    return pattern;
  }

  void _appendByte(List<int> pattern, int byteVal) {
    for (int bit = 0; bit < 8; bit++) {
      pattern.add(bitMark);
      if (((byteVal >> bit) & 0x01) == 1) {
        pattern.add(oneSpace);
      } else {
        pattern.add(zeroSpace);
      }
    }
  }
}
