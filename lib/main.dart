import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/notes_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const TelehealthApp());
}

class TelehealthApp extends StatelessWidget {
  const TelehealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
      ],
      child: MaterialApp(
        title: 'RehaUnified Doctor',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          cardTheme: const CardThemeData(
            surfaceTintColor: Colors.white,
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
