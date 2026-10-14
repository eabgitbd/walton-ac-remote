import 'package:flutter/material.dart';
import '../controllers/ac_controller.dart';
import '../models/ac_state.dart';
import 'widgets/fstn_screen.dart';
import 'widgets/tactile_button.dart';

class RemoteScreen extends StatefulWidget {
  final AcController controller;

  const RemoteScreen({
    super.key,
    required this.controller,
  });

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onStateChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;

    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0), // Clean neutral desk surface
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC), // Off-white remote shell
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top IR Emitter Lens Dome
                    _buildIrEmitterLens(state.isTransmitting),

                    const SizedBox(height: 10),

                    // Brand Header
                    _buildBrandHeader(),

                    const SizedBox(height: 16),

                    // FSTN Calculator LCD Screen
                    FstnScreen(state: state),

                    const SizedBox(height: 24),

                    // Primary Keypad Area
                    _buildPrimaryControls(state),

                    const SizedBox(height: 18),

                    // Secondary Grid (Fan, Swing, Turbo, Eco)
                    _buildSecondaryControls(state),

                    const SizedBox(height: 20),

                    // Protocol Selector (Gree vs Midea)
                    _buildProtocolSelector(state),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIrEmitterLens(bool isTx) {
    return Container(
      width: 24,
      height: 12,
      decoration: BoxDecoration(
        color: isTx ? const Color(0xFFFF2222) : const Color(0xFF4A1010),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        boxShadow: isTx
            ? [
                const BoxShadow(
                  color: Color(0xAAFF0000),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'WALTON',
              style: TextStyle(
                fontFamily: 'sans-serif',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        const Text(
          'INVERTER AC CONTROLLER',
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.5,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryControls(AcState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Power Button
        Column(
          children: [
            TactileButton(
              onPressed: widget.controller.togglePower,
              width: 64,
              height: 64,
              isCircle: true,
              backgroundColor: state.power ? const Color(0xFFDC2626) : const Color(0xFF991B1B),
              borderColor: const Color(0xFF7F1D1D),
              textColor: Colors.white,
              child: const Icon(Icons.power_settings_new, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 6),
            const Text(
              'POWER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),

        // Temperature Stepper (Up / Down)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF2F7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
          ),
          child: Column(
            children: [
              TactileButton(
                onPressed: state.power ? widget.controller.tempUp : null,
                width: 58,
                height: 48,
                borderRadius: 14,
                backgroundColor: const Color(0xFFFFFFFF),
                textColor: const Color(0xFF0F172A),
                child: const Icon(Icons.add, size: 26, color: Color(0xFF0F172A)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'TEMP',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              TactileButton(
                onPressed: state.power ? widget.controller.tempDown : null,
                width: 58,
                height: 48,
                borderRadius: 14,
                backgroundColor: const Color(0xFFFFFFFF),
                textColor: const Color(0xFF0F172A),
                child: const Icon(Icons.remove, size: 26, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),

        // Mode Button
        Column(
          children: [
            TactileButton(
              onPressed: state.power ? widget.controller.cycleMode : null,
              width: 64,
              height: 64,
              isCircle: true,
              backgroundColor: const Color(0xFF2563EB),
              borderColor: const Color(0xFF1D4ED8),
              textColor: Colors.white,
              child: const Icon(Icons.tune, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 6),
            const Text(
              'MODE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryControls(AcState state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Fan Speed
            _buildAuxButton(
              label: 'FAN',
              icon: Icons.air,
              onPressed: state.power ? widget.controller.cycleFanSpeed : null,
            ),
            // Swing
            _buildAuxButton(
              label: 'SWING',
              icon: Icons.swap_vert,
              onPressed: state.power ? widget.controller.toggleSwing : null,
              isActive: state.swing == AcSwing.vertical,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Turbo
            _buildAuxButton(
              label: 'TURBO',
              icon: Icons.bolt,
              onPressed: state.power ? widget.controller.toggleTurbo : null,
              isActive: state.turbo,
            ),
            // Eco
            _buildAuxButton(
              label: 'ECO',
              icon: Icons.eco,
              onPressed: state.power ? widget.controller.toggleEco : null,
              isActive: state.eco,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuxButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isActive = false,
  }) {
    return TactileButton(
      onPressed: onPressed,
      width: 140,
      height: 46,
      borderRadius: 12,
      backgroundColor: isActive ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF),
      borderColor: isActive ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive ? Colors.white : const Color(0xFF334155),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: isActive ? Colors.white : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolSelector(AcState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'CHIPSET:',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Color(0xFF64748B),
              letterSpacing: 1,
            ),
          ),
          Row(
            children: [
              _buildChipsetOption(
                label: 'GREE (90%)',
                isSelected: state.protocol == AcProtocol.gree,
                onTap: () => widget.controller.switchProtocol(AcProtocol.gree),
              ),
              const SizedBox(width: 6),
              _buildChipsetOption(
                label: 'MIDEA',
                isSelected: state.protocol == AcProtocol.midea,
                onTap: () => widget.controller.switchProtocol(AcProtocol.midea),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChipsetOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
