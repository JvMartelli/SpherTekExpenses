import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'pages/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // FFI só para Windows/Linux — Android usa sqflite nativo, web usa SharedPreferences
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const SpherTekApp());
}

class SpherTekApp extends StatelessWidget {
  const SpherTekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spher Tek Expenses',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}