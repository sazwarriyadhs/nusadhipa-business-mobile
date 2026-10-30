import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/theme.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const NusadhipaBusinessApp());
}

class NusadhipaBusinessApp extends StatelessWidget {
  const NusadhipaBusinessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NUSA-DHIPA Business',
      debugShowCheckedModeBanner: false,
      theme: buildNusadhipaTheme(),
      home: const SplashScreen(), // <--- Tanpa isLoggedIn
    );
  }
}