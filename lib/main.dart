import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'animation_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations for better responsive experience
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VPN Max - Ultra Responsive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        // Ensure consistent visual density across devices
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Enhanced responsive text scaling
        textTheme: ThemeData.dark().textTheme.apply(
              fontSizeFactor: 1.0,
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
        // Responsive app bar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A2E),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Enhanced color scheme for better UI
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8A2BE2), // primaryPurple
          secondary: Color(0xFF20E5C7), // accentTeal
          surface: Color(0xFF16213E), // darkBg
        ),
      ),
      home: const AnimationPage(),
      // Enhanced responsive builder for optimal scaling
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final screenWidth = mediaQuery.size.width;
        final screenHeight = mediaQuery.size.height;

        // Calculate optimal text scale factor based on screen size
        double textScaleFactor = 1.0;
        if (screenWidth < 320) {
          textScaleFactor = 0.75; // Extra tiny screens
        } else if (screenWidth < 360) {
          textScaleFactor = 0.80; // Very small screens
        } else if (screenWidth < 480) {
          textScaleFactor = 0.90; // Small screens
        } else if (screenWidth > 1024) {
          textScaleFactor = 1.1; // Large screens/tablets
        }

        // Ensure safe text scaling limits
        final currentTextScale = mediaQuery.textScaler.scale(1.0);
        final clampedTextScale = (currentTextScale * textScaleFactor).clamp(
          0.7,
          1.4,
        );

        return MediaQuery(
          data: mediaQuery.copyWith(
            // Apply calculated text scale factor
            textScaler: TextScaler.linear(clampedTextScale),
            // Ensure proper padding for different screen sizes
            padding: EdgeInsets.only(
              top: mediaQuery.padding.top,
              bottom: mediaQuery.padding.bottom.clamp(0, screenHeight * 0.1),
              left: mediaQuery.padding.left,
              right: mediaQuery.padding.right,
            ),
          ),
          child: Container(
            // Add subtle background for better visual consistency
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A1A2E), // darkBg
                  Color(0xFF16213E), // cardBg
                ],
              ),
            ),
            child: child!,
          ),
        );
      },
    );
  }
}