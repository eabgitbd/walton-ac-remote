import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'controllers/ac_controller.dart';
import 'ui/remote_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode for authentic physical remote feel
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Clean edge-to-edge transparent system overlays
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFE2E8F0),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final controller = AcController();

  runApp(WaltonAcRemoteApp(controller: controller));
}

class WaltonAcRemoteApp extends StatelessWidget {
  final AcController controller;

  const WaltonAcRemoteApp({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Walton AC Remote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFE2E8F0),
        fontFamily: 'sans-serif',
      ),
      home: RemoteScreen(controller: controller),
    );
  }
}
