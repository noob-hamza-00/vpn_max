import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'app_filter_screen.dart';
import 'premium_screen.dart';
import 'responsive_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// --- MAIN PAGE ---
class AnimationPage extends StatefulWidget {
  const AnimationPage({super.key});

  @override
  State<AnimationPage> createState() => _AnimationPageState();
}

class _AnimationPageState extends State<AnimationPage>
    with SingleTickerProviderStateMixin {
  bool connected = false;
  bool connecting = false;
  double connectingProgress = 0.0;
  // Removed all floating toast logic, using only native mobile toast (Fluttertoast)
  late AnimationController _controller;
  int selectedTab = 0; // 0 = VPN, 1 = More

  StreamSubscription<ConnectivityResult>? _networkSub;
  bool networkAvailable = true;

  final List<Map<String, String>> servers = [
    {'country': 'United States', 'flag': '🇺🇸'},
    {'country': 'Germany', 'flag': '🇩🇪'},
    {'country': 'United Kingdom', 'flag': '🇬🇧'},
    {'country': 'France', 'flag': '🇫🇷'},
    {'country': 'Japan', 'flag': '🇯🇵'},
    {'country': 'India', 'flag': '🇮🇳'},
    {'country': 'Canada', 'flag': '🇨🇦'},
  ];

  int selectedServer = 0;

  // Modern Color Palette - Smooth and Attractive
  static const Color primaryPurple = Color(0xFF8A2BE2);
  static const Color lightPurple = Color(0xFFB19CD9);
  static const Color accentTeal = Color(0xFF20E5C7);
  static const Color softTeal = Color(0xFF7FFFD4);
  static const Color connectGreen = Color(0xFF00D4AA);
  static const Color warmGold = Color(0xFFFFD700);
  static const Color softGold = Color(0xFFFFF8DC);
  static const Color darkBg = Color(0xFF1A1A2E);
  static const Color cardBg = Color(0xFF16213E);
  static const Color connectedBg = Color(0xFF0F3460);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Listen for real network changes
    _networkSub = Connectivity().onConnectivityChanged.listen((result) {
      final hasNetwork = result != ConnectivityResult.none;
      if (!hasNetwork && connected) {
        _showNetworkErrorDialog();
      }
      setState(() {
        networkAvailable = hasNetwork;
      });
    });
    // Initial check
    Connectivity().checkConnectivity().then((result) {
      setState(() {
        networkAvailable = result != ConnectivityResult.none;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _networkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Proportional sizes for any device
    double navHeight = screenHeight * 0.08;
    double navIconSize = screenWidth * 0.07;
    double navFontSize = screenWidth * 0.035;
    double navPaddingH = screenWidth * 0.04;
    double navPaddingV = screenHeight * 0.01;
    navHeight = navHeight.clamp(40.0, 80.0);
    navIconSize = navIconSize.clamp(18.0, 32.0);
    navFontSize = navFontSize.clamp(10.0, 16.0);
    navPaddingH = navPaddingH.clamp(8.0, 32.0);
    navPaddingV = navPaddingV.clamp(4.0, 18.0);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: selectedTab == 0 ? _buildVpnScreen(context) : const MoreScreen(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(screenWidth * 0.05)),
          border: Border.all(
            color: (connected ? accentTeal : primaryPurple).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (connected ? accentTeal : primaryPurple).withOpacity(0.2),
              blurRadius: screenWidth * 0.04,
              spreadRadius: screenWidth * 0.01,
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: navHeight,
            padding: EdgeInsets.symmetric(
                horizontal: navPaddingH,
                vertical: navPaddingV),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    onTap: () => setState(() => selectedTab = 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.vpn_key,
                          color: selectedTab == 0 ? (connected ? accentTeal : primaryPurple) : Colors.white60,
                          size: navIconSize,
                        ),
                        Text(
                          "VPN",
                          style: TextStyle(
                            color: selectedTab == 0 ? (connected ? accentTeal : primaryPurple) : Colors.white60,
                            fontWeight: selectedTab == 0 ? FontWeight.w700 : FontWeight.w500,
                            fontSize: navFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    onTap: () => setState(() => selectedTab = 1),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.more_horiz,
                          color: selectedTab == 1 ? (connected ? accentTeal : primaryPurple) : Colors.white60,
                          size: navIconSize,
                        ),
                        Text(
                          "More",
                          style: TextStyle(
                            color: selectedTab == 1 ? (connected ? accentTeal : primaryPurple) : Colors.white60,
                            fontWeight: selectedTab == 1 ? FontWeight.w700 : FontWeight.w500,
                            fontSize: navFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void toggleConnection() async {
    if (!connected && !connecting) {
      if (!networkAvailable) {
        _showNetworkErrorDialog();
        return;
      }
      setState(() {
        connecting = true;
        connectingProgress = 0.0;
      });

      // Simulate loading progress
      for (int i = 1; i <= 30; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        if (!mounted) return;
        setState(() {
          connectingProgress = i / 30;
        });
      }

      setState(() {
        connecting = false;
        connected = true;
      });
      Fluttertoast.showToast(
        msg: "Connected",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
        fontSize: 15.0,
      );
    } else if (connected) {
      _showDisconnectDialog();
    }
  }

  void _showDisconnectDialog() async {
    final shouldDisconnect = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            child: AlertDialog(
              backgroundColor: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: lightPurple.withOpacity(0.3)),
              ),
              title: const Text(
                "Disconnect?",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              content: const Text(
                "Are you sure you want to disconnect from the VPN?",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: lightPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    "Disconnect",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldDisconnect == true) {
      setState(() {
        connected = false;
      });
      Fluttertoast.showToast(
        msg: "Disconnected",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
        fontSize: 15.0,
      );
    }
  }

  void _showNetworkErrorDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            child: AlertDialog(
              backgroundColor: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: warmGold.withOpacity(0.3)),
              ),
              title: const Text(
                "No Network Connection",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: const Text(
                "Please check your WiFi or mobile network connection.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: warmGold,
                    foregroundColor: darkBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      connected = false;
                      connecting = false;
                    });
                  },
                  child: const Text(
                    "Close",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showServerPicker() async {
    int? picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: (connected ? accentTeal : primaryPurple).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (connected ? accentTeal : primaryPurple).withOpacity(
                  0.2,
                ),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: (connected ? accentTeal : primaryPurple).withOpacity(
                    0.5,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Icon(
                      Icons.public,
                      color: connected ? accentTeal : primaryPurple,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Select Server Location",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Warning message if connected
              if (connected) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA726).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFA726).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: const Color(0xFFFFA726),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Changing server will disconnect your current VPN connection",
                          style: TextStyle(
                            color: const Color(0xFFFFA726),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Servers list
              Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: servers.length,
                  separatorBuilder: (_, __) => Divider(
                    color: Colors.white.withOpacity(0.08),
                    height: 1,
                  ),
                  itemBuilder: (context, i) {
                    final isSelected = selectedServer == i;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (connected ? accentTeal : primaryPurple)
                                .withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(
                                color: (connected ? accentTeal : primaryPurple)
                                    .withOpacity(0.3),
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              servers[i]['flag']!,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        title: Text(
                          servers[i]['country']!,
                          style: TextStyle(
                            color: isSelected
                                ? (connected ? accentTeal : primaryPurple)
                                : Colors.white,
                            fontSize: 18,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            if (!isSelected) ...[
                              Icon(Icons.wifi, color: connectGreen, size: 14),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              isSelected ? "Currently selected" : "Online",
                              style: TextStyle(
                                color: isSelected
                                    ? (connected ? softTeal : lightPurple)
                                    : connectGreen,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        trailing: isSelected
                            ? Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      connected ? connectGreen : primaryPurple,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (connected
                                              ? connectGreen
                                              : primaryPurple)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              )
                            : Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                        onTap: () => Navigator.pop(context, i),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );

    if (picked != null && picked != selectedServer) {
      // If connected and trying to change server, show confirmation dialog
      if (connected) {
        await _handleServerChangeConfirmation(picked);
      } else {
        // If not connected, just change server normally
        setState(() {
          selectedServer = picked;
        });
        Fluttertoast.showToast(
          msg: "Server changed to ${servers[picked]['country']}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[800],
          textColor: Colors.white,
          fontSize: 15.0,
        );
      }
    }
  }

  Future<void> _handleServerChangeConfirmation(int newServerIndex) async {
    final shouldChange = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            child: AlertDialog(
              backgroundColor: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: accentTeal.withOpacity(0.3)),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.swap_horiz,
                    color: accentTeal,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Change Server?",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "You are currently connected to VPN. Changing the server will:",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA726).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFA726).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.power_off,
                              color: const Color(0xFFFF6B6B),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Disconnect current VPN",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.public,
                              color: accentTeal,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Switch to ${servers[newServerIndex]['flag']} ${servers[newServerIndex]['country']}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "You'll need to reconnect manually after the server change.",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: lightPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    "Change Server",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldChange == true) {
      // Disconnect first
      setState(() {
        connected = false;
        connecting = false;
        connectingProgress = 0.0;
      });
      Fluttertoast.showToast(
        msg: "Disconnected from VPN",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
        fontSize: 15.0,
      );

      // Wait for disconnect message to show
      await Future.delayed(const Duration(milliseconds: 1000));

      // Change server
      setState(() {
        selectedServer = newServerIndex;
      });
      Fluttertoast.showToast(
        msg: "Server changed to ${servers[newServerIndex]['country']}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
        fontSize: 15.0,
      );
    }
  }

  Widget _buildResponsiveAnimationArea(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isMediumPhone =
        screenWidth >= 360 && screenWidth < 400; // Medium phones
    final isLargePhone =
        screenWidth >= 400 && screenWidth < 768; // Large phones
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Adaptive sizing with more granular breakpoints
    late final double animationSize;
    late final double gifSize;
    late final double connectedImageSize;

   if (isTablet) {
      animationSize = isLandscape ? 350.0 : 400.0;
      gifSize = isLandscape ? 380.0 : 420.0;
      connectedImageSize = isLandscape ? 320.0 : 360.0;
    } else if (isLargePhone) {
      animationSize = 220.0;
      gifSize = 250.0;
      connectedImageSize = 180.0;
    } else if (isMediumPhone) {
      animationSize = 175.0;
      gifSize = 220.0;
      connectedImageSize = 170.0;
    } else {
      // Small phones
      animationSize = 120.0;
      gifSize = 140.0;
      connectedImageSize = 90.0;
    }

    return Center(
      child: SizedBox(
        width: isTablet ? animationSize + 100 : null,
        height: isTablet ? animationSize + 100 : null,
        child: Center(
          child: !connected
              ? // Disconnected state with purple theme - adaptive for tablets
              AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final double scale =
                        1 + 0.05 * sin(_controller.value * 2 * pi);
                    return Transform.translate(
                      offset: const Offset(0, 12),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Modern radar sweep animation - responsive size
                          RadarLoadingAnimation(
                            controller: _controller,
                            size: animationSize,
                            color: primaryPurple,
                          ),
                          // The main GIF with scaling and modern shadow - responsive
                          Transform.scale(
                            scale: scale,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryPurple.withOpacity(0.3),
                                    blurRadius: isTablet
                                        ? 35
                                        : (isMediumPhone
                                            ? 10
                                            : (screenWidth < 360 ? 10 : 20)),
                                    spreadRadius: isTablet
                                        ? 10
                                        : (isMediumPhone
                                            ? 4
                                            : (screenWidth < 360 ? 4 : 8)),
                                  ),
                                  BoxShadow(
                                    color: lightPurple.withOpacity(0.2),
                                    blurRadius: isTablet
                                        ? 60
                                        : (isMediumPhone
                                            ? 20
                                            : (screenWidth < 360 ? 20 : 40)),
                                    spreadRadius: isTablet
                                        ? 30
                                        : (isMediumPhone
                                            ? 12
                                            : (screenWidth < 360 ? 8 : 10)),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  "assets/images/say_no_vpn.gif",
                                  width: gifSize,
                                  height:
                                      gifSize * 0.93, // Maintain aspect ratio
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : // Connected state with teal theme - adaptive for tablets
              AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        RotatingGradientRing(
                          t: _controller.value,
                          size: animationSize,
                          color: accentTeal,
                        ),
                        FloatingHorizontalLines(
                          controller: _controller,
                          size: animationSize,
                          color: primaryPurple,
                        ),
                        FloatingLeftWindLines(
                          controller: _controller,
                          size: animationSize,
                          color: softTeal.withOpacity(0.8),
                        ),
                        AnimatedScale(
                          scale: 1 + 0.03 * (sin(_controller.value * 2 * pi)),
                          duration: Duration.zero,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accentTeal.withOpacity(0.4),
                                  blurRadius: isTablet
                                      ? 35
                                      : (isMediumPhone
                                          ? 18
                                          : (screenWidth < 360 ? 12 : 25)),
                                  spreadRadius: isTablet
                                      ? 12
                                      : (isMediumPhone
                                          ? 5
                                          : (screenWidth < 360 ? 3 : 8)),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              "assets/images/connect_wifi.png",
                              width: connectedImageSize,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildVpnScreen(BuildContext context) {
    final currentServer = servers[selectedServer];
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Proportional sizes for any device
    double titleFontSize = screenWidth * 0.09; // Reduced from 0.13
    double appFilterFontSize = screenWidth * 0.032; // Reduced from 0.04
    double speedValueFontSize = screenWidth * 0.07;
    double speedLabelFontSize = screenWidth * 0.035;
    double unitFontSize = screenWidth * 0.032;
    double serverNameFontSize = screenWidth * 0.045;
    double bannerTitleFontSize = screenWidth * 0.04;
    double bannerSubtitleFontSize = screenWidth * 0.032;
    double upgradeFontSize = screenWidth * 0.032;
    double topPadding = screenHeight * 0.04;
    double sidePadding = screenWidth * 0.04;
    double spacingSmall = screenHeight * 0.018;
    double spacingMedium = screenHeight * 0.014;
    double bannerHeight = screenHeight * 0.08;
    double serverBoxHeight = screenHeight * 0.065; // Reduced from 0.08
    double iconSize = screenWidth * 0.09;
    double smallIconSize = screenWidth * 0.05;
    double borderRadius = screenWidth * 0.04;
    double largeBorderRadius = screenWidth * 0.05;
    double connectBtnHeight = screenHeight * 0.065; // Reduced from 0.08
    // Clamp for extreme small/large screens
    titleFontSize = titleFontSize.clamp(18.0, 40.0); // Lower max
    appFilterFontSize = appFilterFontSize.clamp(9.0, 15.0); // Lower max
    speedValueFontSize = speedValueFontSize.clamp(12.0, 32.0);
    speedLabelFontSize = speedLabelFontSize.clamp(8.0, 18.0);
    unitFontSize = unitFontSize.clamp(8.0, 16.0);
    serverNameFontSize = serverNameFontSize.clamp(10.0, 22.0);
    bannerTitleFontSize = bannerTitleFontSize.clamp(10.0, 20.0);
    bannerSubtitleFontSize = bannerSubtitleFontSize.clamp(8.0, 16.0);
    upgradeFontSize = upgradeFontSize.clamp(8.0, 16.0);
    topPadding = topPadding.clamp(8.0, 40.0);
    sidePadding = sidePadding.clamp(8.0, 40.0);
    spacingSmall = spacingSmall.clamp(4.0, 24.0);
    spacingMedium = spacingMedium.clamp(4.0, 18.0);
    bannerHeight = bannerHeight.clamp(32.0, 80.0);
    serverBoxHeight = serverBoxHeight.clamp(28.0, 60.0); // Lower max
    iconSize = iconSize.clamp(16.0, 48.0);
    smallIconSize = smallIconSize.clamp(10.0, 28.0);
    borderRadius = borderRadius.clamp(6.0, 24.0);
    largeBorderRadius = largeBorderRadius.clamp(8.0, 32.0);
    connectBtnHeight = connectBtnHeight.clamp(28.0, 60.0); // Lower max

    // Dynamic colors based on connection state
    final speedBlockColor = connected ? accentTeal : primaryPurple;
    final blockBackgroundColor =
        connected ? connectedBg.withOpacity(0.8) : cardBg;
    final appFilterBackgroundColor =
        connected ? softTeal.withOpacity(0.2) : cardBg;
    final serverBlockColor = connected ? connectedBg.withOpacity(0.9) : cardBg;
    final adBannerColor = connected ? connectedBg.withOpacity(0.9) : cardBg;
    final textColor = connected ? Colors.white : Colors.white70;

    return Stack(
      children: [
        // Gradient Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: connected
                  ? [connectedBg, connectedBg.withOpacity(0.8), darkBg]
                  : [darkBg, darkBg.withOpacity(0.9), cardBg],
            ),
          ),
        ),
        Column(
          children: [
            // --- Top Section (VPNMax, App Filter, Upload/Download) ---
            Padding(
              padding: EdgeInsets.fromLTRB(
                  sidePadding, topPadding, sidePadding, spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "VPN",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            TextSpan(
                              text: "Max",
                              style: TextStyle(
                                color: connected ? accentTeal : primaryPurple,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        margin: EdgeInsets.only(top: topPadding * 0.25),
                        decoration: BoxDecoration(
                          color: appFilterBackgroundColor,
                          borderRadius: BorderRadius.circular(borderRadius),
                          border: Border.all(
                            color: connected
                                ? accentTeal.withOpacity(0.3)
                                : primaryPurple.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (connected ? accentTeal : primaryPurple)
                                  .withOpacity(0.2),
                              blurRadius: borderRadius,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(borderRadius),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: sidePadding,
                              vertical: topPadding * 0.05,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AppFilterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "APP FILTER",
                            style: TextStyle(
                              color: connected ? accentTeal : primaryPurple,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                              fontSize: appFilterFontSize,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacingSmall),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: spacingSmall * 0.7),
                          decoration: BoxDecoration(
                            color: blockBackgroundColor,
                            borderRadius: BorderRadius.circular(borderRadius),
                            border: Border.all(
                              color: speedBlockColor.withOpacity(0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: speedBlockColor.withOpacity(0.15),
                                blurRadius: borderRadius,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                "UPLOAD",
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: speedLabelFontSize,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: spacingSmall * 0.33),
                              Text(
                                "24.5",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: speedValueFontSize,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: spacingSmall * 0.18),
                              Text(
                                "mbps",
                                style: TextStyle(
                                  color: speedBlockColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: unitFontSize,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: sidePadding * 0.75),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: spacingSmall * 0.7),
                          decoration: BoxDecoration(
                            color: blockBackgroundColor,
                            borderRadius: BorderRadius.circular(borderRadius),
                            border: Border.all(
                              color: speedBlockColor.withOpacity(0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: speedBlockColor.withOpacity(0.15),
                                blurRadius: borderRadius,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                "DOWNLOAD",
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: speedLabelFontSize,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: spacingSmall * 0.33),
                              Text(
                                "87.2",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: speedValueFontSize,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: spacingSmall * 0.18),
                              Text(
                                "mbps",
                                style: TextStyle(
                                  color: speedBlockColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: unitFontSize,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacingMedium),
                  // --- Ad Banner Box ---
                  Container(
                    height: bannerHeight,
                    decoration: BoxDecoration(
                      color: adBannerColor,
                      borderRadius: BorderRadius.circular(largeBorderRadius),
                      border: Border.all(
                        color: (connected ? accentTeal : primaryPurple)
                            .withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (connected ? accentTeal : primaryPurple)
                              .withOpacity(0.2),
                          blurRadius: borderRadius,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: sidePadding * 0.75),
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [warmGold, softGold],
                            ),
                            borderRadius: BorderRadius.circular(iconSize / 2),
                            boxShadow: [
                              BoxShadow(
                                color: warmGold.withOpacity(0.3),
                                blurRadius: borderRadius,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.local_offer,
                              color: const Color(0xFF1A1A2E),
                              size: smallIconSize,
                            ),
                          ),
                        ),
                        SizedBox(width: sidePadding * 0.75),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Premium VPN - 50% OFF",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: bannerTitleFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Upgrade now for no limits",
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: bannerSubtitleFontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sidePadding,
                            vertical: spacingSmall * 0.5,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [warmGold, softGold],
                            ),
                            borderRadius: BorderRadius.circular(borderRadius),
                            boxShadow: [
                              BoxShadow(
                                color: warmGold.withOpacity(0.3),
                                blurRadius: borderRadius,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PremiumScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "UPGRADE",
                              style: TextStyle(
                                color: const Color(0xFF1A1A2E),
                                fontWeight: FontWeight.bold,
                                fontSize: upgradeFontSize,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: sidePadding * 0.75),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // --- Spacer to push content appropriately for smaller screens ---
            Spacer(flex: 2),
            // --- Animation Section ---
            Padding(
              padding: EdgeInsets.only(
                  bottom: spacingMedium * 1.5),
              child: _buildResponsiveAnimationArea(context),
            ),
            // --- Server Box ---
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: sidePadding,
                  vertical: spacingSmall * 0.5),
              child: GestureDetector(
                onTap: showServerPicker,
                child: Container(
                  height: serverBoxHeight,
                  decoration: BoxDecoration(
                    color: serverBlockColor,
                    borderRadius: BorderRadius.circular(largeBorderRadius),
                    border: Border.all(
                      color: connected
                          ? accentTeal.withOpacity(0.4)
                          : primaryPurple.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (connected ? accentTeal : primaryPurple)
                            .withOpacity(0.2),
                        blurRadius: borderRadius,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: sidePadding * 0.75),
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(iconSize / 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: borderRadius * 0.33,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            currentServer['flag']!,
                            style: TextStyle(fontSize: smallIconSize),
                          ),
                        ),
                      ),
                      SizedBox(width: sidePadding * 0.75),
                      Expanded(
                        child: Text(
                          currentServer['country']!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: serverNameFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(spacingSmall * 0.5),
                        decoration: BoxDecoration(
                          color: (connected ? accentTeal : primaryPurple)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: connected ? accentTeal : primaryPurple,
                          size: smallIconSize * 0.75,
                        ),
                      ),
                      SizedBox(width: sidePadding * 0.75),
                    ],
                  ),
                ),
              ),
            ),
            // --- Connect/Disconnect Button ---
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: sidePadding,
                  vertical: spacingSmall * 0.4),
              child: SizedBox(
                width: double.infinity,
                height: connectBtnHeight,
                child: connecting
                    ? ConnectingButton(progress: connectingProgress)
                    : connected
                        ? DisconnectButton(onPressed: toggleConnection)
                        : ConnectButton(
                            onPressed: toggleConnection,
                            color: primaryPurple,
                          ),
              ),
            ),
            SizedBox(height: spacingSmall * 0.2),
          ],
        ),
      ],
    );
  }
}

// ...existing code...
// --- Updated Radar Loading Animation ---
class RadarLoadingAnimation extends StatelessWidget {
  final Animation<double> controller;
  final double size;
  final Color color;

  const RadarLoadingAnimation({
    super.key,
    required this.controller,
    this.size = 250,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _RadarLoadingPainter(progress: controller.value, color: color),
    );
  }
}

class _RadarLoadingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RadarLoadingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw enhanced radar circles
    final Paint circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 1; i <= 4; i++) {
      circlePaint.color = color.withOpacity(0.08 + (i * 0.03));
      canvas.drawCircle(center, radius * i / 4, circlePaint);
    }

    // Draw enhanced radar sweep
    final Paint sweepPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = SweepGradient(
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(0.25),
          color.withOpacity(0.1),
          color.withOpacity(0.0),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
        startAngle: 0,
        endAngle: 2 * pi,
        transform: GradientRotation(progress * 2 * pi),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sweepPaint);

    // Draw scanning line
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * 2 * pi);

    final Paint linePaint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(0, 0), Offset(radius - 30, 0), linePaint);

    canvas.restore();

    // Draw center dot
    final Paint centerPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 4, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarLoadingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// --- Enhanced Floating Horizontal Lines Widget ---
class FloatingHorizontalLines extends StatelessWidget {
  final Animation<double> controller;
  final double size;
  final Color color;

  const FloatingHorizontalLines({
    super.key,
    required this.controller,
    this.size = 280,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(
        MediaQuery.of(context).size.width,
        size,
      ), // Use full screen width
      painter: _FloatingHorizontalLinesPainter(
        progress: controller.value,
        color: color,
        screenWidth: MediaQuery.of(context).size.width, // Pass screen width
      ),
    );
  }
}

class _FloatingHorizontalLinesPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double screenWidth;

  _FloatingHorizontalLinesPainter({
    required this.progress,
    required this.color,
    required this.screenWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Sharp main line paint with increased brightness
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5 // Increased for better visibility and sharpness
      ..strokeCap = StrokeCap.square; // Sharp edges instead of round

    // Multiple glow layers for enhanced brightness effect
    final Paint outerGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0 // Outer glow layer
      ..strokeCap = StrokeCap.round;

    final Paint innerGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5 // Inner glow layer
      ..strokeCap = StrokeCap.round;

    final double centerY = size.height / 2;
    final double minY = centerY - 90;
    final double maxY = centerY + 90;
    // Use actual screen dimensions to go from edge to edge
    final double screenLeft = -20.0; // Start from beyond left edge of screen
    final double screenRight =
        screenWidth + 20.0; // End beyond right edge of screen

    final List<double> yOffsets = [
      minY + 10,
      minY + 35,
      minY + 60,
      centerY - 40,
      centerY - 15,
      centerY + 15,
      centerY + 40,
      maxY - 60,
      maxY - 35,
      maxY - 10,
    ];

    for (int i = 0; i < yOffsets.length; i++) {
      // Significantly faster animation with higher speed multiplier
      double t =
          (progress * 3.5 + i * 0.2) % 1.0; // 3.5x speed multiplier (was 2.5x)
      double dx = (screenRight - screenLeft) * t;

      // Enhanced fade calculation with cubic interpolation for smoother transitions
      double fade = 1.0;
      if (t < 0.12)
        fade = (t / 0.12) * (t / 0.12) * (t / 0.12); // Cubic ease-in
      if (t > 0.88)
        fade = ((1.0 - t) / 0.12) *
            ((1.0 - t) / 0.12) *
            ((1.0 - t) / 0.12); // Cubic ease-out

      // Much brighter main line opacity
      final mainOpacity = 0.85 + 0.15 * fade;
      paint.color = color.withOpacity(mainOpacity);

      // Brighter outer glow effect
      final outerGlowOpacity = 0.15 + 0.25 * fade;
      outerGlowPaint.color = color.withOpacity(outerGlowOpacity);

      // Brighter inner glow effect
      final innerGlowOpacity = 0.35 + 0.45 * fade;
      innerGlowPaint.color = color.withOpacity(innerGlowOpacity);

      double lineLength = 55 +
          30 *
              sin(i +
                  progress * 3.5 * pi); // Increased length and faster variation

      final startPoint = Offset(screenLeft + dx, yOffsets[i]);
      final endPoint = Offset(screenLeft + dx + lineLength, yOffsets[i]);

      // Draw multi-layer glow effects for maximum brightness
      canvas.drawLine(startPoint, endPoint, outerGlowPaint); // Outer glow
      canvas.drawLine(startPoint, endPoint, innerGlowPaint); // Inner glow
      canvas.drawLine(startPoint, endPoint, paint); // Sharp main line on top
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingHorizontalLinesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// --- Enhanced Floating Left Wind Lines Widget ---
class FloatingLeftWindLines extends StatelessWidget {
  final Animation<double> controller;
  final double size;
  final Color color;

  const FloatingLeftWindLines({
    super.key,
    required this.controller,
    this.size = 280,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FloatingLeftWindLinesPainter(
        progress: controller.value,
        color: color,
      ),
    );
  }
}

class _FloatingLeftWindLinesPainter extends CustomPainter {
  final double progress;
  final Color color;

  _FloatingLeftWindLinesPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double minX = centerX - 90;
    final double maxX = centerX + 90;

    final List<Offset> positions = [
      Offset(minX + 20, centerY - 60),
      Offset(minX + 40, centerY - 20),
      Offset(minX + 15, centerY + 20),
      Offset(minX + 35, centerY + 60),
    ];

    for (int i = 0; i < positions.length; i++) {
      double t = (progress + i * 0.2) % 1.0;
      double dx = (maxX - minX) * t * 0.6;

      double fade = 1.0;
      if (t < 0.2) fade = t / 0.2;
      if (t > 0.8) fade = (1.0 - t) / 0.2;

      paint.color = color.withOpacity(0.2 + 0.4 * fade);

      double lineLength = 25 + 10 * sin(i + progress * 3 * pi);

      canvas.drawLine(
        Offset(positions[i].dx + dx, positions[i].dy),
        Offset(positions[i].dx + dx + lineLength, positions[i].dy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingLeftWindLinesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// --- Enhanced Rotating Gradient Ring ---
class RotatingGradientRing extends StatelessWidget {
  final double t;
  final double size;
  final Color color;
  const RotatingGradientRing({
    super.key,
    required this.t,
    this.size = 280,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: t * 2 * pi,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [
              color,
              color.withOpacity(0.6),
              color.withOpacity(0.3),
              color.withOpacity(0.1),
              color,
            ],
            stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
            startAngle: 0.0,
            endAngle: 2 * pi,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 25,
              spreadRadius: 15,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Enhanced Connect Button ---
class ConnectButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;
  const ConnectButton({
    super.key,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 360;
    final isSmall = screenWidth >= 360 && screenWidth < 400;

    // Enhanced responsive button sizing
    late final double buttonHeight;
    late final double fontSize;
    late final double borderRadius;
    late final double letterSpacing;

    if (isVerySmall) {
      buttonHeight = 44.0;
      fontSize = 14.0;
      borderRadius = 14.0;
      letterSpacing = 0.8;
    } else if (isSmall) {
      buttonHeight = 48.0;
      fontSize = 15.0;
      borderRadius = 16.0;
      letterSpacing = 1.0;
    } else if (context.hasLimitedHeight) {
      buttonHeight = 52.0;
      fontSize = 16.0;
      borderRadius = 18.0;
      letterSpacing = 1.1;
    } else {
      buttonHeight = 56.0;
      fontSize = 18.0;
      borderRadius = 20.0;
      letterSpacing = 1.2;
    }

    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: isVerySmall ? 4 : (isSmall ? 6 : 8),
          shadowColor: color.withOpacity(0.4),
        ),
        onPressed: onPressed,
        child: Text(
          "CONNECT",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: letterSpacing,
          ),
        ),
      ),
    );
  }
}

// --- Enhanced Connecting Button ---
class ConnectingButton extends StatelessWidget {
  final double progress;

  const ConnectingButton({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toInt();
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 360;
    final isSmall = screenWidth >= 360 && screenWidth < 400;

    // Enhanced responsive button sizing
    late final double buttonHeight;
    late final double fontSize;
    late final double borderRadius;
    late final double letterSpacing;

    if (isVerySmall) {
      buttonHeight = 44.0;
      fontSize = 12.0;
      borderRadius = 14.0;
      letterSpacing = 0.6;
    } else if (isSmall) {
      buttonHeight = 48.0;
      fontSize = 13.0;
      borderRadius = 16.0;
      letterSpacing = 0.7;
    } else if (context.hasLimitedHeight) {
      buttonHeight = 52.0;
      fontSize = 14.0;
      borderRadius = 18.0;
      letterSpacing = 0.8;
    } else {
      buttonHeight = 56.0;
      fontSize = 16.0;
      borderRadius = 20.0;
      letterSpacing = 1.0;
    }

    return SizedBox(
      height: buttonHeight,
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  Container(
                    width: constraints.maxWidth * progress,
                    height: buttonHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _AnimationPageState.accentTeal,
                          _AnimationPageState.connectGreen,
                        ],
                      ),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(borderRadius),
                        right: Radius.circular(
                          progress == 1.0 ? borderRadius : 0,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: constraints.maxWidth * (1 - progress),
                    height: buttonHeight,
                    decoration: BoxDecoration(
                      color: _AnimationPageState.cardBg.withOpacity(0.8),
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(borderRadius),
                        left: Radius.circular(
                          progress == 0.0 ? borderRadius : 0,
                        ),
                      ),
                      border: Border.all(
                        color: _AnimationPageState.accentTeal.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Container(
            height: buttonHeight,
            alignment: Alignment.center,
            child: Text(
              "CONNECTING... $percent%",
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: letterSpacing,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Enhanced Disconnect Button ---
class DisconnectButton extends StatelessWidget {
  final VoidCallback onPressed;
  const DisconnectButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 360;
    final isSmall = screenWidth >= 360 && screenWidth < 400;

    // Enhanced responsive button sizing
    late final double buttonHeight;
    late final double fontSize;
    late final double borderRadius;
    late final double letterSpacing;

    if (isVerySmall) {
      buttonHeight = 44.0;
      fontSize = 14.0;
      borderRadius = 14.0;
      letterSpacing = 0.8;
    } else if (isSmall) {
      buttonHeight = 48.0;
      fontSize = 15.0;
      borderRadius = 16.0;
      letterSpacing = 1.0;
    } else if (context.hasLimitedHeight) {
      buttonHeight = 52.0;
      fontSize = 16.0;
      borderRadius = 18.0;
      letterSpacing = 1.1;
    } else {
      buttonHeight = 56.0;
      fontSize = 18.0;
      borderRadius = 20.0;
      letterSpacing = 1.2;
    }

    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _AnimationPageState.accentTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: isVerySmall ? 4 : (isSmall ? 6 : 8),
          shadowColor: _AnimationPageState.accentTeal.withOpacity(0.4),
        ),
        onPressed: onPressed,
        child: Text(
          "DISCONNECT",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: letterSpacing,
          ),
        ),
      ),
    );
  }
}

// --- Enhanced Bottom Navigation Item ---
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: selected
                    ? BoxDecoration(
                        color: selectedColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  icon,
                  color: selected ? selectedColor : Colors.white60,
                  size: 26,
                ),
              ),
              const SizedBox(height: 0),
              Text(
                label,
                style: TextStyle(
                  color: selected ? selectedColor : Colors.white60,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Enhanced More Screen ---
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_AnimationPageState.darkBg, _AnimationPageState.cardBg],
        ),
      ),
      width: double.infinity,
      child: SingleChildScrollView(
        // Increase top padding to move options lower and avoid status bar clash
        padding: context.responsivePadding(horizontal: 20, vertical: 60),
        child: Column(
          children: [
            _MoreTile(
              icon: Icons.flash_on,
              label: "Get Premium Access",
              trailing: Container(
                padding: context.responsivePadding(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _AnimationPageState.warmGold,
                      _AnimationPageState.softGold,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(
                    context.responsiveBorderRadius(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _AnimationPageState.warmGold.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  "UNLOCK",
                  style: context.responsiveTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PremiumScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: context.responsiveSpacing(16)),
            _MoreTile(
              icon: Icons.share,
              label: "Share App",
              trailing: Icon(
                Icons.chevron_right,
                color: _AnimationPageState.lightPurple,
                size: context.responsiveIconSize(20),
              ),
              onTap: () async {
                // Share app link using share_plus
                const appUrl = 'https://play.google.com/store/apps/details?id=com.technosofts.vpnmax';
                await Share.share('Check out VPN Max for fast and secure browsing! $appUrl');
              },
            ),
            SizedBox(height: context.responsiveSpacing(16)),
            _MoreTile(
              icon: Icons.star_border,
              label: "Rate this app",
              trailing: Icon(
                Icons.chevron_right,
                color: _AnimationPageState.lightPurple,
                size: context.responsiveIconSize(20),
              ),
              onTap: () async {
                // Open Play Store app page using url_launcher
                const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.technosofts.vpnmax';
                final uri = Uri.parse(playStoreUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  Fluttertoast.showToast(msg: 'Could not open Play Store.');
                }
              },
            ),
            SizedBox(height: context.responsiveSpacing(16)),
            _MoreTile(
              icon: Icons.feedback_outlined,
              label: "Feedback",
              trailing: Icon(
                Icons.chevron_right,
                color: _AnimationPageState.lightPurple,
                size: context.responsiveIconSize(20),
              ),
              onTap: () async {
                // Open mail app with prefilled feedback email
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'vpnapp@technosofts.net',
                  query: 'subject=VPN Max Feedback&body=Your feedback here',
                );
                if (await canLaunchUrl(emailLaunchUri)) {
                  await launchUrl(emailLaunchUri);
                } else {
                  Fluttertoast.showToast(msg: 'No email app found.');
                }
              },
            ),
            SizedBox(height: context.responsiveSpacing(24)),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _AnimationPageState.cardBg,
                borderRadius: BorderRadius.circular(
                  context.responsiveBorderRadius(16),
                ),
                border: Border.all(
                  color: _AnimationPageState.lightPurple.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _AnimationPageState.primaryPurple.withOpacity(0.1),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: context.responsivePadding(all: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Device UUID",
                    style: context.responsiveTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: context.responsiveSpacing(12)),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "02c8bcf6-d30-4166-b291-410ef39c8abc",
                          style: context.responsiveTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _AnimationPageState.lightPurple,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(width: context.responsiveSpacing(12)),
                      GestureDetector(
                        onTap: () => _copyToClipboard(context),
                        child: Container(
                          padding: context.responsivePadding(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _AnimationPageState.primaryPurple,
                            borderRadius: BorderRadius.circular(
                              context.responsiveBorderRadius(10),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _AnimationPageState.primaryPurple
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Text(
                            "COPY",
                            style: context.responsiveTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // (Removed dialog stubs; now using real platform actions above)

  static void _copyToClipboard(BuildContext context) {
    // In a real app, you would copy the UUID to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Device UUID copied to clipboard!",
          style: context.responsiveTextStyle(fontSize: 14, color: Colors.white),
        ),
        backgroundColor: _AnimationPageState.accentTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            context.responsiveBorderRadius(10),
          ),
        ),
      ),
    );
  }
}

// --- Enhanced More Tile Widget ---
class _MoreTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _MoreTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _AnimationPageState.cardBg,
      borderRadius: BorderRadius.circular(
        context.getResponsiveBorderRadius(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          context.getResponsiveBorderRadius(16),
        ),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              context.getResponsiveBorderRadius(16),
            ),
            border: Border.all(
              color: _AnimationPageState.lightPurple.withOpacity(0.2),
              width: context.getResponsiveBorderWidth(1),
            ),
            boxShadow: [
              BoxShadow(
                color: _AnimationPageState.primaryPurple.withOpacity(0.1),
                blurRadius: context.getResponsiveSpacing(8),
                spreadRadius: context.getResponsiveSpacing(1),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: context.getResponsiveSpacing(16),
            vertical: context.getResponsiveSpacing(16),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.getResponsiveSpacing(8)),
                decoration: BoxDecoration(
                  color: _AnimationPageState.primaryPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(
                    context.getResponsiveBorderRadius(10),
                  ),
                ),
                child: Icon(
                  icon,
                  color: _AnimationPageState.lightPurple,
                  size: context.getResponsiveIconSize(20),
                ),
              ),
              SizedBox(width: context.getResponsiveSpacing(16)),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: (context.getResponsiveFontSize(17)).clamp(16.0, 22.0),
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}