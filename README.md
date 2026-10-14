# Walton AC Remote

A lightweight, distraction-free Android application built with **Flutter** to control Walton Air Conditioners using hardware Infrared (IR) blasters.

Featuring an authentic retro **FSTN (Film-compensated Super Twisted Nematic) calculator-style LCD screen** and tactile industrial remote controls.

---

## Features

- **Retro Calculator FSTN LCD Display:**
  - Olive-green monochrome background (`#98A886`) with authentic unlit ghost segments (`#859673`) and dark active segments (`#142113`).
  - Pure vector 7-segment digital temperature display with °C symbol.
  - Active mode annunciators: `[AUTO]`, `[COOL]`, `[DRY]`, `[FAN]`, `[HEAT]`.
  - 3-step digital fan speed ladder bar indicators and vertical swing vane status.
  - `[IR READY]` / `[NO IR SENSOR]` hardware diagnostics indicator.
  - Real-time `TX` transmitting animation badge with top IR emitter lens glow.

- **Dual-Protocol Hardware Support (Walton Compatibility):**
  - **Gree YAA1FB Protocol (Default):** Covers >80% of Walton split and inverter AC models (38 kHz carrier, 9000/4500µs leader, 32-bit block 1, 20ms pause, 32-bit block 2 with dynamic checksum).
  - **Midea/Coolix Protocol:** Covers alternative Walton inverter models (38 kHz carrier, 48-bit frame with complement validation).
  - Quick toggle switch directly on the remote keypad to switch chipsets on the fly.

- **Tactile Keypad with Haptics:**
  - Physical button depress animations with light tactile haptic vibration.
  - High-visibility crimson power button, ergonomic temperature up/down rockers, and clean auxiliary keys.

- **Ultra-Lightweight & Private:**
  - Zero advertisement SDKs, zero background trackers.
  - Fully offline (omits `INTERNET` permission).
  - Release APK size ~5MB (split ABI) / ~12MB (universal).

---

## Building the APK

This repository includes a GitHub Actions CI workflow in `.github/workflows/build_apk.yml` that automatically tests, compiles, and generates release APKs on every push.
