import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/theme.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  final loggedIn = await AuthService().isLoggedIn();
  runApp(NusadhipaBusinessApp(isLoggedIn: loggedIn));
}

class NusadhipaBusinessApp extends StatelessWidget {
  final bool isLoggedIn;
  const NusadhipaBusinessApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NUSA-DHIPA Business',
      debugShowCheckedModeBanner: false,
      theme: buildNusadhipaTheme(),
      home: SplashScreen(isLoggedIn: isLoggedIn), // <--- Passing isLoggedIn
    );
  }
}