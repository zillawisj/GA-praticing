import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:ecommerce_app/src/utils/app_screen_enum.dart';

class ScreenAnalyticsManager {
  static final ScreenAnalyticsManager _instance = ScreenAnalyticsManager._internal();
  factory ScreenAnalyticsManager() => _instance;

  ScreenAnalyticsManager._internal();

  AppScreen? _currentScreen;
  AppScreen? _previousScreen;
  DateTime? _entryTime;

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Call this when a new screen becomes visible
  void trackScreen(AppScreen screen) {
    final now = DateTime.now();

    if (_currentScreen == screen) return;

    // Log duration for current screen before transition
    if (_currentScreen != null && _entryTime != null) {
      final duration = now.difference(_entryTime!);
      _analytics.logEvent(
        name: 'screen_duration',
        parameters: {
          'screen_name': _currentScreen!.screenName,
          'duration_seconds': duration.inSeconds,
        },
      );

      _analytics.logEvent(
        name: 'screen_transition',
        parameters: {
          'from_screen': _currentScreen!.screenName,
          'to_screen': screen.screenName,
          'timestamp': now.toIso8601String(),
        },
      );
    }

    // Update internal state
    _previousScreen = _currentScreen;
    _currentScreen = screen;
    _entryTime = now;

    // Log standard screen_view event
    _analytics.logScreenView(screenName: screen.screenName);
  }

  /// Optionally call this when app is paused, backgrounded, or killed
  void endCurrentScreenSession() {
    if (_currentScreen != null && _entryTime != null) {
      final duration = DateTime.now().difference(_entryTime!);
      _analytics.logEvent(
        name: 'screen_duration',
        parameters: {
          'screen_name': _currentScreen!.screenName,
          'duration_seconds': duration.inSeconds,
        },
      );
    }
  }

  /// For testing or logging
  // AppScreen? get currentScreen => _currentScreen;
  // AppScreen? get previousScreen => _previousScreen;
}
