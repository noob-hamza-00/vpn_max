import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_preview/device_preview.dart';
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
    final screenHeight = MediaQuery.of(context).size.height;
    // Proportional sizes for any device
    double fontSize = screenWidth * 0.10;
    double iconSize = screenWidth * 0.18;
    double boxPadding = screenWidth * 0.05;
    double boxShadowBlur = screenWidth * 0.09;
    double boxShadowOffset = screenHeight * 0.012;
    double titleUnderlineWidth = fontSize * 2.5;
    double titleUnderlineHeight = screenHeight * 0.012;
    double titleUnderlineBlur = screenWidth * 0.03;
    double verticalSpacing1 = screenHeight * 0.04;
    double verticalSpacing2 = screenHeight * 0.02;
    double textPaddingH = screenWidth * 0.05;
    double smallTextSize = screenWidth * 0.035;
    double progressBarHeight = screenHeight * 0.012;
    double progressBarPaddingH = screenWidth * 0.08;
    double progressBarBottom = MediaQuery.of(context).padding.bottom + screenHeight * 0.04;
    // Clamp for extreme small/large screens
    fontSize = fontSize.clamp(18.0, 56.0);
    iconSize = iconSize.clamp(28.0, 100.0);
    boxPadding = boxPadding.clamp(8.0, 32.0);
    boxShadowBlur = boxShadowBlur.clamp(6.0, 32.0);
    boxShadowOffset = boxShadowOffset.clamp(2.0, 16.0);
    titleUnderlineWidth = titleUnderlineWidth.clamp(32.0, 180.0);
    titleUnderlineHeight = titleUnderlineHeight.clamp(2.0, 12.0);
    titleUnderlineBlur = titleUnderlineBlur.clamp(2.0, 12.0);
    verticalSpacing1 = verticalSpacing1.clamp(6.0, 32.0);
    verticalSpacing2 = verticalSpacing2.clamp(4.0, 18.0);
    textPaddingH = textPaddingH.clamp(8.0, 32.0);
    smallTextSize = smallTextSize.clamp(10.0, 18.0);
    progressBarHeight = progressBarHeight.clamp(3.0, 12.0);
    progressBarPaddingH = progressBarPaddingH.clamp(10.0, 64.0);
    progressBarBottom = progressBarBottom.clamp(MediaQuery.of(context).padding.bottom + 8.0, MediaQuery.of(context).padding.bottom + 64.0);
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
                      padding: EdgeInsets.all(boxPadding),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.secondary.withOpacity(0.18),
                            blurRadius: boxShadowBlur,
                            spreadRadius: 2,
                            offset: Offset(0, boxShadowOffset),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.security_rounded,
                        color: theme.colorScheme.secondary,
                        size: iconSize,
                      ),
                    ),
                    SizedBox(height: verticalSpacing1),
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
                                      blurRadius: titleUnderlineBlur,
                                      offset: Offset(0, 2),
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
                                      blurRadius: titleUnderlineBlur,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: -titleUnderlineHeight,
                          child: Container(
                            width: titleUnderlineWidth,
                            height: titleUnderlineHeight,
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
                                  blurRadius: titleUnderlineBlur,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: verticalSpacing2),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: textPaddingH),
                      child: Text(
                        'Ultra Responsive VPN for Secure & Fast Browsing',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: smallTextSize,
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
              bottom: progressBarBottom,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: progressBarPaddingH),
                child: AnimatedBuilder(
                  animation: _barAnimation,
                  builder: (context, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        minHeight: progressBarHeight,
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

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const MyApp(),
    ),
  );
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