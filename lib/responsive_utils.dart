import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Enhanced breakpoints for better small screen support
  static const double tinyScreenBreakpoint = 300; // Only for very tiny screens
  static const double smallMobileBreakpoint = 320; // Very small phones only
  static const double mediumMobileBreakpoint = 375; // Small phones

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static bool isSmallMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= smallMobileBreakpoint;
  }

  static bool isLargeMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= smallMobileBreakpoint && width < 480;
  }

  // New methods for enhanced screen size detection
  static bool isTinyScreen(BuildContext context) {
    return MediaQuery.of(context).size.width <= tinyScreenBreakpoint;
  }

  static bool isVerySmallMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > tinyScreenBreakpoint && width <= smallMobileBreakpoint;
  }

  static bool isMediumMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= smallMobileBreakpoint && width < mediumMobileBreakpoint;
  }

  // Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  // Check if device has very limited vertical space
  static bool hasLimitedHeight(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.height < 600 || (isLandscape(context) && size.height < 500);
  }

  // Enhanced scale factor calculation with orientation support
  static double _getEnhancedScaleFactor(
    double screenWidth,
    double screenHeight,
    bool isLandscape,
  ) {
    // Base scale factor on width
    double widthScale = 1.0;
    if (screenWidth < tinyScreenBreakpoint) {
      widthScale = 0.75; // Very small screens
    } else if (screenWidth < smallMobileBreakpoint) {
      widthScale = 0.80; // Small phones
    } else if (screenWidth < mediumMobileBreakpoint) {
      widthScale = 0.90; // Medium phones
    } else if (screenWidth < 480) {
      widthScale = 0.95; // Regular phones
    } else if (screenWidth < 768) {
      widthScale = 1.0; // Large phones
    } else if (screenWidth < 1024) {
      widthScale = 1.1; // Tablets
    } else {
      widthScale = 1.2; // Desktop/Large tablets
    }

    // Apply height constraints for landscape or short screens
    if (isLandscape && screenHeight < 500) {
      widthScale *= 0.85; // Further reduce for landscape with limited height
    } else if (screenHeight < 600) {
      widthScale *= 0.90; // Reduce for short screens
    }

    return widthScale;
  }

  // Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isSmallMobile(context)) {
      return const EdgeInsets.all(12);
    } else if (isLargeMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  // Get responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    if (isSmallMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 12);
    } else if (isLargeMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32);
    }
  }

  // Get responsive font size based on screen size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final mediaQuery = MediaQuery.of(context);
    final scaleFactor = _getEnhancedScaleFactor(
      mediaQuery.size.width,
      mediaQuery.size.height,
      isLandscape(context),
    );
    return baseSize * scaleFactor;
  }

  // Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    final mediaQuery = MediaQuery.of(context);
    final scaleFactor = _getEnhancedScaleFactor(
      mediaQuery.size.width,
      mediaQuery.size.height,
      isLandscape(context),
    );
    return baseSize * scaleFactor;
  }

  // Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final mediaQuery = MediaQuery.of(context);
    final scaleFactor = _getEnhancedScaleFactor(
      mediaQuery.size.width,
      mediaQuery.size.height,
      isLandscape(context),
    );
    return baseSpacing * scaleFactor;
  }

  // Get responsive border radius
  static double getResponsiveBorderRadius(
    BuildContext context,
    double baseRadius,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final scaleFactor = _getEnhancedScaleFactor(
      mediaQuery.size.width,
      mediaQuery.size.height,
      isLandscape(context),
    );
    return baseRadius * scaleFactor;
  }

  // Get responsive container height with enhanced small screen support
  static double getResponsiveHeight(BuildContext context, double baseHeight) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final isLand = isLandscape(context);

    // More conservative height scaling for small screens and landscape
    double heightFactor;
    if (isTinyScreen(context) || (isLand && screenHeight < 400)) {
      heightFactor = (screenHeight / 800).clamp(
        0.6,
        1.0,
      ); // Extra conservative for tiny screens
    } else if (isVerySmallMobile(context) || (isLand && screenHeight < 500)) {
      heightFactor = (screenHeight / 800).clamp(
        0.7,
        1.1,
      ); // Very conservative for very small screens
    } else if (isSmallMobile(context) || (isLand && screenHeight < 600)) {
      heightFactor = (screenHeight / 800).clamp(
        0.75,
        1.2,
      ); // Conservative for small screens
    } else if (screenWidth < 480) {
      heightFactor = (screenHeight / 800).clamp(
        0.8,
        1.3,
      ); // Conservative for regular phones
    } else {
      heightFactor = (screenHeight / 800).clamp(
        0.8,
        1.5,
      ); // Normal scaling for larger screens
    }

    return baseHeight * heightFactor;
  }

  // Get optimal toast size for any screen
  static double getToastHeight(BuildContext context) {
    if (isTinyScreen(context) || hasLimitedHeight(context)) {
      return 28.0; // Very compact for tiny screens
    } else if (isVerySmallMobile(context)) {
      return 32.0; // Compact for very small screens
    } else if (isSmallMobile(context)) {
      return 36.0; // Standard for small screens
    } else {
      return 40.0; // Normal for larger screens
    }
  }

  // Get optimal animation circle size based on available space
  static double getAnimationCircleSize(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isLand = isLandscape(context);

    // Calculate available space
    final availableHeight = screenHeight -
        MediaQuery.of(context).viewPadding.top -
        MediaQuery.of(context).viewPadding.bottom -
        200; // Reserve space for UI
    final availableWidth = screenWidth - 40; // Side margins

    // Base size calculation
    double baseSize;
    if (isTinyScreen(context)) {
      baseSize = 120.0;
    } else if (isVerySmallMobile(context)) {
      baseSize = 140.0;
    } else if (isSmallMobile(context)) {
      baseSize = 160.0;
    } else if (isMobile(context)) {
      baseSize = 180.0;
    } else {
      baseSize = 200.0;
    }

    // Ensure it fits in available space
    final maxSize = isLand
        ? (availableHeight * 0.6).clamp(80.0, 160.0)
        : (availableHeight * 0.4).clamp(120.0, 220.0);
    final maxWidthSize = availableWidth * 0.6;

    return [baseSize, maxSize, maxWidthSize].reduce((a, b) => a < b ? a : b);
  }

  // Get responsive dialog padding that adapts to screen constraints
  static EdgeInsets getAdaptiveDialogPadding(BuildContext context) {
    if (isTinyScreen(context) || hasLimitedHeight(context)) {
      return const EdgeInsets.all(12.0);
    } else if (isVerySmallMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isSmallMobile(context)) {
      return const EdgeInsets.all(20.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }

  // Get responsive container width
  static double getResponsiveWidth(BuildContext context, double baseWidth) {
    final screenWidth = MediaQuery.of(context).size.width;
    final widthFactor = screenWidth / 400; // Base width of 400
    return baseWidth * widthFactor.clamp(0.8, 2.0);
  }

  // Private helper method to calculate scale factor
  static double _getScaleFactor(double screenWidth) {
    if (screenWidth < 360) {
      return 0.85; // Small phones
    } else if (screenWidth < 480) {
      return 0.95; // Regular phones
    } else if (screenWidth < 768) {
      return 1.0; // Large phones
    } else if (screenWidth < 1024) {
      return 1.1; // Tablets
    } else {
      return 1.2; // Desktop/Large tablets
    }
  }

  // Get responsive grid columns based on screen size
  static int getGridColumns(BuildContext context) {
    if (isSmallMobile(context)) {
      return 2;
    } else if (isLargeMobile(context)) {
      return 3;
    } else if (isTablet(context)) {
      return 4;
    } else {
      return 6;
    }
  }

  // Get responsive maximum width for containers
  static double getMaxContainerWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isDesktop(context)) {
      return screenWidth * 0.8; // 80% of screen width on desktop
    } else if (isTablet(context)) {
      return screenWidth * 0.9; // 90% of screen width on tablet
    } else {
      return screenWidth; // Full width on mobile
    }
  }

  // Get responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    if (isSmallMobile(context)) {
      return kToolbarHeight - 8;
    } else if (isTablet(context)) {
      return kToolbarHeight + 8;
    } else {
      return kToolbarHeight;
    }
  }

  // Get responsive bottom navigation height
  static double getBottomNavHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate a safe bottom nav height based on screen dimensions
    double baseHeight;
    if (screenWidth < 360) {
      baseHeight = 65.0; // Very compact for small screens
    } else if (screenWidth < 480) {
      baseHeight = 70.0; // Compact for regular phones
    } else if (screenWidth < 768) {
      baseHeight = 75.0; // Normal size for large phones
    } else {
      baseHeight = 80.0; // Larger for tablets
    }

    // Ensure the height doesn't exceed a percentage of screen height
    final maxAllowedHeight = screenHeight * 0.12; // Max 12% of screen height
    return baseHeight.clamp(65.0, maxAllowedHeight);
  }

  // Get safe bottom navigation height (alternative method for overflow prevention)
  static double getSafeBottomNavHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final viewPadding = MediaQuery.of(context).viewPadding;

    // Available height after accounting for system UI
    final availableHeight = screenHeight - viewPadding.top - viewPadding.bottom;

    // Conservative height calculation to prevent overflow
    double baseHeight;
    if (screenWidth < 360) {
      baseHeight = 65.0;
    } else if (screenWidth < 480) {
      baseHeight = 70.0;
    } else {
      baseHeight = 75.0;
    }

    // Ensure the height doesn't exceed 10% of available height
    final maxAllowedHeight = availableHeight * 0.1;
    return baseHeight.clamp(60.0, maxAllowedHeight);
  }

  // Get optimal bottom navigation padding
  static EdgeInsets getBottomNavPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) {
      return EdgeInsets.symmetric(vertical: 4, horizontal: 8);
    } else if (screenWidth < 480) {
      return EdgeInsets.symmetric(vertical: 6, horizontal: 12);
    } else {
      return EdgeInsets.symmetric(vertical: 8, horizontal: 16);
    }
  }

  // Get text style based on screen size
  static TextStyle getResponsiveTextStyle(
    BuildContext context, {
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize),
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  // Get responsive button size
  static Size getResponsiveButtonSize(BuildContext context) {
    if (isSmallMobile(context)) {
      return const Size(120, 40);
    } else if (isLargeMobile(context)) {
      return const Size(140, 45);
    } else if (isTablet(context)) {
      return const Size(160, 50);
    } else {
      return const Size(180, 55);
    }
  }

  // Get responsive card elevation
  static double getResponsiveElevation(
    BuildContext context,
    double baseElevation,
  ) {
    final scaleFactor = _getScaleFactor(MediaQuery.of(context).size.width);
    return baseElevation * scaleFactor;
  }

  // Get responsive container constraints for extreme screen sizes
  static BoxConstraints getResponsiveConstraints(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (screenWidth < 320) {
      // Very small screens (older phones)
      return BoxConstraints(
        minWidth: screenWidth * 0.9,
        maxWidth: screenWidth,
        minHeight: 0,
        maxHeight: screenHeight * 0.8,
      );
    } else if (screenWidth < 480) {
      // Small screens (most phones)
      return BoxConstraints(
        minWidth: screenWidth * 0.85,
        maxWidth: screenWidth,
        minHeight: 0,
        maxHeight: screenHeight * 0.85,
      );
    } else if (screenWidth < 768) {
      // Large phones/small tablets
      return BoxConstraints(
        minWidth: screenWidth * 0.8,
        maxWidth: screenWidth * 0.95,
        minHeight: 0,
        maxHeight: screenHeight * 0.9,
      );
    } else {
      // Tablets and larger screens
      return BoxConstraints(
        minWidth: 320,
        maxWidth: screenWidth * 0.8,
        minHeight: 0,
        maxHeight: screenHeight * 0.9,
      );
    }
  }

  // Get safe area padding that adapts to different screen sizes
  static EdgeInsets getAdaptiveSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final viewPadding = mediaQuery.viewPadding;

    // Scale padding based on screen size
    double horizontalScale = 1.0;
    double verticalScale = 1.0;

    if (screenWidth < 360) {
      horizontalScale = 0.8;
      verticalScale = 0.9;
    } else if (screenWidth > 768) {
      horizontalScale = 1.2;
      verticalScale = 1.1;
    }

    return EdgeInsets.only(
      top: (viewPadding.top * verticalScale).clamp(0, 60),
      bottom: (viewPadding.bottom * verticalScale).clamp(0, 40),
      left: (viewPadding.left * horizontalScale).clamp(0, 40),
      right: (viewPadding.right * horizontalScale).clamp(0, 40),
    );
  }

  // Get responsive font size with minimum and maximum limits
  static double getSafeFontSize(
    BuildContext context,
    double baseSize, {
    double? minSize,
    double? maxSize,
  }) {
    final responsiveSize = getResponsiveFontSize(context, baseSize);
    final min = minSize ?? baseSize * 0.7;
    final max = maxSize ?? baseSize * 1.5;
    return responsiveSize.clamp(min, max);
  }

  // Get optimal layout columns based on content and screen size
  static int getOptimalColumns(
    BuildContext context, {
    int minColumns = 1,
    int maxColumns = 4,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) {
      return minColumns;
    } else if (screenWidth < 480) {
      return (minColumns + 1).clamp(minColumns, maxColumns);
    } else if (screenWidth < 768) {
      return (minColumns + 2).clamp(minColumns, maxColumns);
    } else if (screenWidth < 1024) {
      return (maxColumns - 1).clamp(minColumns, maxColumns);
    } else {
      return maxColumns;
    }
  }

  // Get responsive dialog size
  static Size getDialogSize(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    if (screenWidth < 480) {
      // Mobile phones - use most of the screen
      return Size(
        screenWidth * 0.9,
        (screenHeight * 0.6).clamp(300, screenHeight * 0.8),
      );
    } else if (screenWidth < 768) {
      // Large phones/small tablets
      return Size(
        (screenWidth * 0.8).clamp(400, 600),
        (screenHeight * 0.5).clamp(350, screenHeight * 0.7),
      );
    } else {
      // Tablets and desktops
      return Size(
        (screenWidth * 0.6).clamp(500, 800),
        (screenHeight * 0.6).clamp(400, screenHeight * 0.8),
      );
    }
  }
}

// Extension to make ResponsiveUtils easier to use
extension ResponsiveContext on BuildContext {
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  bool get isSmallMobile => ResponsiveUtils.isSmallMobile(this);
  bool get isLargeMobile => ResponsiveUtils.isLargeMobile(this);
  bool get isTinyScreen => ResponsiveUtils.isTinyScreen(this);
  bool get isVerySmallMobile => ResponsiveUtils.isVerySmallMobile(this);
  bool get isMediumMobile => ResponsiveUtils.isMediumMobile(this);
  bool get isLandscape => ResponsiveUtils.isLandscape(this);
  bool get hasLimitedHeight => ResponsiveUtils.hasLimitedHeight(this);

  EdgeInsets get defaultResponsivePadding =>
      ResponsiveUtils.getResponsivePadding(this);
  EdgeInsets get responsiveHorizontalPadding =>
      ResponsiveUtils.getResponsiveHorizontalPadding(this);

  double responsiveFontSize(double baseSize) =>
      ResponsiveUtils.getResponsiveFontSize(this, baseSize);
  double responsiveIconSize(double baseSize) =>
      ResponsiveUtils.getResponsiveIconSize(this, baseSize);
  double responsiveSpacing(double baseSpacing) =>
      ResponsiveUtils.getResponsiveSpacing(this, baseSpacing);
  double responsiveBorderRadius(double baseRadius) =>
      ResponsiveUtils.getResponsiveBorderRadius(this, baseRadius);
  double responsiveHeight(double baseHeight) =>
      ResponsiveUtils.getResponsiveHeight(this, baseHeight);
  double responsiveWidth(double baseWidth) =>
      ResponsiveUtils.getResponsiveWidth(this, baseWidth);

  // Enhanced responsive utilities for toasts and animations
  double get toastHeight => ResponsiveUtils.getToastHeight(this);
  double get animationCircleSize =>
      ResponsiveUtils.getAnimationCircleSize(this);
  EdgeInsets get adaptiveDialogPadding =>
      ResponsiveUtils.getAdaptiveDialogPadding(this);

  // Alternative method names for consistency
  double getResponsiveFontSize(double baseSize) =>
      ResponsiveUtils.getResponsiveFontSize(this, baseSize);
  double getResponsiveIconSize(double baseSize) =>
      ResponsiveUtils.getResponsiveIconSize(this, baseSize);
  double getResponsiveSpacing(double baseSpacing) =>
      ResponsiveUtils.getResponsiveSpacing(this, baseSpacing);
  double getResponsiveBorderRadius(double baseRadius) =>
      ResponsiveUtils.getResponsiveBorderRadius(this, baseRadius);
  double getResponsiveBorderWidth(double baseWidth) =>
      ResponsiveUtils.getResponsiveSpacing(
        this,
        baseWidth,
      ); // Use spacing for border width

  // Custom responsive padding method
  EdgeInsets responsivePadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    if (all != null) {
      return EdgeInsets.all(getResponsiveSpacing(all));
    }
    return EdgeInsets.only(
      left: left != null
          ? getResponsiveSpacing(left)
          : (horizontal != null ? getResponsiveSpacing(horizontal) : 0),
      right: right != null
          ? getResponsiveSpacing(right)
          : (horizontal != null ? getResponsiveSpacing(horizontal) : 0),
      top: top != null
          ? getResponsiveSpacing(top)
          : (vertical != null ? getResponsiveSpacing(vertical) : 0),
      bottom: bottom != null
          ? getResponsiveSpacing(bottom)
          : (vertical != null ? getResponsiveSpacing(vertical) : 0),
    );
  }

  int get gridColumns => ResponsiveUtils.getGridColumns(this);
  double get maxContainerWidth => ResponsiveUtils.getMaxContainerWidth(this);
  double get appBarHeight => ResponsiveUtils.getAppBarHeight(this);
  double get bottomNavHeight => ResponsiveUtils.getBottomNavHeight(this);
  double get safeBottomNavHeight =>
      ResponsiveUtils.getSafeBottomNavHeight(this);
  EdgeInsets get bottomNavPadding => ResponsiveUtils.getBottomNavPadding(this);
  Size get responsiveButtonSize =>
      ResponsiveUtils.getResponsiveButtonSize(this);

  TextStyle responsiveTextStyle({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) =>
      ResponsiveUtils.getResponsiveTextStyle(
        this,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );

  // Advanced responsive utilities
  BoxConstraints get responsiveConstraints =>
      ResponsiveUtils.getResponsiveConstraints(this);
  EdgeInsets get adaptiveSafeAreaPadding =>
      ResponsiveUtils.getAdaptiveSafeAreaPadding(this);
  double safeFontSize(double baseSize, {double? minSize, double? maxSize}) =>
      ResponsiveUtils.getSafeFontSize(
        this,
        baseSize,
        minSize: minSize,
        maxSize: maxSize,
      );
  int optimalColumns({int minColumns = 1, int maxColumns = 4}) =>
      ResponsiveUtils.getOptimalColumns(
        this,
        minColumns: minColumns,
        maxColumns: maxColumns,
      );
  Size get dialogSize => ResponsiveUtils.getDialogSize(this);
}
