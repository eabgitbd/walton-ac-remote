enum AcMode {
  auto,
  cool,
  dry,
  fan,
  heat;

  String get label {
    switch (this) {
      case AcMode.auto:
        return 'AUTO';
      case AcMode.cool:
        return 'COOL';
      case AcMode.dry:
        return 'DRY';
      case AcMode.fan:
        return 'FAN';
      case AcMode.heat:
        return 'HEAT';
    }
  }
}

enum AcFanSpeed {
  auto,
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case AcFanSpeed.auto:
        return 'AUTO';
      case AcFanSpeed.low:
        return 'LOW';
      case AcFanSpeed.medium:
        return 'MED';
      case AcFanSpeed.high:
        return 'HIGH';
    }
  }

  int get barCount {
    switch (this) {
      case AcFanSpeed.auto:
        return 0;
      case AcFanSpeed.low:
        return 1;
      case AcFanSpeed.medium:
        return 2;
      case AcFanSpeed.high:
        return 3;
    }
  }
}

enum AcSwing {
  off,
  vertical;

  String get label => this == AcSwing.vertical ? 'SWING ON' : 'SWING OFF';
}

enum AcProtocol {
  gree,
  midea;

  String get displayName => this == AcProtocol.gree ? 'Gree / Walton A' : 'Midea / Walton B';
}

class AcState {
  final bool power;
  final int temperature; // 16 to 30
  final AcMode mode;
  final AcFanSpeed fanSpeed;
  final AcSwing swing;
  final bool turbo;
  final bool eco;
  final AcProtocol protocol;
  final bool isTransmitting;
  final bool? hasIrEmitter;

  const AcState({
    this.power = false,
    this.temperature = 24,
    this.mode = AcMode.cool,
    this.fanSpeed = AcFanSpeed.auto,
    this.swing = AcSwing.off,
    this.turbo = false,
    this.eco = false,
    this.protocol = AcProtocol.gree,
    this.isTransmitting = false,
    this.hasIrEmitter,
  });

  AcState copyWith({
    bool? power,
    int? temperature,
    AcMode? mode,
    AcFanSpeed? fanSpeed,
    AcSwing? swing,
    bool? turbo,
    bool? eco,
    AcProtocol? protocol,
    bool? isTransmitting,
    bool? hasIrEmitter,
  }) {
    return AcState(
      power: power ?? this.power,
      temperature: (temperature ?? this.temperature).clamp(16, 30),
      mode: mode ?? this.mode,
      fanSpeed: fanSpeed ?? this.fanSpeed,
      swing: swing ?? this.swing,
      turbo: turbo ?? this.turbo,
      eco: eco ?? this.eco,
      protocol: protocol ?? this.protocol,
      isTransmitting: isTransmitting ?? this.isTransmitting,
      hasIrEmitter: hasIrEmitter ?? this.hasIrEmitter,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'power': power,
      'temperature': temperature,
      'mode': mode.index,
      'fanSpeed': fanSpeed.index,
      'swing': swing.index,
      'turbo': turbo,
      'eco': eco,
      'protocol': protocol.index,
    };
  }

  factory AcState.fromJson(Map<String, dynamic> json) {
    return AcState(
      power: json['power'] as bool? ?? false,
      temperature: (json['temperature'] as int? ?? 24).clamp(16, 30),
      mode: AcMode.values[(json['mode'] as int? ?? 1).clamp(0, AcMode.values.length - 1)],
      fanSpeed: AcFanSpeed.values[(json['fanSpeed'] as int? ?? 0).clamp(0, AcFanSpeed.values.length - 1)],
      swing: AcSwing.values[(json['swing'] as int? ?? 0).clamp(0, AcSwing.values.length - 1)],
      turbo: json['turbo'] as bool? ?? false,
      eco: json['eco'] as bool? ?? false,
      protocol: AcProtocol.values[(json['protocol'] as int? ?? 0).clamp(0, AcProtocol.values.length - 1)],
    );
  }
}
