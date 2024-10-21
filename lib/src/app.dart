// lib/src/app.dart
import 'package:flutter/material.dart';
import 'settings/settings_controller.dart';
import 'home_screen.dart';
import 'speech_text_screen.dart';  // Importa la nueva vista
import 'gps_screen.dart';
import 'qr_scanner_screen.dart';
import 'sensor_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppMovil que utiliza las herramientas del teléfono',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: settingsController.themeMode,
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        SpeechTextScreen.routeName: (context) => SpeechTextScreen(),  // Nueva ruta
        GPSScreen.routeName: (context) => const GPSScreen(),
        QRScannerScreen.routeName: (context) => const QRScannerScreen(),
        SensorScreen.routeName: (context) => const SensorScreen(),
      },
    );
  }
}

