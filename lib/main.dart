import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'animation_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;
  late AnimationController _barController;
  late Animation<double> _barAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();

    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
    _barAnimation = CurvedAnimation(parent: _barController, curve: Curves.easeInOut);
    _barController.forward();

    _barController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AnimationPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;
    final isMedium = screenWidth >= 360 && screenWidth < 480;
    final fontSize = isSmall ? 36.0 : (isMedium ? 48.0 : 56.0);
    final iconSize = isSmall ? 60.0 : (isMedium ? 80.0 : 100.0);
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF20E5C7),
            ],
            stops: [0.0, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            FadeTransition(
              opacity: _fadeIn,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmall ? 18 : 24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.secondary.withOpacity(0.18),
                            blurRadius: 32,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.security_rounded,
                        color: theme.colorScheme.secondary,
                        size: iconSize,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'VPN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.22),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              TextSpan(
                                text: ' Max',
                                style: TextStyle(
                                  color: theme.colorScheme.secondary,
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: theme.colorScheme.secondary.withOpacity(0.22),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: -8,
                          child: Container(
                            width: fontSize * 3,
                            height: 7,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.secondary.withOpacity(0.0),
                                  theme.colorScheme.secondary.withOpacity(0.7),
                                  theme.colorScheme.secondary.withOpacity(0.0),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.secondary.withOpacity(0.18),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: isSmall ? 18 : 28),
                      child: Text(
                        'Ultra Responsive VPN for Secure & Fast Browsing',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isSmall ? 13 : (isMedium ? 15 : 18),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.05,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Loading bar at the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).padding.bottom + 32,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmall ? 32 : 64),
                child: AnimatedBuilder(
                  animation: _barAnimation,
                  builder: (context, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: _barAnimation.value,
                        backgroundColor: Colors.white.withOpacity(0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Restrict app to portrait mode only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
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
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: ThemeData.dark().textTheme.apply(
              fontSizeFactor: 1.0,
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A2E),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8A2BE2),
          secondary: Color(0xFF20E5C7),
          surface: Color(0xFF16213E),
        ),
      ),
      home: const SplashScreen(),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final screenWidth = mediaQuery.size.width;
        final screenHeight = mediaQuery.size.height;

        double textScaleFactor = 1.0;
        if (screenWidth < 320) {
          textScaleFactor = 0.75;
        } else if (screenWidth < 360) {
          textScaleFactor = 0.80;
        } else if (screenWidth < 480) {
          textScaleFactor = 0.90;
        } else if (screenWidth > 1024) {
          textScaleFactor = 1.1;
        }

        final currentTextScale = mediaQuery.textScaler.scale(1.0);
        final clampedTextScale = (currentTextScale * textScaleFactor).clamp(
          0.7,
          1.4,
        );

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(clampedTextScale),
            padding: EdgeInsets.only(
              top: mediaQuery.padding.top,
              bottom: mediaQuery.padding.bottom.clamp(0, screenHeight * 0.1),
              left: mediaQuery.padding.left,
              right: mediaQuery.padding.right,
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
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