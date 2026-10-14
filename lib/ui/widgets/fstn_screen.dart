import 'package:flutter/material.dart';
import '../../models/ac_state.dart';
import 'lcd_digits_painter.dart';

class FstnScreen extends StatelessWidget {
  final AcState state;

  const FstnScreen({
    super.key,
    required this.state,
  });

  static const Color lcdBackground = Color(0xFF98A886);
  static const Color lcdActive = Color(0xFF142113);
  static const Color lcdGhost = Color(0x24142113);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2B332A), // Dark plastic bezel frame
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: lcdBackground,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF7A896C), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(1.5, 1.5),
              blurRadius: 2,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Stack(
            children: [
              // Screen content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Status Row
                    _buildTopStatusBar(),

                    // Main Center Row (Temperature or Standby)
                    Expanded(
                      child: Center(
                        child: state.power
                            ? SizedBox(
                                width: 140,
                                height: 75,
                                child: CustomPaint(
                                  painter: LcdDigitsPainter(
                                    value: state.temperature,
                                    isPowerOn: true,
                                    activeColor: lcdActive,
                                    ghostColor: lcdGhost,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'STANDBY',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 4,
                                      color: lcdActive.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    // Bottom Functions & Modes Row
                    _buildBottomFunctionBar(),
                  ],
                ),
              ),

              // Diagonal glass glare / specular reflection
              Positioned(
                top: 0,
                right: 0,
                width: 90,
                height: 90,
                child: CustomPaint(
                  painter: _GlassGlarePainter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopStatusBar() {
    final bool hasEmitter = state.hasIrEmitter ?? true;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Hardware IR Status
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasEmitter ? lcdActive : const Color(0xFF8B2500),
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                hasEmitter ? 'IR READY' : 'NO IR SENSOR',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: hasEmitter ? lcdActive : const Color(0xFF8B2500),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Transmitting animation pulse
            if (state.isTransmitting)
              Row(
                children: [
                  Icon(Icons.wifi_tethering, size: 13, color: lcdActive),
                  const SizedBox(width: 2),
                  const Text(
                    'TX',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: lcdActive,
                    ),
                  ),
                ],
              )
            else
              Text(
                'TX',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: lcdGhost,
                ),
              ),
          ],
        ),

        // Active Profile Identifier
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
          decoration: BoxDecoration(
            color: lcdActive,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            state.protocol == AcProtocol.gree ? 'PROFILE: GREE' : 'PROFILE: MIDEA',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: lcdBackground,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomFunctionBar() {
    return Column(
      children: [
        // Modes row: AUTO | COOL | DRY | FAN | HEAT
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: AcMode.values.map((mode) {
            final isCurrent = state.power && state.mode == mode;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: isCurrent ? lcdActive : Colors.transparent,
                border: Border.all(
                  color: isCurrent ? lcdActive : lcdGhost,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                mode.label,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isCurrent ? lcdBackground : lcdGhost,
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 5),

        // Fan Speed & Aux Status Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Fan Indicator: AUTO or stepped bars
            Row(
              children: [
                Text(
                  'FAN: ',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: state.power ? lcdActive : lcdGhost,
                  ),
                ),
                if (state.fanSpeed == AcFanSpeed.auto)
                  Text(
                    'AUTO',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: state.power ? lcdActive : lcdGhost,
                    ),
                  )
                else
                  Row(
                    children: List.generate(3, (index) {
                      final activeBar = state.power && index < state.fanSpeed.barCount;
                      return Container(
                        margin: const EdgeInsets.only(right: 2.5),
                        width: 7,
                        height: 7.0 + (index * 3.0),
                        color: activeBar ? lcdActive : lcdGhost,
                      );
                    }),
                  ),
              ],
            ),

            // Swing indicator
            Row(
              children: [
                Text(
                  'SWING: ',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: (state.power && state.swing == AcSwing.vertical) ? lcdActive : lcdGhost,
                  ),
                ),
                Text(
                  state.swing == AcSwing.vertical ? '⇳ ON' : 'OFF',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: (state.power && state.swing == AcSwing.vertical) ? lcdActive : lcdGhost,
                  ),
                ),
              ],
            ),

            // Turbo / Eco indicators
            Row(
              children: [
                Text(
                  'TURBO',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: (state.power && state.turbo) ? lcdActive : lcdGhost,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'ECO',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: (state.power && state.eco) ? lcdActive : lcdGhost,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _GlassGlarePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0x35FFFFFF),
          Color(0x05FFFFFF),
          Colors.transparent,
        ],
        stops: [0.0, 0.4, 0.8],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(size.width * 0.4, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.6)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
