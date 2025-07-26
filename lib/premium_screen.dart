import 'package:flutter/material.dart';
import 'responsive_utils.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  int selectedPlan = 1; // 0 = Monthly, 1 = Yearly, 2 = Lifetime

  // App theme colors
  static const Color primaryPurple = Color(0xFF8A2BE2);
  static const Color lightPurple = Color(0xFFB19CD9);
  static const Color accentTeal = Color(0xFF20E5C7);
  static const Color connectGreen = Color(0xFF00D4AA);
  static const Color warmGold = Color(0xFFFFD700);
  static const Color softGold = Color(0xFFFFF8DC);
  static const Color darkBg = Color(0xFF1A1A2E);
  static const Color cardBg = Color(0xFF16213E);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen information for better responsive handling
    final isSmallScreen = context.isTinyScreen || context.isVerySmallMobile;
    final hasLimitedSpace = context.hasLimitedHeight;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [darkBg, cardBg, darkBg.withOpacity(0.9)],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height -
                              MediaQuery.of(context).viewPadding.top -
                              MediaQuery.of(context).viewPadding.bottom,
                        ),
                        child: Column(
                          children: [
                            // Custom App Bar with adaptive height
                            _buildCustomAppBar(context),

                            // Header Section with adaptive sizing
                            _buildEnhancedHeader(context),

                            // Plans Section with improved spacing
                            _buildEnhancedPlansSection(context),

                            // Features Section with compact mode for small screens
                            _buildEnhancedFeaturesSection(context),

                            // Footer with adaptive sizing
                            _buildFooterNote(context),

                            // Bottom Spacing - adaptive
                            SizedBox(
                              height: isSmallScreen || hasLimitedSpace
                                  ? context.getResponsiveSpacing(12)
                                  : context.getResponsiveSpacing(20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.getResponsiveSpacing(20),
        vertical: context.getResponsiveSpacing(10),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: cardBg.withOpacity(0.8),
              borderRadius: BorderRadius.circular(
                context.getResponsiveBorderRadius(12),
              ),
              border: Border.all(color: accentTeal.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: accentTeal,
                size: context.getResponsiveIconSize(20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            child: Text(
              "Premium Upgrade",
              style: TextStyle(
                fontSize: context.getResponsiveFontSize(25),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: context.getResponsiveSpacing(48),
          ), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildEnhancedHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final iconSize = (screenWidth * 0.15).clamp(40.0, 80.0);
    final titleFontSize = (screenWidth * 0.07).clamp(20.0, 32.0);
    final subtitleFontSize = (screenWidth * 0.045).clamp(14.0, 22.0);
    final verticalSpacing = (screenHeight * 0.015).clamp(8.0, 24.0);
    final headerMargin = (screenWidth * 0.05).clamp(10.0, 32.0);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: headerMargin,
        vertical: verticalSpacing,
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [warmGold, softGold, accentTeal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(iconSize * 0.3),
                    boxShadow: [
                      BoxShadow(
                        color: warmGold.withOpacity(0.4),
                        blurRadius: iconSize * 0.18,
                        spreadRadius: iconSize * 0.03,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.diamond,
                    color: darkBg,
                    size: iconSize * 0.5,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: verticalSpacing),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [warmGold, accentTeal, connectGreen],
            ).createShader(bounds),
            child: Text(
              "Unlock VPN Max Pro",
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: verticalSpacing * 0.7),
          Text(
            screenWidth < 400
                ? "Ultimate privacy and speed"
                : "Experience ultimate privacy and speed\nwith our premium VPN service",
            style: TextStyle(
              fontSize: subtitleFontSize,
              color: Colors.white.withOpacity(0.9),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: screenWidth < 400 ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPlansSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = context.isTinyScreen || context.isVerySmallMobile;
    final hasLimitedSpace = context.hasLimitedHeight;

    // Adaptive spacing and sizing
    final sectionMargin = (screenWidth * 0.06).clamp(14.0, 28.0);
    final titleFontSize = (screenWidth * 0.06).clamp(20.0, 28.0); // Bigger and flexible
    final subtitleFontSize = (screenWidth * 0.04).clamp(14.0, 20.0); // Bigger and flexible
    final verticalSpacing = (screenWidth * 0.04).clamp(12.0, 24.0);
    final elementSpacing = (screenWidth * 0.02).clamp(6.0, 12.0);
    final planSpacing = (screenWidth * 0.03).clamp(10.0, 18.0);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.getResponsiveSpacing(sectionMargin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: context.getResponsiveSpacing(verticalSpacing)),
          Text(
            "Choose Your Plan",
            style: TextStyle(
              fontSize: context.getResponsiveFontSize(titleFontSize),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: context.getResponsiveSpacing(elementSpacing)),
          Text(
            isSmallScreen
                ? "Unlock premium features"
                : "Unlock all premium features with any plan",
            style: TextStyle(
              fontSize: context.getResponsiveFontSize(subtitleFontSize),
              color: Colors.white60,
            ),
          ),
          SizedBox(height: context.getResponsiveSpacing(planSpacing)),

          // Plans Column with adaptive spacing
          _buildPlansColumn(context),
        ],
      ),
    );
  }

  Widget _buildPlansColumn(BuildContext context) {
    final isSmallScreen = context.isTinyScreen || context.isVerySmallMobile;
    final hasLimitedSpace = context.hasLimitedHeight;
    final cardSpacing = isSmallScreen ? 4.0 : (hasLimitedSpace ? 5.0 : 6.0);

    return Column(
      children: [
        _buildEnhancedPlanCard(
          context: context,
          index: 0,
          title: "Monthly Plan",
          subtitle: isSmallScreen ? "Try it out" : "Perfect for trying out",
          price: "Rs 300",
          period: "/month",
          originalPrice: "",
          color: primaryPurple,
          isPopular: false,
        ),
        SizedBox(height: context.getResponsiveSpacing(cardSpacing)),
        _buildEnhancedPlanCard(
          context: context,
          index: 1,
          title: "Yearly Plan",
          subtitle: isSmallScreen ? "Best value" : "Best value for money",
          price: "Rs 3,200",
          period: "/year",
          originalPrice: "",
          color: accentTeal,
          isPopular: true,
        ),
        SizedBox(height: context.getResponsiveSpacing(cardSpacing)),
        _buildEnhancedPlanCard(
          context: context,
          index: 2,
          title: "Lifetime Access",
          subtitle: "One Time Payment",
          price: "Rs 10,500",
          period: "",
          originalPrice: "",
          color: connectGreen,
          isPopular: false,
          isLifetime: true,
        ),
      ],
    );
  }

  Widget _buildEnhancedPlanCard({
    required BuildContext context,
    required int index,
    required String title,
    required String subtitle,
    required String price,
    required String period,
    required String originalPrice,
    required Color color,
    required bool isPopular,
    bool isLifetime = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSelected = selectedPlan == index;
    final isSmallScreen = context.isTinyScreen || context.isVerySmallMobile;
    final hasLimitedSpace = context.hasLimitedHeight;

    // Adaptive sizing for plan cards (bigger and flexible)
    final cardPadding = (screenWidth * 0.045).clamp(14.0, 24.0);
    final borderRadius = (screenWidth * 0.04).clamp(12.0, 20.0);
    final badgeFontSize = (screenWidth * 0.03).clamp(12.0, 16.0);
    final titleFontSize = (screenWidth * 0.05).clamp(18.0, 26.0);
    final subtitleFontSize = (screenWidth * 0.035).clamp(14.0, 20.0);
    final priceFontSize = (screenWidth * 0.055).clamp(20.0, 30.0);
    final periodFontSize = (screenWidth * 0.035).clamp(14.0, 20.0);
    final buttonHeight = (screenWidth * 0.09).clamp(32.0, 48.0);
    final buttonFontSize = (screenWidth * 0.04).clamp(14.0, 20.0);
    final elementSpacing = (screenWidth * 0.03).clamp(10.0, 18.0);

    return GestureDetector(
      onTap: () => setState(() => selectedPlan = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    primaryPurple.withOpacity(0.9),
                    primaryPurple.withOpacity(0.7),
                    primaryPurple.withOpacity(0.5),
                  ]
                : [cardBg.withOpacity(0.8), cardBg.withOpacity(0.6)],
          ),
          borderRadius: BorderRadius.circular(
            context.getResponsiveBorderRadius(borderRadius),
          ),
          border: Border.all(
            color: isSelected ? Colors.white : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected ? primaryPurple.withOpacity(0.3) : Colors.black26,
              blurRadius: isSelected
                  ? (isSmallScreen ? 10 : 15)
                  : (isSmallScreen ? 5 : 8),
              spreadRadius: isSelected
                  ? (isSmallScreen ? 1 : 2)
                  : (isSmallScreen ? 0 : 1),
              offset: Offset(0, isSmallScreen ? 2 : 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(context.getResponsiveSpacing(cardPadding)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with badges - adaptive sizing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isPopular)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.getResponsiveSpacing(
                        isSmallScreen ? 8 : 10,
                      ),
                      vertical: context.getResponsiveSpacing(
                        isSmallScreen ? 3 : 4,
                      ),
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [warmGold, softGold],
                      ),
                      borderRadius: BorderRadius.circular(
                        context.getResponsiveBorderRadius(
                          isSmallScreen ? 10 : 12,
                        ),
                      ),
                    ),
                    child: Text(
                      isSmallScreen ? "POPULAR" : "MOST POPULAR",
                      style: TextStyle(
                        fontSize: context.getResponsiveFontSize(badgeFontSize),
                        fontWeight: FontWeight.bold,
                        color: darkBg,
                      ),
                    ),
                  )
                else if (isLifetime)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.getResponsiveSpacing(
                        isSmallScreen ? 6 : 8,
                      ),
                      vertical: context.getResponsiveSpacing(
                        isSmallScreen ? 3 : 4,
                      ),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [connectGreen, accentTeal],
                      ),
                      borderRadius: BorderRadius.circular(
                        context.getResponsiveBorderRadius(
                          isSmallScreen ? 10 : 12,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.diamond,
                          color: Colors.white,
                          size: context.getResponsiveIconSize(
                            isSmallScreen ? 10 : 12,
                          ),
                        ),
                        SizedBox(
                          width: context.getResponsiveSpacing(
                            isSmallScreen ? 3 : 4,
                          ),
                        ),
                        Text(
                          "LIFETIME",
                          style: TextStyle(
                            fontSize: context.getResponsiveFontSize(
                              badgeFontSize,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
            SizedBox(height: context.getResponsiveSpacing(elementSpacing)),

            // Plan Title - adaptive font
            Text(
              title,
              style: TextStyle(
                fontSize: context.getResponsiveFontSize(titleFontSize),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: context.getResponsiveSpacing(2)),

            // Plan Subtitle - adaptive font
            Text(
              subtitle,
              style: TextStyle(
                fontSize: context.getResponsiveFontSize(subtitleFontSize),
                color: Colors.white70,
              ),
            ),
            SizedBox(
              height: context.getResponsiveSpacing(isSmallScreen ? 8 : 10),
            ),

            // Price Section - adaptive layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: context.getResponsiveFontSize(priceFontSize),
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : accentTeal,
                  ),
                ),
                if (period.isNotEmpty)
                  Text(
                    period,
                    style: TextStyle(
                      fontSize: context.getResponsiveFontSize(periodFontSize),
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
            SizedBox(
              height: context.getResponsiveSpacing(isSmallScreen ? 8 : 10),
            ),

            // Select Button - adaptive sizing
            Container(
              width: double.infinity,
              height: context.getResponsiveSpacing(buttonHeight),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(colors: [warmGold, softGold])
                    : LinearGradient(
                        colors: [
                          primaryPurple,
                          primaryPurple.withOpacity(0.8),
                        ],
                      ),
                borderRadius: BorderRadius.circular(
                  context.getResponsiveBorderRadius(isSmallScreen ? 8 : 10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isSelected ? warmGold : primaryPurple).withOpacity(
                      0.3,
                    ),
                    blurRadius: isSmallScreen ? 3 : 5,
                    offset: Offset(0, isSmallScreen ? 1 : 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    context.getResponsiveBorderRadius(isSmallScreen ? 8 : 10),
                  ),
                  onTap: () => _handlePurchase(index),
                  child: Center(
                    child: Text(
                      "BUY NOW",
                      style: TextStyle(
                        fontSize: context.getResponsiveFontSize(buttonFontSize),
                        fontWeight: FontWeight.bold,
                        color: isSelected ? darkBg : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedFeaturesSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = context.isTinyScreen || context.isVerySmallMobile;
    final hasLimitedSpace = context.hasLimitedHeight;

    // Adaptive sizing (bigger and flexible)
    final sectionMargin = (screenWidth * 0.05).clamp(14.0, 24.0);
    final sectionPadding = (screenWidth * 0.06).clamp(16.0, 28.0);
    final borderRadius = (screenWidth * 0.045).clamp(14.0, 22.0);
    final headerIconSize = (screenWidth * 0.06).clamp(18.0, 28.0);
    final headerIconPadding = (screenWidth * 0.03).clamp(10.0, 16.0);
    final headerIconRadius = (screenWidth * 0.03).clamp(10.0, 16.0);
    final headerSpacing = (screenWidth * 0.03).clamp(10.0, 16.0);
    final titleFontSize = (screenWidth * 0.055).clamp(20.0, 28.0);
    final subtitleFontSize = (screenWidth * 0.04).clamp(14.0, 20.0);
    final featuresSpacing = (screenWidth * 0.04).clamp(14.0, 20.0);
    final featureMargin = (screenWidth * 0.03).clamp(10.0, 16.0);
    final featureEmojiSize = (screenWidth * 0.055).clamp(20.0, 28.0);
    final featureTitleSize = (screenWidth * 0.045).clamp(16.0, 22.0);
    final featureSubtitleSize = (screenWidth * 0.035).clamp(12.0, 18.0);

    final features = [
      {
        "icon": "🚀",
        "title": "Unlimited Speed",
        "subtitle": isSmallScreen ? "No limits" : "No bandwidth limitations",
      },
      {
        "icon": "🌍",
        "title": "Global Servers",
        "subtitle": isSmallScreen ? "Worldwide" : "worldwide locations",
      },
      {
        "icon": "📱",
        "title": "Multi-Device",
        "subtitle": isSmallScreen ? "Up to 10" : "Connect up to 10 devices",
      },
      {
        "icon": "🛡️",
        "title": "Add Blocker",
        "subtitle": isSmallScreen ? "Block ads" : "Block ads and malware",
      },
      {
        "icon": "🔄",
        "title": "No Logs Policy",
        "subtitle":
            isSmallScreen ? "Complete privacy" : "Complete privacy guaranteed",
      },
    ];

    return Container(
      margin: EdgeInsets.all(context.getResponsiveSpacing(sectionMargin)),
      padding: EdgeInsets.all(context.getResponsiveSpacing(sectionPadding)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardBg.withOpacity(0.8), darkBg.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          context.getResponsiveBorderRadius(borderRadius),
        ),
        border: Border.all(color: lightPurple.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.15),
            blurRadius: isSmallScreen ? 10 : 15,
            spreadRadius: isSmallScreen ? 1 : 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  context.getResponsiveSpacing(headerIconPadding),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [accentTeal, connectGreen]),
                  borderRadius: BorderRadius.circular(
                    context.getResponsiveBorderRadius(headerIconRadius),
                  ),
                ),
                child: Icon(
                  Icons.star,
                  color: Colors.white,
                  size: context.getResponsiveIconSize(headerIconSize),
                ),
              ),
              SizedBox(width: context.getResponsiveSpacing(headerSpacing)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Premium Features",
                      style: TextStyle(
                        fontSize: context.getResponsiveFontSize(titleFontSize),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      isSmallScreen
                          ? "Secure browsing essentials"
                          : "Everything you need for secure browsing",
                      style: TextStyle(
                        fontSize: context.getResponsiveFontSize(
                          subtitleFontSize,
                        ),
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.getResponsiveSpacing(featuresSpacing)),

          // Features List - simple text points style
          ...features.map(
            (feature) => Padding(
              padding: EdgeInsets.only(
                bottom: context.getResponsiveSpacing(featureMargin),
                left: context.getResponsiveSpacing(4.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Feature emoji
                  Text(
                    feature["icon"]!,
                    style: TextStyle(
                      fontSize: context.getResponsiveFontSize(featureEmojiSize),
                    ),
                  ),
                  SizedBox(width: context.getResponsiveSpacing(6.0)),
                  // Bullet point - closer to icon and lower
                  Container(
                    margin: EdgeInsets.only(
                      top: context.getResponsiveSpacing(6.0),
                      right: context.getResponsiveSpacing(8.0),
                    ),
                    width: context.getResponsiveSpacing(6.0),
                    height: context.getResponsiveSpacing(6.0),
                    decoration: BoxDecoration(
                      color: accentTeal,
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                  // Feature text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature["title"]!,
                          style: TextStyle(
                            fontSize: context.getResponsiveFontSize(
                              featureTitleSize,
                            ),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (!isSmallScreen || hasLimitedSpace) ...[
                          SizedBox(height: context.getResponsiveSpacing(2)),
                          Text(
                            feature["subtitle"]!,
                            style: TextStyle(
                              fontSize: context.getResponsiveFontSize(
                                featureSubtitleSize,
                              ),
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterNote(BuildContext context) {
    final isSmallScreen = context.isTinyScreen || context.isVerySmallMobile;
    final hasLimitedSpace = context.hasLimitedHeight;

    // Adaptive sizing
    final footerMargin = isSmallScreen ? 12.0 : 20.0;
    final footerPadding = isSmallScreen ? 10.0 : 15.0;
    final borderRadius = isSmallScreen ? 12.0 : 15.0;
    final iconSize = isSmallScreen ? 12.0 : 14.0;
    final iconSpacing = isSmallScreen ? 4.0 : 6.0;
    final titleFontSize = isSmallScreen ? 10.0 : 12.0;
    final textFontSize = isSmallScreen ? 8.0 : 10.0;
    final verticalSpacing = isSmallScreen ? 6.0 : 8.0;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.getResponsiveSpacing(footerMargin),
        vertical: context.getResponsiveSpacing(hasLimitedSpace ? 5 : 10),
      ),
      padding: EdgeInsets.all(context.getResponsiveSpacing(footerPadding)),
      decoration: BoxDecoration(
        color: darkBg.withOpacity(0.6),
        borderRadius: BorderRadius.circular(
          context.getResponsiveBorderRadius(borderRadius),
        ),
        border: Border.all(color: lightPurple.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: isSmallScreen ? 5 : 8,
            spreadRadius: isSmallScreen ? 0 : 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                color: accentTeal,
                size: context.getResponsiveIconSize(iconSize),
              ),
              SizedBox(width: context.getResponsiveSpacing(iconSpacing)),
              Text(
                "Important Information",
                style: TextStyle(
                  fontSize: context.getResponsiveFontSize(titleFontSize),
                  fontWeight: FontWeight.bold,
                  color: accentTeal,
                ),
              ),
            ],
          ),
          SizedBox(height: context.getResponsiveSpacing(verticalSpacing)),
          Text(
            isSmallScreen
                ? "• Auto-renew until cancelled\n• Manage in account settings"
                : "• Subscriptions auto-renew until cancelled\n• Manage subscriptions in account settings",
            style: TextStyle(
              fontSize: context.getResponsiveFontSize(textFontSize),
              color: Colors.white.withOpacity(0.7),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handlePurchase(int planIndex) {
    final planNames = ["Monthly Plan", "Yearly Plan", "Lifetime Access"];
    final planPrices = ["Rs 300/month", "Rs 3,200/year", "Rs 10,500 one-time"];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final isSmallScreen =
            dialogContext.isTinyScreen || dialogContext.isVerySmallMobile;
        final hasLimitedSpace = dialogContext.hasLimitedHeight;

        // Adaptive sizing for dialog
        final dialogPadding = isSmallScreen ? 16.0 : 25.0;
        final borderRadius = isSmallScreen ? 20.0 : 25.0;
        final iconSize = isSmallScreen ? 45.0 : 60.0;
        final iconInnerSize = isSmallScreen ? 22.0 : 30.0;
        final titleFontSize = isSmallScreen ? 18.0 : 22.0;
        final planTitleSize = isSmallScreen ? 16.0 : 18.0;
        final planPriceSize = isSmallScreen ? 14.0 : 16.0;
        final descriptionSize = isSmallScreen ? 12.0 : 14.0;
        final buttonHeight = isSmallScreen ? 40.0 : 45.0;
        final buttonFontSize = isSmallScreen ? 12.0 : 14.0;
        final verticalSpacing = isSmallScreen ? 15.0 : 20.0;
        final smallSpacing = isSmallScreen ? 6.0 : 8.0;
        final mediumSpacing = isSmallScreen ? 8.0 : 12.0;
        final buttonSpacing = isSmallScreen ? 12.0 : 16.0;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isSmallScreen
                  ? MediaQuery.of(dialogContext).size.width * 0.95
                  : MediaQuery.of(dialogContext).size.width * 0.85,
              maxHeight: hasLimitedSpace
                  ? MediaQuery.of(dialogContext).size.height * 0.85
                  : MediaQuery.of(dialogContext).size.height * 0.9,
            ),
            padding: EdgeInsets.all(
              dialogContext.getResponsiveSpacing(dialogPadding),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cardBg, darkBg],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(
                dialogContext.getResponsiveBorderRadius(borderRadius),
              ),
              border: Border.all(color: accentTeal.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: primaryPurple.withOpacity(0.3),
                  blurRadius: isSmallScreen ? 15 : 20,
                  spreadRadius: isSmallScreen ? 3 : 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon - adaptive size
                Container(
                  width: dialogContext.getResponsiveIconSize(iconSize),
                  height: dialogContext.getResponsiveIconSize(iconSize),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [connectGreen, accentTeal],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: dialogContext.getResponsiveIconSize(iconInnerSize),
                  ),
                ),
                SizedBox(
                  height: dialogContext.getResponsiveSpacing(verticalSpacing),
                ),

                // Title - adaptive font
                Text(
                  "Confirm Purchase",
                  style: TextStyle(
                    fontSize: dialogContext.getResponsiveFontSize(
                      titleFontSize,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: dialogContext.getResponsiveSpacing(mediumSpacing),
                ),

                // Plan Details - adaptive container
                Container(
                  padding: EdgeInsets.all(
                    dialogContext.getResponsiveSpacing(
                      isSmallScreen ? 12.0 : 16.0,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: darkBg.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(
                      dialogContext.getResponsiveBorderRadius(
                        isSmallScreen ? 12.0 : 15.0,
                      ),
                    ),
                    border: Border.all(color: accentTeal.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        planNames[planIndex],
                        style: TextStyle(
                          fontSize: dialogContext.getResponsiveFontSize(
                            planTitleSize,
                          ),
                          fontWeight: FontWeight.bold,
                          color: accentTeal,
                        ),
                      ),
                      SizedBox(
                        height: dialogContext.getResponsiveSpacing(
                          smallSpacing,
                        ),
                      ),
                      Text(
                        planPrices[planIndex],
                        style: TextStyle(
                          fontSize: dialogContext.getResponsiveFontSize(
                            planPriceSize,
                          ),
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: dialogContext.getResponsiveSpacing(verticalSpacing),
                ),

                Text(
                  isSmallScreen
                      ? "Demo: Payment gateway preview"
                      : "This would redirect to payment gateway in a real app. For demo purposes, this is just a preview.",
                  style: TextStyle(
                    fontSize: dialogContext.getResponsiveFontSize(
                      descriptionSize,
                    ),
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: dialogContext.getResponsiveSpacing(
                    hasLimitedSpace ? 15.0 : 25.0,
                  ),
                ),

                // Action Buttons - adaptive layout
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: dialogContext.getResponsiveSpacing(
                          buttonHeight,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            dialogContext.getResponsiveBorderRadius(12),
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              dialogContext.getResponsiveBorderRadius(12),
                            ),
                            onTap: () => Navigator.pop(dialogContext),
                            child: Center(
                              child: Text(
                                "CANCEL",
                                style: TextStyle(
                                  fontSize: dialogContext.getResponsiveFontSize(
                                    buttonFontSize,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: dialogContext.getResponsiveSpacing(buttonSpacing),
                    ),
                    Expanded(
                      child: Container(
                        height: dialogContext.getResponsiveSpacing(
                          buttonHeight,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accentTeal, connectGreen],
                          ),
                          borderRadius: BorderRadius.circular(
                            dialogContext.getResponsiveBorderRadius(12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentTeal.withOpacity(0.4),
                              blurRadius: isSmallScreen ? 5 : 8,
                              offset: Offset(0, isSmallScreen ? 1 : 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              dialogContext.getResponsiveBorderRadius(12),
                            ),
                            onTap: () {
                              Navigator.pop(dialogContext);
                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Demo: ${planNames[planIndex]} selected!",
                                  ),
                                  backgroundColor: connectGreen,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Center(
                              child: Text(
                                "PROCEED",
                                style: TextStyle(
                                  fontSize: dialogContext.getResponsiveFontSize(
                                    buttonFontSize,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}