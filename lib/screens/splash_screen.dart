import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'tenant_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Delay 2 detik buat nampilin splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Cek apakah user udah login
    final isLoggedIn = await AuthService().isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TenantShell()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // <--- Background PUTIH
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo NUSA-DHIPA
            Image.asset(
              'assets/branding/logo_nusadhipa.png',
              width: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            // Loading indicator merah
            const CircularProgressIndicator(
              color: Color(0xFFE5232E), // Merah NUSA-DHIPA
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Memuat aplikasi...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}