import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/capsule_provider.dart';
import 'screens/main_screen.dart';
import 'widgets/launch_intro_overlay.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CapsuleProvider()),
      ],
      child: const OmniCapsuleApp(),
    ),
  );
}

class OmniCapsuleApp extends StatelessWidget {
  const OmniCapsuleApp({Key? key}) : super(key: key);

  ThemeData _buildDefaultTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: Colors.deepPurpleAccent,
      colorScheme: const ColorScheme.dark(
        primary: Colors.deepPurpleAccent,
        secondary: Colors.deepPurple,
        surface: Color(0xFF1E1E1E),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  ThemeData _buildMonochromeTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      primaryColor: Colors.white,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: Colors.white70,
        surface: Color(0xFF101010),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF101010),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CapsuleProvider>(
      builder: (context, provider, child) {
        final isMono = provider.themeStyle == AppThemeStyle.monochrome;
        const appHome = LaunchIntroOverlay(child: MainScreen());

        return MaterialApp(
          title: 'Pickup',
          debugShowCheckedModeBanner: false,
          theme: isMono ? _buildMonochromeTheme() : _buildDefaultTheme(),
          home: appHome,
        );
      },
    );
  }
}
