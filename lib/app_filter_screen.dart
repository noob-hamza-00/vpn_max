import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'responsive_utils.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

class AppFilterScreen extends StatefulWidget {
  const AppFilterScreen({super.key});

  @override
  State<AppFilterScreen> createState() => _AppFilterScreenState();
}

class _AppFilterScreenState extends State<AppFilterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AppInfo> installedApps = [];
  List<AppInfo> systemApps = [];
  List<AppInfo> filteredInstalledApps = [];
  List<AppInfo> filteredSystemApps = [];
  // Store filter state for each app by package name
  Map<String, bool> appFilterStates = {};
  bool isLoading = true;
  String errorMessage = '';
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  // Colors matching the main app theme
  static const Color primaryPurple = Color(0xFF8A2BE2);
  static const Color lightPurple = Color(0xFFB19CD9);
  static const Color accentTeal = Color(0xFF20E5C7);
  static const Color darkBg = Color(0xFF1A1A2E);
  static const Color cardBg = Color(0xFF16213E);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadApps();
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApps() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Request permissions for Android
      if (Platform.isAndroid) {
        await [Permission.storage, Permission.manageExternalStorage].request();
      }

      // Use MULTIPLE methods to get ALL apps from physical device
      List<AppInfo> allApps = [];

      // Method 1: Get apps with icons and system apps
      try {
        List<AppInfo> appsWithIcons =
            await InstalledApps.getInstalledApps(true, true);
        allApps.addAll(appsWithIcons);
        print('📱 Method 1: Loaded ${appsWithIcons.length} apps with icons');
      } catch (e) {
        print('❌ Method 1 failed: $e');
      }

      // Method 2: Get apps without icons but include system apps
      try {
        List<AppInfo> appsWithoutIcons =
            await InstalledApps.getInstalledApps(false, true);
        for (var app in appsWithoutIcons) {
          if (!allApps
              .any((existing) => existing.packageName == app.packageName)) {
            allApps.add(app);
          }
        }
        print(
            '📱 Method 2: Total after adding apps without icons: ${allApps.length}');
      } catch (e) {
        print('❌ Method 2 failed: $e');
      }

      // Method 3: Get only system apps to ensure we catch Chrome/YouTube/Google
      try {
        List<AppInfo> systemOnlyApps =
            await InstalledApps.getInstalledApps(true, false);
        for (var app in systemOnlyApps) {
          if (!allApps
              .any((existing) => existing.packageName == app.packageName)) {
            allApps.add(app);
          }
        }
        print('📱 Method 3: Total after adding system apps: ${allApps.length}');
      } catch (e) {
        print('❌ Method 3 failed: $e');
      }

      // Method 4: Get user apps only (in case Chrome/YouTube are installed as user apps)
      try {
        List<AppInfo> userOnlyApps =
            await InstalledApps.getInstalledApps(false, false);
        for (var app in userOnlyApps) {
          if (!allApps
              .any((existing) => existing.packageName == app.packageName)) {
            allApps.add(app);
          }
        }
        print('📱 Method 4: Total after adding user apps: ${allApps.length}');
      } catch (e) {
        print('❌ Method 4 failed: $e');
      }

      print(
          '📱 FINAL TOTAL: Loaded ${allApps.length} apps from physical device');

      // Debug: Check if we found Chrome, Google, or YouTube
      final chromeFound = allApps
          .where((app) =>
              app.name.toLowerCase().contains('chrome') ||
              app.packageName.toLowerCase().contains('chrome'))
          .toList();
      final googleFound = allApps
          .where((app) =>
              app.name.toLowerCase().contains('google') ||
              app.packageName.toLowerCase().contains('google'))
          .toList();
      final youtubeFound = allApps
          .where((app) =>
              app.name.toLowerCase().contains('youtube') ||
              app.packageName.toLowerCase().contains('youtube'))
          .toList();

      print('🔍 Chrome apps found on device: ${chromeFound.length}');
      for (var app in chromeFound) {
        print('  📱 ${app.name} (${app.packageName})');
      }
      print('🔍 Google apps found on device: ${googleFound.length}');
      for (var app in googleFound.take(5)) {
        // Show first 5 to avoid spam
        print('  📱 ${app.name} (${app.packageName})');
      }
      print('🔍 YouTube apps found on device: ${youtubeFound.length}');
      for (var app in youtubeFound) {
        print('  📱 ${app.name} (${app.packageName})');
      }

      setState(() {
        // Whitelist for system apps: Google, Chrome, YouTube, and a few real device system apps (excluding phone, messaging, storage)
        final systemWhitelist = [
          'com.android.chrome',
          'com.google.android.youtube',
          'com.google.android.apps.youtube.music',
          'com.google.android.apps.youtube.kids',
          'com.google.android.googlequicksearchbox',
          'com.google.android.gms',
          'com.google.android.gsf',
          'com.android.camera',
          'com.android.gallery3d',
          'com.android.contacts',
          'com.android.calculator',
          'com.android.clock',
          'com.android.settings',
          'com.android.inputmethod.latin',
          'com.android.launcher',
          'com.android.launcher3',
          'com.android.wallpaper',
          'com.android.music',
          'com.android.calendar',
          'com.android.documentsui',
          'com.android.bluetooth',
          'com.android.nfc',
          'com.android.providers.downloads',
          'com.android.providers.media',
          'com.android.providers.contacts',
          'com.android.providers.calendar',
          'com.android.providers.telephony',
          'com.android.providers.settings',
          // Device-specific app stores and core apps
          'com.android.vending', // Google Play Store
          'com.samsung.android.app.samsungapps', // Samsung Galaxy Store
          'com.xiaomi.market', // Xiaomi App Store
          'com.huawei.appmarket', // Huawei AppGallery
          'com.oppo.market', // OPPO App Market
          'com.vivo.appstore', // Vivo App Store
          'com.miui.securitycenter', // Xiaomi Security
          'com.samsung.android.sm', // Samsung Device Care
          'com.huawei.systemmanager', // Huawei Phone Manager
          'com.oneplus.security', // OnePlus Security
          'com.oppo.safe', // OPPO Phone Manager
          'com.vivo.safecenter', // Vivo iManager
        ];

        // System apps: only Google, Chrome, YouTube, and a few real device system apps (excluding phone, messaging, storage)
        final systemExclude = [
          'com.android.phone',
          'com.android.dialer',
          'com.android.messaging',
          'com.android.providers.telephony',
          'com.android.providers.contacts',
          'com.android.providers.calendar',
          'com.android.providers.settings',
          'com.android.providers.downloads',
          'com.android.providers.media',
          'com.android.providers.userdictionary',
          'com.android.providers.blockednumber',
          'com.android.providers.applications',
          'com.android.providers.storage',
        ];
        systemApps = allApps.where((app) {
          final appNameLower = app.name.toLowerCase();
          final packageNameLower = app.packageName.toLowerCase();
          // Google, Chrome, YouTube
          if (_isChromeApp(appNameLower, packageNameLower)
              || _isGoogleApp(appNameLower, packageNameLower)
              || _isYouTubeApp(appNameLower, packageNameLower)) {
            return true;
          }
          // Always show real device system apps (gallery, calculator, phone, contacts, camera, clock, calendar, music, documentsui, bluetooth, nfc, settings, launcher, wallpaper, inputmethod.latin, device app stores, security, device care, phone manager, storage, etc.)
          if (systemWhitelist.contains(app.packageName)
              || packageNameLower == 'com.android.gallery3d'
              || packageNameLower == 'com.android.calculator'
              || packageNameLower == 'com.android.phone'
              || packageNameLower == 'com.android.contacts'
              || packageNameLower == 'com.android.camera'
              || packageNameLower == 'com.android.clock'
              || packageNameLower == 'com.android.calendar'
              || packageNameLower == 'com.android.music'
              || packageNameLower == 'com.android.documentsui'
              || packageNameLower == 'com.android.bluetooth'
              || packageNameLower == 'com.android.nfc'
              || packageNameLower == 'com.android.settings'
              || packageNameLower == 'com.android.launcher'
              || packageNameLower == 'com.android.launcher3'
              || packageNameLower == 'com.android.wallpaper'
              || packageNameLower == 'com.android.inputmethod.latin'
              || packageNameLower == 'com.android.vending'
              || packageNameLower == 'com.samsung.android.app.samsungapps'
              || packageNameLower == 'com.xiaomi.market'
              || packageNameLower == 'com.huawei.appmarket'
              || packageNameLower == 'com.oppo.market'
              || packageNameLower == 'com.vivo.appstore'
              || packageNameLower == 'com.miui.securitycenter'
              || packageNameLower == 'com.samsung.android.sm'
              || packageNameLower == 'com.huawei.systemmanager'
              || packageNameLower == 'com.oneplus.security'
              || packageNameLower == 'com.oppo.safe'
              || packageNameLower == 'com.vivo.safecenter'
              || packageNameLower == 'com.android.providers.storage'
              || packageNameLower == 'com.android.providers.calendar'
              || packageNameLower == 'com.android.providers.contacts'
              || packageNameLower == 'com.android.providers.media'
              || packageNameLower == 'com.android.providers.downloads'
          ) {
            // Exclude phone, messaging, storage, etc.
            if (systemExclude.contains(app.packageName)) {
              return false;
            }
            return true;
          }
          return false;
        }).toList();

        // Installed apps: only user-installed apps (not system apps, not Google/Chrome/YouTube, not support components)
        // Aggressive exclusion for installed apps: remove all unwanted packages and app names
        final extraUnwantedPatterns = [
          'com.sec', 'usb', 'tether', 'resoverlay', 'automation', 'soundquality', 'sound quality', 'sound effects', 'smart fps', 'fps adjuster', 'silent logging', 'safety information', 'roboto', 'rilnotifier', 'perso', 'nsdswebapp', 'meta app installer', 'meta components', 'magtap', 'launcher', 'klms agent', 'imslogger', 'ims settings', 'gestural navigation', 'factory camera', 'easy onehand', 'diagmonagent', 'factory', 'onehand', 'diagmon', 'logger', 'ims', 'settings', 'usb settings', 'overlay', 'effects', 'fps', 'logging', 'safety', 'information', 'notifier', 'installer', 'components', 'tap', 'agent', 'navigation', 'camera', 'meta', 'mag', 'smart', 'silent', 'quality', 'sound', 'storage', 'android', 'samsung', 'system', 'service', 'setup', 'manager', 'security', 'provider', 'framework', 'utility', 'test', 'demo', 'sample', 'miui', 'xiaomi', 'huawei', 'oneplus', 'oppo', 'vivo', 'qualcomm', 'mediatek', 'bixby', 'knox', 'wellbeing', 'health', 'nfc', 'bluetooth', 'print', 'backup', 'restore', 'update', 'store', 'market', 'appstore', 'themes', 'wallpaper', 'audio', 'radio', 'fm', 'scanner', 'compass', 'flashlight', 'recorder', 'voice', 'speech', 'download', 'file', 'emergency', 'sos', 'find', 'locate', 'tracker', 'analytics', 'telemetry', 'diagnostics'
        ];
        installedApps = allApps.where((app) {
          final appNameLower = app.name.toLowerCase();
          final packageNameLower = app.packageName.toLowerCase();
          // Exclude Google, Chrome, YouTube, system apps, all real device apps, and device-specific app stores/core apps
          if (_isChromeApp(appNameLower, packageNameLower)
              || _isGoogleApp(appNameLower, packageNameLower)
              || _isYouTubeApp(appNameLower, packageNameLower)
              || systemWhitelist.contains(app.packageName)
              || packageNameLower == 'com.android.gallery3d'
              || packageNameLower == 'com.android.calculator'
              || packageNameLower == 'com.android.phone'
              || packageNameLower == 'com.android.contacts'
              || packageNameLower == 'com.android.camera'
              || packageNameLower == 'com.android.clock'
              || packageNameLower == 'com.android.calendar'
              || packageNameLower == 'com.android.music'
              || packageNameLower == 'com.android.documentsui'
              || packageNameLower == 'com.android.bluetooth'
              || packageNameLower == 'com.android.nfc'
              || packageNameLower == 'com.android.settings'
              || packageNameLower == 'com.android.launcher'
              || packageNameLower == 'com.android.launcher3'
              || packageNameLower == 'com.android.wallpaper'
              || packageNameLower == 'com.android.inputmethod.latin'
              || packageNameLower == 'com.android.vending'
              || packageNameLower == 'com.samsung.android.app.samsungapps'
              || packageNameLower == 'com.xiaomi.market'
              || packageNameLower == 'com.huawei.appmarket'
              || packageNameLower == 'com.oppo.market'
              || packageNameLower == 'com.vivo.appstore'
              || packageNameLower == 'com.miui.securitycenter'
              || packageNameLower == 'com.samsung.android.sm'
              || packageNameLower == 'com.huawei.systemmanager'
              || packageNameLower == 'com.oneplus.security'
              || packageNameLower == 'com.oppo.safe'
              || packageNameLower == 'com.vivo.safecenter'
          ) {
            return false;
          }
          // Exclude all apps with system prefixes (com.android., com.google.android., etc.) unless they are in the Play Store install list
          final systemPrefixes = [
            'com.android.', 'com.google.android.', 'com.samsung.android.', 'com.miui.', 'com.xiaomi.', 'com.huawei.', 'com.oneplus.', 'com.oppo.', 'com.vivo.', 'android.', 'org.', 'net.', 'vendor.'
          ];
          for (final prefix in systemPrefixes) {
            if (packageNameLower.startsWith(prefix)) {
              return false;
            }
          }
          // Exclude apps with package names starting with com.android., com.google.android., com.samsung.android., etc.
          
          // Exclude com.google.manline.telemetry and support components specifically
          if (packageNameLower == 'com.google.manline.telemetry' || appNameLower.contains('support components')) {
            return false;
          }
          // Exclude all extra unwanted patterns (package or app name)
          for (final pattern in extraUnwantedPatterns) {
            if (packageNameLower.contains(pattern) || appNameLower.contains(pattern)) {
              return false;
            }
          }
          return true;
        }).toList();

        // Sort alphabetically
        systemApps.sort((a, b) => a.name.compareTo(b.name));
        installedApps.sort((a, b) => a.name.compareTo(b.name));

        isLoading = false;
        filteredSystemApps = systemApps;
        filteredInstalledApps = installedApps;
      });
    } catch (e) {
      print('❌ Error loading apps: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load apps: ${e.toString()}';
      });
    }
  }

  // Force these essential Google apps to always be treated as system apps

  bool _isSystemApp(String packageName, String appName) {
    // Comprehensive system app package names and patterns
    const systemPackages = [
      // Core Google Apps
      'com.android.chrome',
      'com.google.android.youtube',
      'com.google.android.gms',
      'com.google.android.gsf',
      'com.google.android.googlequicksearchbox', // Google Search
      'com.google.android.apps.photos',
      'com.google.android.apps.maps',
      'com.google.android.gmail',
      'com.google.android.apps.messaging',
      'com.google.android.inputmethod.latin', // Gboard
      'com.google.android.webview',
      'com.google.android.gm', // Gmail alternative package
      'com.google.android.talk', // Google Meet/Hangouts
      'com.google.android.apps.docs', // Google Drive/Docs
      'com.google.android.apps.docs.editors.docs', // Google Docs
      'com.google.android.apps.docs.editors.sheets', // Google Sheets
      'com.google.android.apps.docs.editors.slides', // Google Slides
      'com.google.android.calendar',
      'com.google.android.contacts',
      'com.google.android.dialer', // Google Phone
      'com.google.android.apps.youtube.music', // YouTube Music
      'com.google.android.apps.youtube.kids', // YouTube Kids
      'com.google.android.apps.translate', // Google Translate
      'com.google.android.keep', // Google Keep
      'com.google.android.apps.fitness', // Google Fit
      'com.google.android.apps.wellbeing', // Digital Wellbeing
      'com.google.android.packageinstaller',
      'com.google.android.permissioncontroller',
      'com.google.android.networkstack',
      'com.google.android.networkstack.tethering',
      'com.google.android.captiveportallogin',
      'com.google.android.ext.services',
      'com.google.android.ext.shared',
      'com.google.android.printservice.recommendation',
      'com.google.android.apps.walletnfcrel', // Google Pay/Wallet
      'com.google.android.apps.authenticator2', // Google Authenticator
      'com.google.android.projection.gearhead', // Android Auto
      'com.google.android.apps.chromecast.app', // Google Home
      'com.google.android.apps.podcasts', // Google Podcasts
      'com.google.android.apps.nexuslauncher', // Pixel Launcher
      'com.google.android.launcher', // Google Launcher
      'com.google.android.setupwizard',
      'com.google.android.partnersetup',
      'com.google.android.marvin.talkback', // TalkBack
      'com.google.android.accessibility.suite',

      // Core Android System Apps
      'com.android.settings',
      'com.android.systemui',
      'com.android.phone',
      'com.android.contacts',
      'com.android.camera2',
      'com.android.camera',
      'com.android.gallery3d',
      'com.android.calculator',
      'com.android.calendar',
      'com.android.music',
      'com.android.documentsui',
      'com.android.bluetooth',
      'com.android.nfc',
      'com.android.providers.downloads',
      'com.android.providers.media',
      'com.android.providers.contacts',
      'com.android.providers.calendar',
      'com.android.providers.telephony',
      'com.android.providers.settings',
      'com.android.vending', // Play Store
      'com.android.launcher3',
      'com.android.launcher',
      'com.android.wallpaper',
      'com.android.keychain',
      'com.android.permissioncontroller',
      'com.android.shell',
      'com.android.sharedstoragebackup',
      'com.android.printspooler',
      'com.android.server.telecom',
      'com.android.cellbroadcastreceiver',
      'com.android.emergency',
      'com.android.mms',
      'com.android.mms.service',
      'com.android.messaging',
      'com.android.deskclock', // Clock
      'com.android.soundrecorder',
      'com.android.bips', // Built-in Print Service
      'com.android.facelock',
      'com.android.inputmethod.latin',
      'com.android.managedprovisioning',
      'com.android.dreams.basic',
      'com.android.dreams.phototable',
      'com.android.provision',
      'com.android.statementservice',
      'com.android.calllogbackup',
      'com.android.companiondevicemanager',
      'com.android.mtp',
      'com.android.ons',
      'com.android.stk',
      'com.android.wallpaperbackup',
      'com.android.carrierconfig',
      'com.android.carrierdefaultapp',

      // Samsung System Apps
      'com.samsung.android.app.galaxyfinder', // Samsung Finder
      'com.samsung.android.bixby.agent', // Bixby
      'com.samsung.android.visionintelligence', // Bixby Vision
      'com.samsung.android.app.spage', // Samsung Daily
      'com.samsung.android.oneconnect', // SmartThings
      'com.samsung.android.smartface', // Smart Stay
      'com.samsung.android.app.soundalive', // SoundAlive
      'com.samsung.android.game.gametools', // Game Tools
      'com.samsung.android.game.gos', // Game Optimizing Service
      'com.samsung.android.messaging', // Samsung Messages
      'com.samsung.android.dialer', // Samsung Phone
      'com.samsung.android.contacts', // Samsung Contacts
      'com.samsung.android.calendar', // Samsung Calendar
      'com.samsung.android.gallery3d', // Samsung Gallery
      'com.samsung.android.camera', // Samsung Camera
      'com.samsung.android.app.notes', // Samsung Notes
      'com.samsung.android.email.provider', // Samsung Email
      'com.samsung.android.app.memo', // Samsung Memo
      'com.samsung.android.weather', // Samsung Weather
      'com.samsung.android.app.music', // Samsung Music
      'com.samsung.android.video', // Samsung Video
      'com.samsung.android.tvplus', // Samsung TV Plus
      'com.samsung.android.app.watchmanager', // Galaxy Watch Manager
      'com.samsung.android.health', // Samsung Health
      'com.samsung.android.wellbeing', // Digital Wellbeing
      'com.samsung.android.accessibility', // Samsung Accessibility
      'com.samsung.voiceservice', // Samsung Voice Service
      'com.samsung.android.samsungpass', // Samsung Pass
      'com.samsung.android.securefolder', // Secure Folder
      'com.samsung.knox', // Samsung Knox
      'com.samsung.android.sm', // Device Care
      'com.samsung.android.smartmirroring', // Smart View
      'com.samsung.android.app.dressroom', // Samsung Themes
      'com.samsung.android.themestore', // Galaxy Themes
      'com.samsung.android.app.clockpack', // Samsung Clock

      // Xiaomi/MIUI System Apps
      'com.miui.home', // MIUI Launcher
      'com.miui.securitycenter', // Security
      'com.miui.cleaner', // Cleaner
      'com.miui.calculator', // Calculator
      'com.miui.notes', // Notes
      'com.miui.compass', // Compass
      'com.miui.weather2', // Weather
      'com.miui.gallery', // Gallery
      'com.miui.camera', // Camera
      'com.miui.player', // Music
      'com.miui.videoplayer', // Video
      'com.miui.screenrecorder', // Screen Recorder
      'com.miui.fm', // FM Radio
      'com.miui.backup', // Mi Mover
      'com.miui.analytics', // Analytics
      'com.miui.powerkeeper', // Battery & Performance
      'com.miui.contentextension', // MIUI Content Extension
      'com.xiaomi.discover', // App Vault
      'com.xiaomi.scanner', // Mi Scanner
      'com.xiaomi.account', // Mi Account
      'com.xiaomi.payment', // Mi Pay
      'com.xiaomi.market', // Mi App Store
      'com.xiaomi.finddevice', // Find Device
      'com.xiaomi.glgm', // Games
      'com.xiaomi.mi_connect_service', // Mi Connect

      // Huawei/EMUI System Apps
      'com.huawei.android.launcher', // Huawei Launcher
      'com.huawei.systemmanager', // Phone Manager
      'com.huawei.camera', // Camera
      'com.huawei.gallery', // Gallery
      'com.huawei.music', // Music
      'com.huawei.video', // Video
      'com.huawei.compass', // Compass
      'com.huawei.calculator', // Calculator
      'com.huawei.notepad', // Notepad
      'com.huawei.weather', // Weather
      'com.huawei.appmarket', // AppGallery
      'com.huawei.health', // Huawei Health
      'com.huawei.wallet', // Huawei Wallet
      'com.huawei.browser', // Huawei Browser
      'com.huawei.backup', // Backup
      'com.huawei.scanner', // AI Lens
      'com.huawei.intelligent', // HiAssistant
      'com.huawei.findmyphone', // Find My Phone

      // OnePlus System Apps
      'net.oneplus.launcher', // OnePlus Launcher
      'com.oneplus.camera', // OnePlus Camera
      'com.oneplus.gallery', // OnePlus Gallery
      'com.oneplus.calculator', // OnePlus Calculator
      'com.oneplus.note', // OnePlus Notes
      'com.oneplus.weather', // OnePlus Weather
      'com.oneplus.filemanager', // OnePlus File Manager
      'com.oneplus.soundrecorder', // OnePlus Sound Recorder
      'com.oneplus.security', // OnePlus Security
      'com.oneplus.gamespace', // OnePlus Game Space

      // OPPO/ColorOS System Apps
      'com.oppo.launcher', // OPPO Launcher
      'com.oppo.camera', // OPPO Camera
      'com.oppo.gallery3d', // OPPO Gallery
      'com.oppo.music', // OPPO Music
      'com.oppo.video', // OPPO Video
      'com.oppo.calculator', // OPPO Calculator
      'com.oppo.note', // OPPO Notes
      'com.oppo.weather', // OPPO Weather
      'com.oppo.market', // OPPO App Market
      'com.oppo.safe', // Phone Manager
      'com.oppo.gamecenter', // Game Center

      // Vivo/FuntouchOS System Apps
      'com.vivo.launcher', // Vivo Launcher
      'com.vivo.camera', // Vivo Camera
      'com.vivo.gallery', // Vivo Gallery
      'com.vivo.music', // Vivo Music
      'com.vivo.video', // Vivo Video
      'com.vivo.calculator', // Vivo Calculator
      'com.vivo.notes', // Vivo Notes
      'com.vivo.weather', // Vivo Weather
      'com.vivo.appstore', // Vivo App Store
      'com.vivo.safecenter', // iManager
      'com.vivo.gamecenter', // Game Center

      // Qualcomm System Components
      'com.qualcomm.qcrilmsgtunnel',
      'com.qualcomm.qti.workloadclassifier',
      'com.qualcomm.qti.telephonyservice',
      'com.qualcomm.timeservice',
      'com.qualcomm.location',
      'com.qualcomm.embms',

      // MediaTek System Components
      'com.mediatek.bluetooth',
      'com.mediatek.camera',
      'com.mediatek.voicecommand',
      'com.mediatek.ims',
      'com.mediatek.location',

      // Common Carrier Apps
      'com.android.stk', // SIM Toolkit
      'com.android.phone', // Phone Services
      'com.android.cellbroadcastreceiver', // Emergency Alerts
    ];

    // Check exact package name matches
    if (systemPackages.contains(packageName)) {
      return true;
    }

    // Check package name patterns
    if (packageName.startsWith('com.android.') ||
        packageName.startsWith('com.google.android.') ||
        packageName.startsWith('android.') ||
        packageName.startsWith('com.samsung.android.') ||
        packageName.startsWith('com.sec.android.') ||
        packageName.startsWith('com.miui.') ||
        packageName.startsWith('com.xiaomi.') ||
        packageName.startsWith('com.huawei.') ||
        packageName.startsWith('com.oneplus.') ||
        packageName.startsWith('com.oppo.') ||
        packageName.startsWith('com.vivo.') ||
        packageName.startsWith('com.qualcomm.') ||
        packageName.startsWith('com.mediatek.') ||
        packageName.startsWith('com.qti.') ||
        packageName.startsWith('vendor.') ||
        packageName.startsWith('org.codeaurora.') ||
        packageName.contains('.systemui') ||
        packageName.contains('.settings') ||
        packageName.contains('.launcher')) {
      return true;
    }

    // Check app name patterns for system apps
    final lowerAppName = appName.toLowerCase();
    final systemAppNames = [
      'chrome',
      'youtube',
      'google',
      'gmail',
      'maps',
      'photos',
      'drive',
      'docs',
      'sheets',
      'slides',
      'keep',
      'translate',
      'calendar',
      'contacts',
      'phone',
      'messages',
      'camera',
      'gallery',
      'music',
      'video',
      'calculator',
      'clock',
      'weather',
      'notes',
      'memo',
      'settings',
      'launcher',
      'keyboard',
      'android',
      'samsung',
      'bixby',
      'miui',
      'xiaomi',
      'huawei',
      'oneplus',
      'oppo',
      'vivo',
      'system',
      'framework',
      'service',
      'provider',
      'setup',
      'security',
      'safe',
      'cleaner',
      'manager',
      'assistant',
      'health',
      'fitness',
      'wellbeing',
      'accessibility',
      'bluetooth',
      'wifi',
      'nfc',
      'location',
      'backup',
      'restore',
      'update',
      'store',
      'market',
      'play store',
      'app store',
      'themes',
      'wallpaper',
      'sound',
      'audio',
      'media',
      'radio',
      'fm',
      'scanner',
      'compass',
      'flashlight',
      'recorder',
      'voice',
      'speech',
      'print',
      'download',
      'file',
      'document',
      'emergency',
      'sos',
      'find',
      'locate',
      'tracker',
      'analytics',
      'telemetry',
      'diagnostics'
    ];

    for (String systemName in systemAppNames) {
      if (lowerAppName.contains(systemName)) {
        return true;
      }
    }

    return false;
  }

  void _filterApps(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredInstalledApps = installedApps;
        filteredSystemApps = systemApps;
      } else {
        filteredInstalledApps = installedApps
            .where(
              (app) =>
                  app.name.toLowerCase().contains(query.toLowerCase()) ||
                  app.packageName.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
            )
            .toList();
        filteredSystemApps = systemApps
            .where(
              (app) =>
                  app.name.toLowerCase().contains(query.toLowerCase()) ||
                  app.packageName.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: accentTeal,
            size: context.responsiveIconSize(24),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'App Filter',
          style: context.responsiveTextStyle(
            fontSize: (MediaQuery.of(context).size.width * 0.07).clamp(22.0, 32.0), // Much bigger and flexible
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        // Removed manual reload button
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(context.responsiveHeight(55)),
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: context.responsiveSpacing(16),
              vertical: context.responsiveSpacing(8),
            ),
            decoration: BoxDecoration(
              color: darkBg,
              borderRadius: BorderRadius.circular(
                context.responsiveBorderRadius(25),
              ),
              border: Border.all(
                color: lightPurple.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPurple, accentTeal],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(
                  context.responsiveBorderRadius(25),
                ),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: lightPurple,
              labelStyle: context.responsiveTextStyle(
                fontSize: (MediaQuery.of(context).size.width * 0.055).clamp(16.0, 22.0), // Bigger and flexible
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: context.responsiveTextStyle(
                fontSize: (MediaQuery.of(context).size.width * 0.045).clamp(14.0, 18.0), // Bigger and flexible
                fontWeight: FontWeight.w500,
              ),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.apps, size: context.responsiveIconSize(20)),
                      SizedBox(width: context.responsiveSpacing(6)),
                      Flexible(
                        child: Text(
                          'INSTALLED',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.android, size: context.responsiveIconSize(20)),
                      SizedBox(width: context.responsiveSpacing(6)),
                      Flexible(
                        child: Text('SYSTEM', overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? _buildLoadingWidget()
          : errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : CustomRefreshIndicator(
                  onRefresh: _loadApps,
                  builder: (context, child, controller) {
                    final value = controller.value;
                    final offsetY = value * 70.0;
                    // Only slide the app content down, no animation
                    return Transform.translate(
                      offset: Offset(0, offsetY),
                      child: child,
                    );
                  },
                  child: Builder(
                    builder: (context) {
                      return CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                // Search Bar
                                Container(
                                  margin: EdgeInsets.all(context.responsiveSpacing(16)),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(
                                      context.responsiveBorderRadius(20),
                                    ),
                                    border: Border.all(
                                      color: lightPurple.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: searchController,
                                    onChanged: _filterApps,
                                    style: context.responsiveTextStyle(
                                      fontSize: (MediaQuery.of(context).size.width * 0.055).clamp(18.0, 32.0), // Even bigger and more readable
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search apps...',
                                      hintStyle: context.responsiveTextStyle(
                                        fontSize: (MediaQuery.of(context).size.width * 0.055).clamp(18.0, 32.0), // Even bigger and more readable
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: accentTeal,
                                        size: context.responsiveIconSize(24),
                                      ),
                                      suffixIcon: searchQuery.isNotEmpty
                                          ? IconButton(
                                              icon: Icon(
                                                Icons.clear,
                                                color: lightPurple,
                                                size: context.responsiveIconSize(24),
                                              ),
                                              onPressed: () {
                                                searchController.clear();
                                                _filterApps('');
                                              },
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: context.responsiveSpacing(16),
                                        vertical: context.responsiveSpacing(14),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SliverFillRemaining(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildAppList(
                                  filteredInstalledApps,
                                  'No installed apps found',
                                ),
                                _buildAppList(
                                  filteredSystemApps,
                                  'No system apps found',
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildLoadingWidget() {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Ultra-aggressive responsive sizing for small screens
    final isUltraTinyScreen = screenWidth < 280;
    final isVerySmallScreen = screenWidth < 320;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 600;

    // Loading spinner size - ultra-compact for tiny screens
    final loadingIconSize = isUltraTinyScreen
        ? (screenWidth * 0.12).clamp(35.0, 45.0)
        : isVerySmallScreen
            ? (screenWidth * 0.13).clamp(40.0, 50.0)
            : isSmallScreen
                ? (screenWidth * 0.14).clamp(45.0, 55.0)
                : isMediumScreen
                    ? (screenWidth * 0.15).clamp(50.0, 70.0)
                    : (screenWidth * 0.15).clamp(60.0, 80.0);

    // Text sizes that scale appropriately for very small screens
    final titleFontSize = isUltraTinyScreen
        ? 12.0
        : isVerySmallScreen
            ? 14.0
            : isSmallScreen
                ? 16.0
                : isMediumScreen
                    ? 18.0
                    : 20.0;

    final subtitleFontSize = isUltraTinyScreen
        ? 10.0
        : isVerySmallScreen
            ? 11.0
            : isSmallScreen
                ? 12.0
                : isMediumScreen
                    ? 14.0
                    : 16.0;

    // Compact padding for small screens
    final containerPadding = isUltraTinyScreen
        ? 8.0
        : isVerySmallScreen
            ? 10.0
            : isSmallScreen
                ? 12.0
                : isMediumScreen
                    ? 16.0
                    : 20.0;

    // Stroke width that's visible on small screens
    final strokeWidth = isUltraTinyScreen
        ? 2.0
        : isVerySmallScreen
            ? 2.5
            : 3.0;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.6,
            maxWidth: screenWidth * 0.9,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(containerPadding),
                margin: EdgeInsets.symmetric(horizontal: containerPadding),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(
                    isUltraTinyScreen
                        ? 12
                        : isVerySmallScreen
                            ? 15
                            : 20,
                  ),
                  border: Border.all(
                    color: accentTeal.withOpacity(0.3),
                    width: isUltraTinyScreen ? 1 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentTeal.withOpacity(0.2),
                      blurRadius: isUltraTinyScreen ? 10 : 20,
                      spreadRadius: isUltraTinyScreen ? 2 : 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: loadingIconSize,
                      height: loadingIconSize,
                      child: CircularProgressIndicator(
                        strokeWidth: strokeWidth,
                        valueColor: AlwaysStoppedAnimation<Color>(accentTeal),
                      ),
                    ),
                    SizedBox(height: containerPadding * 0.6),
                    Text(
                      'Loading Apps...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: containerPadding * 0.3),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isUltraTinyScreen ? 4.0 : 8.0,
                      ),
                      child: Text(
                        'Please wait while we fetch your apps',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: subtitleFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Ultra-aggressive responsive sizing for small screens
    final isUltraTinyScreen = screenWidth < 280;
    final isVerySmallScreen = screenWidth < 320;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 600;

    // Error icon size that's always visible and proportional
    final iconSize = isUltraTinyScreen
        ? (screenWidth * 0.1).clamp(35.0, 45.0)
        : isVerySmallScreen
            ? (screenWidth * 0.11).clamp(40.0, 50.0)
            : isSmallScreen
                ? (screenWidth * 0.12).clamp(45.0, 55.0)
                : isMediumScreen
                    ? (screenWidth * 0.12).clamp(50.0, 70.0)
                    : (screenWidth * 0.12).clamp(60.0, 80.0);

    // Text sizes that scale appropriately for very small screens
    final titleFontSize = isUltraTinyScreen
        ? 12.0
        : isVerySmallScreen
            ? 14.0
            : isSmallScreen
                ? 16.0
                : isMediumScreen
                    ? 18.0
                    : 22.0;

    final textFontSize = isUltraTinyScreen
        ? 10.0
        : isVerySmallScreen
            ? 11.0
            : isSmallScreen
                ? 12.0
                : isMediumScreen
                    ? 14.0
                    : 16.0;

    final buttonFontSize = isUltraTinyScreen
        ? 11.0
        : isVerySmallScreen
            ? 12.0
            : isSmallScreen
                ? 14.0
                : isMediumScreen
                    ? 16.0
                    : 18.0;

    // Compact padding and margins for small screens
    final containerPadding = isUltraTinyScreen
        ? 8.0
        : isVerySmallScreen
            ? 10.0
            : isSmallScreen
                ? 12.0
                : isMediumScreen
                    ? 16.0
                    : 20.0;

    final containerMargin = isUltraTinyScreen
        ? 8.0
        : isVerySmallScreen
            ? 10.0
            : isSmallScreen
                ? 12.0
                : isMediumScreen
                    ? 16.0
                    : 20.0;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.8,
            maxWidth: screenWidth * 0.9,
          ),
          margin: EdgeInsets.all(containerMargin),
          padding: EdgeInsets.all(containerPadding),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(
              isUltraTinyScreen
                  ? 12
                  : isVerySmallScreen
                      ? 15
                      : 20,
            ),
            border: Border.all(
              color: Colors.redAccent.withOpacity(0.3),
              width: isUltraTinyScreen ? 1 : 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: iconSize,
              ),
              SizedBox(height: containerPadding * 0.6),
              Text(
                'Oops! Something went wrong',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: containerPadding * 0.4),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isUltraTinyScreen ? 4.0 : 8.0,
                ),
                child: Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  maxLines: isUltraTinyScreen ? 4 : 6,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: textFontSize,
                  ),
                ),
              ),
              SizedBox(height: containerPadding * 0.8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentTeal,
                    foregroundColor: darkBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        isUltraTinyScreen
                            ? 10
                            : isVerySmallScreen
                                ? 12
                                : 15,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: containerPadding * 0.8,
                      vertical: isUltraTinyScreen
                          ? 8
                          : isVerySmallScreen
                              ? 10
                              : isSmallScreen
                                  ? 12
                                  : 15,
                    ),
                  ),
                  onPressed: _loadApps,
                  child: Text(
                    'Try Again',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: buttonFontSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppList(List<AppInfo> apps, String emptyMessage) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final isUltraTinyScreen = screenWidth < 280;
    final isVerySmallScreen = screenWidth < 320;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 600;

    // Ultra-compact sizing for very small screens
    final emptyIconSize = isUltraTinyScreen
        ? (screenWidth * 0.1).clamp(35.0, 45.0)
        : isVerySmallScreen
            ? (screenWidth * 0.11).clamp(40.0, 50.0)
            : isSmallScreen
                ? (screenWidth * 0.12).clamp(45.0, 55.0)
                : isMediumScreen
                    ? (screenWidth * 0.12).clamp(50.0, 70.0)
                    : (screenWidth * 0.12).clamp(60.0, 80.0);

    final emptyTextSize = isUltraTinyScreen
        ? 11.0
        : isVerySmallScreen
            ? 12.0
            : isSmallScreen
                ? 14.0
                : isMediumScreen
                    ? 16.0
                    : 20.0;

    // List padding that adapts to ultra-small screens
    final listPadding = isUltraTinyScreen
        ? 6.0
        : isVerySmallScreen
            ? 8.0
            : isSmallScreen
                ? 10.0
                : (screenWidth * 0.03).clamp(12.0, 24.0);

    if (apps.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.5,
              maxWidth: screenWidth * 0.8,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.apps_outlined,
                  color: lightPurple,
                  size: emptyIconSize,
                ),
                SizedBox(height: listPadding * (isUltraTinyScreen ? 0.8 : 1.0)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: listPadding * 1.5),
                  child: Text(
                    emptyMessage,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: emptyTextSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(listPadding),
      itemCount: apps.length,
      physics: const BouncingScrollPhysics(), // Smoother scrolling
      itemBuilder: (context, index) {
        final app = apps[index];
        return _buildAppCard(app, screenWidth, screenHeight);
      },
    );
  }

  Widget _buildAppCard(AppInfo app, double screenWidth, double screenHeight) {
    final isUltraTinyScreen = screenWidth < 280;
    final isVerySmallScreen = screenWidth < 320;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 600;

    // App icon size that's always tappable and visible on ultra-small screens
    final iconSize = isUltraTinyScreen
        ? (screenWidth * 0.08).clamp(30.0, 40.0)
        : isVerySmallScreen
            ? (screenWidth * 0.09).clamp(35.0, 45.0)
            : isSmallScreen
                ? (screenWidth * 0.1).clamp(40.0, 50.0)
                : isMediumScreen
                    ? (screenWidth * 0.11).clamp(45.0, 60.0)
                    : (screenWidth * 0.12).clamp(50.0, 70.0);

    // Text sizes that scale properly for ultra-small screens
    final titleFontSize = isUltraTinyScreen
        ? 11.0
        : isVerySmallScreen
            ? 12.0
            : isSmallScreen
                ? 14.0
                : isMediumScreen
                    ? 16.0
                    : 18.0;

    final packageFontSize = isUltraTinyScreen
        ? 8.0
        : isVerySmallScreen
            ? 9.0
            : isSmallScreen
                ? 10.0
                : isMediumScreen
                    ? 12.0
                    : 14.0;

    final tagFontSize = isUltraTinyScreen
        ? 7.0
        : isVerySmallScreen
            ? 8.0
            : isSmallScreen
                ? 9.0
                : isMediumScreen
                    ? 10.0
                    : 12.0;

    final buttonFontSize = isUltraTinyScreen
        ? 8.0
        : isVerySmallScreen
            ? 9.0
            : isSmallScreen
                ? 10.0
                : isMediumScreen
                    ? 12.0
                    : 14.0;

    // Ultra-compact spacing and padding for small screens
    final cardMargin = isUltraTinyScreen
        ? 4.0
        : isVerySmallScreen
            ? 6.0
            : isSmallScreen
                ? 8.0
                : (screenWidth * 0.02).clamp(8.0, 16.0);

    final horizontalPadding = isUltraTinyScreen
        ? 6.0
        : isVerySmallScreen
            ? 8.0
            : isSmallScreen
                ? 10.0
                : (screenWidth * 0.03).clamp(12.0, 24.0);

    final verticalPadding = isUltraTinyScreen
        ? 4.0
        : isVerySmallScreen
            ? 5.0
            : isSmallScreen
                ? 6.0
                : (screenWidth * 0.015).clamp(6.0, 12.0);

    final borderRadius = isUltraTinyScreen
        ? 8.0
        : isVerySmallScreen
            ? 10.0
            : isSmallScreen
                ? 12.0
                : 16.0;

    return Container(
      margin: EdgeInsets.only(bottom: cardMargin),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: lightPurple.withOpacity(0.2),
          width: isUltraTinyScreen ? 0.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.1),
            blurRadius: isUltraTinyScreen ? 4 : 8,
            spreadRadius: isUltraTinyScreen ? 0.5 : 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        dense: isUltraTinyScreen || isVerySmallScreen,
        contentPadding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        leading: Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              isUltraTinyScreen
                  ? 6
                  : isVerySmallScreen
                      ? 8
                      : 12,
            ),
            border: Border.all(
              color: accentTeal.withOpacity(0.3),
              width: isUltraTinyScreen ? 0.5 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              isUltraTinyScreen
                  ? 6
                  : isVerySmallScreen
                      ? 8
                      : 12,
            ),
            child: _buildAppIcon(app),
          ),
        ),
        title: Text(
          app.name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: titleFontSize,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isUltraTinyScreen)
              Text(
                app.packageName,
                style: TextStyle(
                  color: lightPurple.withOpacity(0.8),
                  fontSize: packageFontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (!isUltraTinyScreen) SizedBox(height: isVerySmallScreen ? 1 : 2),
            Text(
              _isSystemApp(app.packageName, app.name)
                  ? 'System App'
                  : 'User App',
              style: TextStyle(
                color: _isSystemApp(app.packageName, app.name)
                    ? Colors.orange.withOpacity(0.8)
                    : accentTeal.withOpacity(0.8),
                fontSize: tagFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Switch(
          value: appFilterStates[app.packageName] ?? false,
          onChanged: (val) {
            setState(() {
              appFilterStates[app.packageName] = val;
            });
            // TODO: Add logic to enable/disable VPN filtering for this app
          },
          activeColor: accentTeal,
          inactiveThumbColor: Colors.grey[400],
          inactiveTrackColor: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildAppIcon(AppInfo app) {
    if (app.icon != null) {
      try {
        return Image.memory(
          app.icon!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultIcon();
          },
        );
      } catch (e) {
        return _buildDefaultIcon();
      }
    } else {
      return _buildDefaultIcon();
    }
  }

  Widget _buildDefaultIcon() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryPurple, accentTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.android, color: Colors.white, size: 24),
    );
  }


  // AGGRESSIVE Chrome detection - captures all Chrome variants from physical device
  bool _isChromeApp(String appNameLower, String packageNameLower) {
    return (appNameLower.contains('chrome') &&
            !appNameLower.contains('chromium')) ||
        packageNameLower == 'com.android.chrome' ||
        packageNameLower == 'com.chrome.beta' ||
        packageNameLower == 'com.chrome.dev' ||
        packageNameLower == 'com.chrome.canary' ||
        packageNameLower.startsWith('com.google.android.apps.chrome') ||
        (packageNameLower.contains('chrome') &&
            !packageNameLower.contains('chromium') &&
            packageNameLower.contains('google'));
  }

  // AGGRESSIVE Google app detection - captures main Google app from physical device
  bool _isGoogleApp(String appNameLower, String packageNameLower) {
    return (appNameLower == 'google' ||
            appNameLower == 'google app' ||
            appNameLower == 'search' ||
            appNameLower.contains('google search') ||
            (appNameLower.contains('google') &&
                appNameLower.contains('search'))) ||
        packageNameLower == 'com.google.android.googlequicksearchbox' ||
        packageNameLower == 'com.google.android.apps.searchlite' ||
        packageNameLower.startsWith('com.google.android.apps.gsa');
  }

  // AGGRESSIVE YouTube detection - captures all YouTube variants from physical device
  bool _isYouTubeApp(String appNameLower, String packageNameLower) {
    return (appNameLower.contains('youtube')) ||
        packageNameLower == 'com.google.android.youtube' ||
        packageNameLower == 'com.google.android.apps.youtube.music' ||
        packageNameLower == 'com.google.android.apps.youtube.kids' ||
        packageNameLower.startsWith('com.google.android.youtube');
  }
 }