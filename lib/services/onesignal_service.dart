import 'package:falcim_benim/utils/logger.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();

  factory OneSignalService() {
    return _instance;
  }

  OneSignalService._internal();

  /// Get OneSignal subscription state
  Future<void> getSubscriptionState() async {
    try {
      final state = await OneSignal.User.getOnesignalId();
      Logger.info('OneSignal User ID: $state');
    } catch (e) {
      Logger.error('Failed to get subscription state: $e');
    }
  }

  /// Set user external ID (useful to link with Firebase UID)
  Future<void> setExternalUserId(String userId) async {
    try {
      // Wait for OneSignal SDK to fully initialize and register device
      // This ensures the device is subscribed before we set the external ID
      await Future.delayed(const Duration(seconds: 2));

      OneSignal.User.addAlias('firebase_uid', userId);
      Logger.info('✅ OneSignal external ID set: $userId');

      // Also add user tags for easier segmentation
      OneSignal.User.addTags({'user_id': userId});
      Logger.debug('OneSignal user tags added: $userId');
    } catch (e) {
      Logger.error('Failed to set external ID: $e');
    }
  }

  /// Remove external user ID
  Future<void> removeExternalUserId() async {
    try {
      OneSignal.User.removeAlias('firebase_uid');
      Logger.info('OneSignal external ID removed');
    } catch (e) {
      Logger.error('Failed to remove external ID: $e');
    }
  }

  /// Add user tags for targeting
  Future<void> addUserTags(Map<String, dynamic> tags) async {
    try {
      OneSignal.User.addTags(tags);
      Logger.info('OneSignal tags added: $tags');
    } catch (e) {
      Logger.error('Failed to add tags: $e');
    }
  }

  /// Remove user tags
  Future<void> removeUserTags(List<String> tags) async {
    try {
      OneSignal.User.removeTags(tags);
      Logger.info('OneSignal tags removed: $tags');
    } catch (e) {
      Logger.error('Failed to remove tags: $e');
    }
  }

  /// Get OneSignal push subscription state
  Future<bool> isPushSubscribed() async {
    try {
      final state = OneSignal.User.pushSubscription.optedIn;
      Logger.info('Push subscription state: $state');
      return state ?? false;
    } catch (e) {
      Logger.error('Failed to get push subscription state: $e');
      return false;
    }
  }

  /// Opt in to push notifications
  Future<void> optInPushNotifications() async {
    try {
      OneSignal.User.pushSubscription.optIn();
      Logger.info('User opted in to push notifications');
    } catch (e) {
      Logger.error('Failed to opt in: $e');
    }
  }

  /// Opt out of push notifications
  Future<void> optOutPushNotifications() async {
    try {
      OneSignal.User.pushSubscription.optOut();
      Logger.info('User opted out of push notifications');
    } catch (e) {
      Logger.error('Failed to opt out: $e');
    }
  }

  /// Schedule delayed notification via backend API
  /// The backend will use OneSignal REST API to schedule the push
  Future<void> scheduleDelayedNotification({
    required String userId,
    required String title,
    required String message,
    int delaySeconds = 300, // 5 minutes default
  }) async {
    try {
      Logger.info('📡 Scheduling delayed notification via backend API');

      // Backend API endpoint
      const String apiUrl =
          'https://omerfarukcelenk.com/api/schedule-notification.php';

      Logger.debug('Request URL: $apiUrl');
      Logger.debug('User ID: $userId');
      Logger.debug('Delay: ${delaySeconds}s');

      final headers = {'Content-Type': 'application/json'};

      final body = {
        'user_id': userId,
        'delay_seconds': delaySeconds,
        'title': title,
        'message': message,
      };

      final response = await http
          .post(Uri.parse(apiUrl), headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        Logger.success(
          '✅ Notification scheduled via backend! Send after: ${responseData['send_after']}',
        );
        Logger.info(
          'Notification ID: ${responseData['notification_id'] ?? 'N/A'}',
        );
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Backend API error: ${response.statusCode} - ${errorBody['error'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      Logger.error('❌ Error scheduling delayed notification: $e');
      rethrow;
    }
  }
}
