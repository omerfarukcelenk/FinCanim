<?php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Error logging
ini_set('display_errors', 1);
ini_set('log_errors', 1);
error_reporting(E_ALL);
date_default_timezone_set('Europe/Istanbul');

// Log file
$logFile = __DIR__ . '/fortune.log';

function logMessage($message)
{
    global $logFile;
    $timestamp = date('Y-m-d H:i:s');
    $logEntry = "[$timestamp] $message\n";
    error_log($logEntry, 3, $logFile);
    error_log($logEntry); // Also to PHP error log
}

// ============== HANDLE STATUS REQUEST ==============
if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['action']) && $_GET['action'] === 'status') {
    $requestId = $_GET['request_id'] ?? null;
    
    if (!$requestId) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'request_id required']);
        exit;
    }
    
    logMessage("Status check for: $requestId");
    
    $QUEUE_STATUS_DIR = __DIR__ . '/queue_status/';
    $statusFile = $QUEUE_STATUS_DIR . $requestId . '.json';
    
    if (!file_exists($statusFile)) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'status' => 'not_found',
            'message' => 'Request not found'
        ]);
        exit;
    }
    
    $statusData = json_decode(file_get_contents($statusFile), true);
    
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'request_id' => $requestId,
        'status' => $statusData['status'] ?? 'unknown',
        'fortune' => $statusData['data']['fortune'] ?? null,
        'message' => $statusData['data']['message'] ?? ''
    ]);
    exit;
}

// ============== HANDLE QUEUE PROCESSING ==============
if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['action']) && $_GET['action'] === 'process_queue') {
    $QUEUE_DIR = __DIR__ . '/queue/';
    $QUEUE_INDEX_FILE = __DIR__ . '/queue_index.json';
    $QUEUE_STATUS_DIR = __DIR__ . '/queue_status/';
    $CACHE_DIR = __DIR__ . '/fortune_cache/';
    $DEVELOPMENT_MODE = true;
    $GEMINI_API_KEY = 'AIzaSyBHv8DNlGP-951mIfsTAiFK5C2CGEsxwx8';
    $GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent';
    $MAX_RETRIES = 3;
    $RETRY_DELAY = 5;
    
    logMessage("=== QUEUE PROCESSING START ===");
    
    if (!file_exists($QUEUE_INDEX_FILE)) {
        http_response_code(200);
        echo json_encode(['success' => true, 'message' => 'Queue empty', 'processed' => 0]);
        exit;
    }
    
    $queueIndex = json_decode(file_get_contents($QUEUE_INDEX_FILE), true);
    $queue = $queueIndex['queue'] ?? [];
    
    if (empty($queue)) {
        http_response_code(200);
        echo json_encode(['success' => true, 'message' => 'Queue empty', 'processed' => 0]);
        exit;
    }
    
    $processed = 0;
    
    // Process first item in queue
    $requestId = array_shift($queue);
    $queueFile = $QUEUE_DIR . $requestId . '.json';
    
    if (!file_exists($queueFile)) {
        logMessage("Queue file not found: $requestId");
        $queueIndex['queue'] = $queue;
        @file_put_contents($QUEUE_INDEX_FILE, json_encode($queueIndex, JSON_PRETTY_PRINT));
        http_response_code(200);
        echo json_encode(['success' => true, 'message' => 'Processed', 'processed' => 0]);
        exit;
    }
    
    $requestData = json_decode(file_get_contents($queueFile), true);
    logMessage("Processing request: $requestId");
    
    // Extract data
    $name = $requestData['name'] ?? '';
    $age = $requestData['age'] ?? 25;
    $gender = $requestData['gender'] ?? 'Belirtilmemiş';
    $maritalStatus = $requestData['marital_status'] ?? 'Belirtilmemiş';
    $cacheKey = $requestData['cache_key'] ?? '';
    $imageData = $requestData['image_data'] ?? [];
    
    // Check cache again (in case processed elsewhere)
    $cacheFile = $CACHE_DIR . $cacheKey . '.json';
    if (file_exists($cacheFile)) {
        logMessage("Cache hit during processing: $requestId");
        $cacheData = json_decode(file_get_contents($cacheFile), true);
        $fortune = $cacheData['fortune'] ?? '';
        
        // Save to status
        $statusFile = $QUEUE_STATUS_DIR . $requestId . '.json';
        @file_put_contents($statusFile, json_encode([
            'request_id' => $requestId,
            'status' => 'completed',
            'data' => ['fortune' => $fortune, 'message' => 'Falınız hazır!'],
            'timestamp' => time()
        ], JSON_PRETTY_PRINT));
        
        // Remove from queue
        $queueIndex['queue'] = $queue;
        @file_put_contents($QUEUE_INDEX_FILE, json_encode($queueIndex, JSON_PRETTY_PRINT));
        @unlink($queueFile);
        
        $processed = 1;
        logMessage("Queue processing complete - cache hit");
    } else {
        // Generate fortune
        logMessage("Generating fortune for: $requestId");
        
        if ($DEVELOPMENT_MODE) {
            logMessage("DEVELOPMENT MODE - Using mock");
            $fortune = getMockFortune($name, $age, $gender, $maritalStatus);
        } else {
            logMessage("PRODUCTION MODE - Calling Gemini");
            // sendToGemini would be called here in production
            $fortune = "Gemini API response would go here";
        }
        
        // Save to cache
        $cacheData = [
            'timestamp' => time(),
            'fortune' => $fortune,
            'created_at' => date('Y-m-d H:i:s')
        ];
        @file_put_contents($cacheFile, json_encode($cacheData, JSON_PRETTY_PRINT));
        logMessage("Fortune cached");
        
        // Save to status
        $statusFile = $QUEUE_STATUS_DIR . $requestId . '.json';
        @file_put_contents($statusFile, json_encode([
            'request_id' => $requestId,
            'status' => 'completed',
            'data' => ['fortune' => $fortune, 'message' => 'Falınız hazır!'],
            'timestamp' => time()
        ], JSON_PRETTY_PRINT));
        
        // Remove from queue
        $queueIndex['queue'] = $queue;
        @file_put_contents($QUEUE_INDEX_FILE, json_encode($queueIndex, JSON_PRETTY_PRINT));
        @unlink($queueFile);
        
        $processed = 1;
        logMessage("Queue processing complete");
    }
    
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'processed' => $processed,
        'queue_remaining' => count($queue),
        'message' => 'Queue processed'
    ]);
    exit;
}

// ============== MAIN FORTUNE SUBMIT ==============

// ============== CONFIGURATION ==============
$GEMINI_API_KEY = 'AIzaSyBHv8DNlGP-951mIfsTAiFK5C2CGEsxwx8';
$GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent';

// ============== DEVELOPMENT MODE ==============
// Set to true to use mock responses (for testing without API quota)
$DEVELOPMENT_MODE = true;  // <-- CHANGE TO FALSE FOR PRODUCTION

// Rate limiting (per user - 5 minutes)
$RATE_LIMIT_FILE = __DIR__ . '/rate_limits.json';
$MIN_REQUEST_INTERVAL = 300; // 5 minutes

// Cache
$CACHE_DIR = __DIR__ . '/fortune_cache/';
if (!file_exists($CACHE_DIR)) {
    @mkdir($CACHE_DIR, 0755, true);
}

// Retry
$MAX_RETRIES = 3;
$RETRY_DELAY = 5;

// Queue system
$QUEUE_DIR = __DIR__ . '/queue/';
$QUEUE_STATUS_DIR = __DIR__ . '/queue_status/';
if (!file_exists($QUEUE_DIR)) {
    @mkdir($QUEUE_DIR, 0755, true);
}
if (!file_exists($QUEUE_STATUS_DIR)) {
    @mkdir($QUEUE_STATUS_DIR, 0755, true);
}

// Queue index
$QUEUE_INDEX_FILE = __DIR__ . '/queue_index.json';

logMessage("=== NEW REQUEST ===");

// ============== QUEUE MANAGEMENT ==============
function getQueueIndex()
{
    global $QUEUE_INDEX_FILE;
    if (file_exists($QUEUE_INDEX_FILE)) {
        return json_decode(file_get_contents($QUEUE_INDEX_FILE), true) ?: ['next_id' => 1, 'queue' => []];
    }
    return ['next_id' => 1, 'queue' => []];
}

function saveQueueIndex($index)
{
    global $QUEUE_INDEX_FILE;
    @file_put_contents($QUEUE_INDEX_FILE, json_encode($index, JSON_PRETTY_PRINT));
}

function getQueuePosition($requestId)
{
    $index = getQueueIndex();
    $queue = $index['queue'] ?? [];
    $position = array_search($requestId, $queue) + 1;
    $estimatedWait = $position * 15; // ~15 seconds per request
    return [
        'position' => $position,
        'total_in_queue' => count($queue),
        'estimated_wait' => $estimatedWait
    ];
}

function saveRequestStatus($requestId, $status, $data = [])
{
    global $QUEUE_STATUS_DIR;
    $statusFile = $QUEUE_STATUS_DIR . $requestId . '.json';
    $statusData = [
        'request_id' => $requestId,
        'status' => $status,
        'timestamp' => time(),
        'data' => $data
    ];
    @file_put_contents($statusFile, json_encode($statusData, JSON_PRETTY_PRINT));
    logMessage("Status saved - ID: $requestId, Status: $status");
}

function getRequestStatus($requestId)
{
    global $QUEUE_STATUS_DIR;
    $statusFile = $QUEUE_STATUS_DIR . $requestId . '.json';

    if (file_exists($statusFile)) {
        return json_decode(file_get_contents($statusFile), true);
    }
    return ['status' => 'not_found', 'data' => []];
}

// ============== RATE LIMITING ==============
function checkRateLimit($userId)
{
    global $RATE_LIMIT_FILE, $MIN_REQUEST_INTERVAL;

    $limits = [];
    if (file_exists($RATE_LIMIT_FILE)) {
        $limits = json_decode(file_get_contents($RATE_LIMIT_FILE), true) ?: [];
    }

    if (isset($limits[$userId])) {
        $lastRequest = $limits[$userId];
        $timeSinceLastRequest = time() - $lastRequest;

        if ($timeSinceLastRequest < $MIN_REQUEST_INTERVAL) {
            $remainingTime = $MIN_REQUEST_INTERVAL - $timeSinceLastRequest;
            $waitMinutes = ceil($remainingTime / 60);

            return [
                'allowed' => false,
                'wait_seconds' => $remainingTime,
                'wait_minutes' => $waitMinutes,
                'message' => "Bir sonraki fal için $waitMinutes dakika beklemeniz gerekiyor. Premium üyeler sınırsız fal bakabilir! 💎"
            ];
        }
    }

    // Update rate limit
    $limits[$userId] = time();
    @file_put_contents($RATE_LIMIT_FILE, json_encode($limits, JSON_PRETTY_PRINT));

    return ['allowed' => true];
}

// ============== MOCK FORTUNE (DEVELOPMENT) ==============
function getMockFortune($name, $age, $gender, $maritalStatus)
{
    $greeting = !empty($name) ? "Sevgili $name," : "Sevgili dostum,";

    return "$greeting

🔮 Genel Yorum
Bu ay sana çok şanslı gözüküyor. Kahvenin iyice damlası senin için iyi şeyler getiriyor. Çevrendeki insanlar sana yakın olacak ve destek bulacaksın.

❤️ Aşk ve İlişkiler
Aşk hayatında yeni bir başlangıç hissediliyor. Eğer bekarsan, kısa zamanda birisiyle tanışabilirsin. Evliler için ilişkisinde yeni bir dönem başlayacak.

💼 Kariyer ve İş Hayatı
İş hayatında fırsatlar kapıyı çalıyor. Yeni bir proje veya iş teklifi gelebilir. Cesaretli bir karar almanın zamanı geldi.

🌟 Gelecek ve Fırsatlar
Önümüzdeki 3 ay çok önemli. Rüyalarını gerçekleştirme zamanı! Fırsatları kaçırma.

💰 Maddi Durum
Para konusunda iyiye gidiyor. Beklenmedik bir gelir kaynağı ortaya çıkabilir.

⚠️ Dikkat Edilmesi Gerekenler
Aceleci kararlar verme. Sabırlı ve planlı hareket et.";
}

function getImageHash($imageData)
{
    return md5($imageData);
}

function getCacheKey($hash1, $hash2, $hash3, $age, $gender, $maritalStatus)
{
    return md5($hash1 . $hash2 . $hash3 . $age . $gender . $maritalStatus);
}

function getCachedFortune($cacheKey)
{
    global $CACHE_DIR;

    $cacheFile = $CACHE_DIR . $cacheKey . '.json';

    if (file_exists($cacheFile)) {
        $cacheData = json_decode(file_get_contents($cacheFile), true);
        $cacheAge = time() - $cacheData['timestamp'];

        if ($cacheAge < 86400) { // 24 hours
            logMessage("Cache HIT - Age: " . round($cacheAge / 3600, 1) . " hours");
            return $cacheData['fortune'];
        } else {
            @unlink($cacheFile);
            logMessage("Cache EXPIRED");
        }
    }

    logMessage("Cache MISS");
    return null;
}

function saveCachedFortune($cacheKey, $fortune)
{
    global $CACHE_DIR;

    $cacheFile = $CACHE_DIR . $cacheKey . '.json';

    $cacheData = [
        'timestamp' => time(),
        'fortune' => $fortune,
        'created_at' => date('Y-m-d H:i:s')
    ];

    @file_put_contents($cacheFile, json_encode($cacheData, JSON_PRETTY_PRINT));
    logMessage("Fortune cached successfully");
}

// ============== GEMINI API ==============
function sendToGemini($imageData1, $imageData2, $imageData3, $age, $gender, $maritalStatus, $name, $attempt = 1)
{
    global $GEMINI_API_KEY, $GEMINI_API_URL, $MAX_RETRIES, $RETRY_DELAY;

    logMessage("Gemini API attempt $attempt/$MAX_RETRIES");

    $greeting = !empty($name) ? "Sevgili $name," : "Sevgili dostum,";

    $prompt = "Sen profesyonel bir Türk kahve falı yorumcususun. Önünde 3 fotoğraf var: fincanın dışı, fincanın içi ve tabak. 

Kullanıcı bilgileri:
- İsim: " . (!empty($name) ? $name : "Belirtilmemiş") . "
- Yaş: $age
- Cinsiyet: $gender
- Medeni Durum: $maritalStatus

ÖNEMLI: Falı okurken '$greeting' diye başla ve metinde ismi kullan. Samimi ve kişisel bir üslup kullan.

Lütfen bu fotoğraflara bakarak detaylı bir Türk kahve falı yorumu yap. Yorumun şu bölümleri içermeli:

$greeting

🔮 Genel Yorum (3-4 cümle, kişiye özel)
❤️ Aşk ve İlişkiler (2-3 cümle)
💼 Kariyer ve İş Hayatı (2-3 cümle)
🌟 Gelecek ve Fırsatlar (2-3 cümle)
💰 Maddi Durum (1-2 cümle)
⚠️ Dikkat Edilmesi Gerekenler (1-2 cümle)

Samimi, pozitif ama gerçekçi bir üslup kullan. İsmi doğal şekilde kullan. Türkçe yaz.";

    $requestBody = [
        'contents' => [
            [
                'parts' => [
                    ['text' => $prompt],
                    ['inline_data' => ['mime_type' => 'image/jpeg', 'data' => $imageData1]],
                    ['inline_data' => ['mime_type' => 'image/jpeg', 'data' => $imageData2]],
                    ['inline_data' => ['mime_type' => 'image/jpeg', 'data' => $imageData3]]
                ]
            ]
        ],
        'generationConfig' => [
            'temperature' => 0.7,
            'topK' => 40,
            'topP' => 0.95,
            'maxOutputTokens' => 2048,
        ]
    ];

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $GEMINI_API_URL . '?key=' . $GEMINI_API_KEY);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($requestBody));
    curl_setopt($ch, CURLOPT_TIMEOUT, 60);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $curlError = curl_error($ch);
    curl_close($ch);

    logMessage("Gemini API response code: $httpCode");

    if ($curlError) {
        logMessage("Curl error: $curlError");
        throw new Exception("Curl error: $curlError");
    }

    if ($httpCode == 200) {
        $data = json_decode($response, true);

        if (isset($data['candidates'][0]['content']['parts'][0]['text'])) {
            $fortune = $data['candidates'][0]['content']['parts'][0]['text'];
            logMessage("Success! Fortune length: " . strlen($fortune));
            return ['success' => true, 'fortune' => $fortune];
        } else {
            logMessage("Invalid response structure: " . substr($response, 0, 200));
            throw new Exception("Invalid response from Gemini API");
        }
    } elseif ($httpCode == 503 || $httpCode == 429) {
        logMessage("Rate limit or service unavailable (HTTP $httpCode)");

        if ($attempt < $MAX_RETRIES) {
            $delay = $RETRY_DELAY * $attempt;
            logMessage("Waiting $delay seconds before retry...");
            sleep($delay);
            return sendToGemini($imageData1, $imageData2, $imageData3, $age, $gender, $maritalStatus, $name, $attempt + 1);
        }
    }

    logMessage("API Error - Status: $httpCode, Response: " . substr($response, 0, 200));
    throw new Exception("Gemini API error: HTTP $httpCode");
}

// ============== MAIN ==============
try {
    // Validate files
    if (!isset($_FILES['image1']) || !isset($_FILES['image2']) || !isset($_FILES['image3'])) {
        logMessage("Error: Missing image files");
        throw new Exception('3 fotoğraf gerekli');
    }

    logMessage("Files received: " . count($_FILES));

    // Get user info
    $userId = $_POST['user_id'] ?? 'anonymous_' . uniqid();
    $name = trim($_POST['name'] ?? '');
    $age = intval($_POST['age'] ?? 25);
    $gender = $_POST['gender'] ?? 'Belirtilmemiş';
    $maritalStatus = $_POST['marital_status'] ?? 'Belirtilmemiş';

    logMessage("Request - User: $userId, Name: $name, Age: $age, Gender: $gender, MaritalStatus: $maritalStatus");

    // Check rate limit
    $rateLimitCheck = checkRateLimit($userId);
    if (!$rateLimitCheck['allowed']) {
        logMessage("Rate limit exceeded for user: $userId");
        http_response_code(429);
        echo json_encode([
            'success' => false,
            'rate_limited' => true,
            'wait_seconds' => $rateLimitCheck['wait_seconds'],
            'wait_minutes' => $rateLimitCheck['wait_minutes'],
            'message' => $rateLimitCheck['message']
        ]);
        exit;
    }

    // Read and encode images
    logMessage("Reading images...");
    $imageData1 = base64_encode(file_get_contents($_FILES['image1']['tmp_name']));
    $imageData2 = base64_encode(file_get_contents($_FILES['image2']['tmp_name']));
    $imageData3 = base64_encode(file_get_contents($_FILES['image3']['tmp_name']));

    logMessage("Images encoded - Sizes: " . strlen($imageData1) . ", " . strlen($imageData2) . ", " . strlen($imageData3));

    // Generate cache key
    $hash1 = getImageHash($imageData1);
    $hash2 = getImageHash($imageData2);
    $hash3 = getImageHash($imageData3);
    $cacheKey = getCacheKey($hash1, $hash2, $hash3, $age, $gender, $maritalStatus);

    logMessage("Cache key: $cacheKey");

    // Check cache FIRST - instant response if cache hit
    $cachedFortune = getCachedFortune($cacheKey);

    if ($cachedFortune) {
        logMessage("Cache HIT - Returning instant response");
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'instant' => true,
            'cached' => true,
            'fortune' => $cachedFortune,
            'message' => 'Falınız hazır!'
        ]);
        exit;
    }

    // No cache - add to queue for processing
    logMessage("Cache MISS - Adding to queue for processing");

    $queueIndex = getQueueIndex();
    $requestId = 'REQ_' . $queueIndex['next_id'] . '_' . time();

    // Save request data to queue
    $requestData = [
        'request_id' => $requestId,
        'user_id' => $userId,
        'name' => $name,
        'age' => $age,
        'gender' => $gender,
        'marital_status' => $maritalStatus,
        'cache_key' => $cacheKey,
        'image_data' => [
            'hash1' => $hash1,
            'hash2' => $hash2,
            'hash3' => $hash3,
            'data1' => $imageData1,
            'data2' => $imageData2,
            'data3' => $imageData3
        ],
        'submitted_at' => date('Y-m-d H:i:s')
    ];

    // Save to queue
    $queueFile = $QUEUE_DIR . $requestId . '.json';
    @file_put_contents($queueFile, json_encode($requestData, JSON_PRETTY_PRINT));

    // Update queue index
    $queueIndex['queue'][] = $requestId;
    $queueIndex['next_id']++;
    saveQueueIndex($queueIndex);

    // Save initial status
    saveRequestStatus($requestId, 'queued', [
        'position' => count($queueIndex['queue']),
        'total_in_queue' => count($queueIndex['queue'])
    ]);

    $queueInfo = getQueuePosition($requestId);

    logMessage("Request queued: $requestId, Position: " . $queueInfo['position'] . ", Wait: " . $queueInfo['estimated_wait'] . "s");

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'instant' => false,
        'request_id' => $requestId,
        'queue_position' => $queueInfo['position'],
        'total_in_queue' => $queueInfo['total_in_queue'],
        'estimated_wait' => $queueInfo['estimated_wait'],
        'message' => 'Falınız kuyruğa alındı, lütfen bekleyin...'
    ]);
    exit;

} catch (Exception $e) {
    $errorMsg = $e->getMessage();
    logMessage("ERROR: $errorMsg");

    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $errorMsg,
        'debug' => [
            'file' => $e->getFile(),
            'line' => $e->getLine()
        ]
    ]);
}
?>