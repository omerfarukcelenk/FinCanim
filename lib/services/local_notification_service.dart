import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:falcim_benim/utils/logger.dart';
import 'package:falcim_benim/utils/toast_helper.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();

  factory LocalNotificationService() {
    return _instance;
  }

  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize local notifications
  Future<void> init() async {
    if (_initialized) {
      Logger.info('Local notifications already initialized, skipping...');
      return;
    }

    try {
      Logger.info('🔧 Initializing local notification service...');
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
          );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationTapped,
      );
      _initialized = true;
      Logger.success('✅ Local notification service initialized successfully');
    } catch (e) {
      Logger.error('❌ Failed to initialize local notifications: $e');
      // Gracefully fail - don't block app startup
      _initialized = true; // Mark as attempted so we don't retry
    }
  }

  /// Handle local notification tap
  void _handleNotificationTapped(NotificationResponse response) {
    try {
      final payload = response.payload;
      Logger.info('Local notification tapped with payload: $payload');

      if (payload == 'fortune:detail') {
        // Get the last reading index (0 = most recent)
        _navigateToFortuneDetail(0);
      }
    } catch (e) {
      Logger.error('Error handling notification tap: $e');
    }
  }

  /// Navigate to fortune detail
  void _navigateToFortuneDetail(int index) {
    try {
      Logger.info('Attempting to navigate to detail screen with index: $index');
      final navigator = ToastHelper.navigatorKey.currentState;
      if (navigator != null) {
        // Use pushNamed with route parameter format
        navigator.pushNamed('/detail', arguments: {'index': index});
        Logger.info('✅ Navigated to detail with index: $index');
      } else {
        Logger.error('Navigator is null, cannot navigate to detail');
      }
    } catch (e) {
      Logger.error('Failed to navigate to detail: $e');
    }
  }

  /// Schedule a fortune ready notification after 5 minutes (300 seconds)
  Future<void> scheduleFortuneReadyNotification({
    required String fortuneId,
    int delaySeconds = 300, // 5 minutes
  }) async {
    try {
      // Only proceed if plugin is available
      if (!_initialized) {
        Logger.info('Initializing local notifications before scheduling...');
        await init();
      }

      Logger.info('Starting notification schedule for fortuneId: $fortuneId');

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'fortune_channel',
            'Fortune Notifications',
            channelDescription: 'Notifications for fortune readings',
            importance: Importance.high,
            priority: Priority.high,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule notification for 5 minutes later using UTC timezone
      final utcNow = tz.TZDateTime.now(tz.UTC);
      final scheduledTime = utcNow.add(Duration(seconds: delaySeconds));

      Logger.info(
        'Scheduling notification for: $scheduledTime (delay: ${delaySeconds}s)',
      );

      await _notificationsPlugin.zonedSchedule(
        fortuneId.hashCode, // Unique notification ID
        'Falınız Hazır! ✨',
        'Kahve falınız bekliyorsunuz. Hemen kontrol edin!',
        scheduledTime,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'fortune:detail',
      );

      Logger.success(
        '✅ Notification scheduled successfully for: $scheduledTime',
      );
    } catch (e) {
      Logger.error('❌ Failed to schedule fortune notification: $e');
      rethrow; // Re-throw so caller knows there was an error
    }
  }
}
