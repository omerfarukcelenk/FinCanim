/**
 * OneSignal Configuration Guide for Flutter
 * 
 * Steps to complete the setup:
 * 
 * 1. Create OneSignal Account:
 *    - Go to https://onesignal.com
 *    - Sign up for free account
 *    - Create a new app
 * 
 * 2. Get Your App ID:
 *    - In OneSignal dashboard, navigate to Settings > Keys & IDs
 *    - Copy your ONE_SIGNAL_APP_ID
 *    - Replace 'YOUR_ONESIGNAL_APP_ID' in lib/main.dart with this ID
 * 
 * 3. Android Setup:
 *    - In OneSignal dashboard, go to Platforms > Android
 *    - Download Google Services JSON file
 *    - Place it at: android/app/google-services.json
 *    - This was already configured for Firebase, OneSignal uses the same setup
 * 
 * 4. iOS Setup:
 *    - In OneSignal dashboard, go to Platforms > iOS
 *    - Follow the certificate upload instructions
 *    - No additional code changes needed - already configured
 * 
 * 5. Update your OneSignal App ID in main.dart:
 *    File: lib/main.dart
 *    Line: const String oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID';
 *    Replace with your actual OneSignal App ID
 * 
 * Usage Examples:
 * 
 * // Get OneSignal service instance
 * final oneSignalService = OneSignalService();
 * 
 * // Add user tags for targeting
 * await oneSignalService.addUserTags({
 *   'fortune_count': 5,
 *   'premium_user': true,
 *   'language': 'tr',
 * });
 * 
 * // Opt in/out of push notifications
 * await oneSignalService.optInPushNotifications();
 * await oneSignalService.optOutPushNotifications();
 * 
 * // Check if user is subscribed
 * bool isSubscribed = await oneSignalService.isPushSubscribed();
 * 
 * // Remove tags
 * await oneSignalService.removeUserTags(['tag1', 'tag2']);
 * 
 * Features Included:
 * 
 * ✓ Automatic external user ID linking with Firebase UID
 * ✓ Foreground notification display
 * ✓ Click listener for notification actions
 * ✓ User tagging for segmentation
 * ✓ Push subscription management
 * ✓ Debug logging support
 * 
 * Next Steps:
 * 
 * 1. Complete the OneSignal configuration steps above
 * 2. Run: flutter pub get
 * 3. Run: flutter run
 * 4. Test notification sending from OneSignal dashboard
 * 5. Monitor logs in VS Code debug console
 * 
 * Troubleshooting:
 * 
 * - If notifications don't appear, check:
 *   1. OneSignal App ID is correct in main.dart
 *   2. Android: google-services.json is in correct location
 *   3. iOS: Push certificates are properly configured
 *   4. User has granted notification permission
 *   5. Check debug logs for "OneSignal initialized successfully"
 * 
 * - For Android specific issues:
 *   - Check Android permissions in AndroidManifest.xml
 *   - Verify Android build.gradle has correct setup
 * 
 * - For iOS specific issues:
 *   - Verify push capability is enabled in Xcode
 *   - Check iOS push certificate configuration in OneSignal
 */
