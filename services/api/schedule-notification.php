<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Log setup
ini_set('display_errors', 1);
ini_set('log_errors', 1);
error_reporting(E_ALL);
date_default_timezone_set('Europe/Istanbul');

$logFile = __DIR__ . '/onesignal.log';

function logMessage($message)
{
    global $logFile;
    $timestamp = date('Y-m-d H:i:s');
    $logEntry = "[$timestamp] $message\n";
    error_log($logEntry, 3, $logFile);
    error_log($logEntry);
}

// OneSignal Config
$ONESIGNAL_APP_ID = '';
$ONESIGNAL_REST_API_KEY = '';
$ONESIGNAL_API_URL = 'https://onesignal.com/api/v1/notifications';

logMessage("=== SCHEDULE NOTIFICATION REQUEST ===");

try {
    // Get POST data (JSON or form)
    $input = file_get_contents('php://input');
    $data = json_decode($input, true) ?? $_POST;

    $userId = $data['user_id'] ?? null;
    $title = $data['title'] ?? 'Falınız Hazır! ✨';
    $message = $data['message'] ?? 'Kahve falınız bekliyorsunuz. Hemen kontrol edin!';
    $delaySeconds = intval($data['delay_seconds'] ?? 300);

    logMessage("User ID: $userId, Title: $title, Delay: ${delaySeconds}s");

    if (!$userId) {
        logMessage("ERROR: user_id required");
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'user_id required'
        ]);
        exit;
    }

    // Calculate send_after time (UTC)
    $sendAt = new DateTime('now', new DateTimeZone('UTC'));
    $sendAt->modify("+$delaySeconds seconds");
    $sendAfter = $sendAt->format('Y-m-d\TH:i:s\Z');

    logMessage("Scheduled send_after: $sendAfter (UTC)");

    // Build OneSignal request - use tag-based targeting for specific user
    $notificationData = [
        'app_id' => $ONESIGNAL_APP_ID,
        'filters' => [
            [
                'field' => 'tag',
                'key' => 'user_id',
                'value' => $userId
            ]
        ],
        'contents' => [
            'en' => $message,
            'tr' => $message
        ],
        'headings' => [
            'en' => $title,
            'tr' => $title
        ],
        'send_after' => $sendAfter,
        // Android-specific
        'priority' => 10,
        'ttl' => 86400,  // 24 hours
        // Web notification
        'chrome_web_notification' => [
            'title' => $title,
            'message' => $message,
            'icon' => 'https://example.com/icon.png'
        ],
        // Custom data
        'data' => [
            'type' => 'fortune_ready',
            'user_id' => $userId,
            'action' => 'open_last_fortune',  // App will open latest fortune
            'scheduled_at' => date('Y-m-d H:i:s')
        ]
    ];

    logMessage("Request body: " . json_encode($notificationData));

    // Send to OneSignal
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $ONESIGNAL_API_URL);

    // Authorization header - OneSignal REST API format
    $authHeader = 'Authorization: ' . $ONESIGNAL_REST_API_KEY;
    logMessage("Auth header: " . substr($authHeader, 0, 30) . "...");

    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        $authHeader,
        'Content-Type: application/json; charset=utf-8'
    ]);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HEADER, false);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($notificationData));
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_TIMEOUT, 30);

    logMessage("Sending to OneSignal API...");
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $curlError = curl_error($ch);
    curl_close($ch);

    logMessage("OneSignal Response Code: $httpCode");
    logMessage("OneSignal Response: " . substr($response, 0, 500));

    if ($curlError) {
        logMessage("CURL Error: $curlError");
        throw new Exception("CURL Error: $curlError");
    }

    $responseData = json_decode($response, true);

    if ($httpCode === 200) {
        $notificationId = $responseData['body']['notification_id'] ?? $responseData['id'] ?? 'unknown';
        logMessage("✅ SUCCESS - Notification ID: $notificationId");

        http_response_code(200);
        echo json_encode([
            'success' => true,
            'notification_id' => $notificationId,
            'send_after' => $sendAfter,
            'message' => 'Notification scheduled successfully'
        ]);
    } else {
        $error = $responseData['errors'] ?? $responseData['error'] ?? 'Unknown error';
        logMessage("ERROR: HTTP $httpCode - " . json_encode($error));

        http_response_code($httpCode);
        echo json_encode([
            'success' => false,
            'http_code' => $httpCode,
            'error' => $error,
            'message' => 'OneSignal API error'
        ]);
    }
} catch (Exception $e) {
    logMessage("EXCEPTION: " . $e->getMessage());

    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Error: ' . $e->getMessage()
    ]);
}
?>
