// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider()..init(),
      child: const AMSApp(),
    ),
  );
}

class AMSApp extends StatelessWidget {
  const AMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return MaterialApp(
      title: 'AMS – Attendance Master Scholar',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: provider.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: provider.isAuthenticated ? const HomeShell() : const LoginScreen(),
    );
  }
}
