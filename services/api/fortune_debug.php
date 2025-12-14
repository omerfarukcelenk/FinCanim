<?php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Error logging - Production mode: hide errors from users, log to file only
ini_set('display_errors', 0);
ini_set('log_errors', 1);
error_reporting(E_ALL);
date_default_timezone_set('Europe/Istanbul');

// Log file
$logFile = __DIR__ . '/fortune_debug.log';

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
        'data' => [
            'status' => $statusData['status'] ?? 'unknown',
            'fortune' => $statusData['data']['fortune'] ?? null,
            'message' => $statusData['data']['message'] ?? ''
        ]
    ]);
    exit;
}

// ============== HANDLE QUEUE PROCESSING ==============
if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['action']) && $_GET['action'] === 'process_queue') {
    $QUEUE_DIR = __DIR__ . '/queue/';
    $QUEUE_INDEX_FILE = __DIR__ . '/queue_index.json';
    $QUEUE_STATUS_DIR = __DIR__ . '/queue_status/';
    $CACHE_DIR = __DIR__ . '/fortune_cache/';
    // Use environment variables or fallback to actual mode
    $DEVELOPMENT_MODE = getenv('DEVELOPMENT_MODE') === 'true';
    $GEMINI_API_KEY = 'AIzaSyBHv8DNlGP-951mIfsTAiFK5C2CGEsxwx8';
    $GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';
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
    $imageDataObj = $requestData['image_data'] ?? [];

    // Extract base64 image data from the correct keys
    $imageData = [
        $imageDataObj['data1'] ?? '',
        $imageDataObj['data2'] ?? '',
        $imageDataObj['data3'] ?? ''
    ];

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
            // Debug: log image data availability
            logMessage("Image data lengths - [0]: " . strlen($imageData[0] ?? '') . ", [1]: " . strlen($imageData[1] ?? '') . ", [2]: " . strlen($imageData[2] ?? ''));

            try {
                $geminiResult = sendToGemini($imageData[0] ?? '', $imageData[1] ?? '', $imageData[2] ?? '', $age, $gender, $maritalStatus, $name);
                if ($geminiResult['success']) {
                    $fortune = $geminiResult['fortune'];
                } else {
                    logMessage("Gemini API failed: " . ($geminiResult['error'] ?? 'Unknown error'));
                    $fortune = "❌ API Error: " . ($geminiResult['error'] ?? 'Unknown error');
                }
            } catch (Exception $e) {
                logMessage("Gemini API exception: " . $e->getMessage());
                $fortune = "❌ Error: " . $e->getMessage();
            }
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
// Use environment variables for sensitive keys
$GEMINI_API_KEY = 'AIzaSyBHv8DNlGP-951mIfsTAiFK5C2CGEsxwx8';
$GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';

// ============== DEVELOPMENT MODE ==============
// Set to true to use mock responses (for testing without API quota)
// Use environment variable or default to production mode (false)
$DEVELOPMENT_MODE = getenv('DEVELOPMENT_MODE') === 'true';

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
    $nameDisplay = !empty($name) ? $name : "dostum";

    return "$greeting

🔮 GENEL YORUM:
Kahve falında gördüğümüz işaretler senin hayatında önemli bir dönüşümün başında olduğunu gösteriyor. Bardağında biriken kahve kalıntıları ve semboller, içsel gücünü ve bilinçli kararlarını temsil ediyor. Şu an aldığın her seçim senin geleceğini şekillendiriyor ve bu sorumluluğu taşıyabilecek kadar güçlüsün. Enerji seviyesi yüksek, ancak dikkatli ve dengeli adımlar atman önemli.

❤️ AŞK VE İLİŞKİLER:
Falında kalp sembolleri görüyoruz - bu duygusal dönemin yakında açılacağını gösteriyor. Şu an ilişkide isen, daha derin bir bağlaşma yaşayacaksın. Bekar isen, yakın zamanda tanıştığın birisi seni gerçekten etkileyecek. Çiçek ve yıldız sembolleri sevgide şans gösteriyor.

💼 KARİYER VE İŞ HAYATI:
Kardiyerde ilerleme sembollerini net şekilde görüyorum - merdiven, ok gibi semboller senin mesleki gelişimini gösteriyor. Başında bulunduğun projeler kısa süre içinde meyvesini verecek. Beklenmedik bir iş fırsatı gelebilir ve bu senin istediğinden daha iyi olacak.

🌟 GELECEK VE FIRSATLAR:
Falında yıldız ve ışık sembolleri baskın - yakın 3-4 ay senin için çok verimli olacak. Hayatında açılacak yeni kapılar seni beklenen yerlere götürecek. Sosyal çevrende ilginç tanışmalar ve kişisel gelişim olanakları hızlı hızlı gelecek.

💰 MADDİ DURUM:
Finansal konuda iyileşme dönemi açıkça görülüyor. Uzun süredir beklediğin para işi sonuç verecek. Borçlar yapılanalacak ya da beklenen para gelecek. Şansın parasal konuda çok iyi - dikkatli ve bilinçli harcamalar yap.

⚠️ DİKKAT EDİLMESİ GEREKENLER:
Falında bazı uyarı sembolleri de var - çarpı, ters ok gibi şekiller bize dikkatini çekmek istiyor. Başında birisi sana kötü niyetle yaklaşabilir. Ruh ve fiziki sağlığına vakit ayır, stres senin düşman.

✨ KAPANIŞ MESAJI:
Senin başında muhteşem bir dönem var, bu kesin. Kendine inan ve bu fırsatları değerlendir. Evren seni destekliyor! 🌙✨";
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
    $nameDisplay = !empty($name) ? $name : "dostum";
    $ageDisplay = $age && $age > 0 ? $age : "yaş belirtilmemiş";
    $genderDisplay = !empty($gender) && $gender !== "Belirtilmemiş" ? $gender : "cinsiyet belirtilmemiş";
    $maritalDisplay = !empty($maritalStatus) && $maritalStatus !== "Belirtilmemiş" ? $maritalStatus : "medeni durum belirtilmemiş";

    $prompt = "Sen profesyonel, deneyimli ve samimi bir Türk kahve falı yorumcususun. Kullanıcı sana 3 fotoğraf göndermiş: kahve fincanının dışı, içi ve altında bulunan tabak. Bu fotoğrafları DİKKATLİCE analiz edip, görünen semboller, şekiller ve kahve kalıntılarının yerleşimine dayalı DETAYLI ve KIŞİSEL yorumlar yapacaksın.

👤 KULLANICı BİLGİLERİ:
- İsim: $nameDisplay
- Yaş: $ageDisplay
- Cinsiyet: $genderDisplay
- Medeni Durum: $maritalDisplay

📸 FOTOĞRAF ANALIZ TAPALıĞı:
Fotoğraf 1: Kahve fincanının dışı (genel görünüş, renk, desen, fincanın şekli ve kalitesi)
Fotoğraf 2: Kahve fincanının içi (semboller, kalp, ev, merdiven, kuş, çiçek, yıldız, halka, çarpı, ok vb. kahve kalıntıları ve desenler)
Fotoğraf 3: Fincanın altındaki tabak (falın çerçevesi, tama yer alan ek semboller, kahve dağılımı)

🔮 TALIMATLAR (ÖZEL VURGU):
1. \"$greeting\" diye başla
2. Metinde ismi ($nameDisplay) doğal ve samimi şekilde kullan
3. GÖRÜNEN SEMBOLLER ÜZERİNE YOĞUNLAŞ: Kahvenin içinde hangi şekiller/semboller görülüyor? Her sembolün anlamını detaylı şekilde açıkla.
   - Kalp gördüysen: \"falında bardağında biriken kalp yakında aşkı bulacağını gösteriyor\" şeklinde örnek ver
   - Ev gördüysen: ev hayatı, aile, güvenlik hakkında detaylı yorum
   - Merdiven gördüysen: yükseliş, gelişim, başarıya giden yol
   - Çiçek gördüysen: güzellik, sevgi, doğallık
   - Kuş gördüysen: özgürlük, mesaj, haberler
   - Yıldız gördüysen: başarı, şans, umut
4. Yaş, cinsiyet ve medeni durum bilgilerini dikkate al ve buna göre kişiselleştir
5. Her bölümü 3-4 cümle ile açıkla (daha detaylı)
6. Samimi, pozitif, ancak gerçekçi bir üslup kullan
7. Spesifik ve genel şeyler arasında denge kur
8. Dini veya kültürel hassasiyetlere saygı göster

📋 FALI SONUÇ YAPISI:

$greeting

🔮 GENEL YORUM (7-8 cümle):
$nameDisplay'ın kahve falında görülen tüm semboller, kahvenin yoğunluğu ve dağılımı hakkında detaylı genel yorum. Mevcut hayat aşamasında neler yaşadığını, enerjisini ve psikolojik durumunu analiz et. Fotoğraflarda görmüş olduğun spesifik sembollerden bahset.

❤️ AŞK VE İLİŞKİLER (3-4 cümle):
Kalp, yıldız, çiçek gibi aşk sembollerinden bahset. Romantik hayatında beklenen gelişmeler. İlişki durumuna göre (bekar/evli) özel öneriler. Aşk beklentileri ve yakın gelecek.

💼 KARİYER VE İŞ HAYATI (3-4 cümle):
Merdiven, ok, çarpı gibi kariyer sembollerinden detaylı yorum. İş hayatında yeni fırsatlar ve zorluklar. Başarı olasılıkları. Mesleki gelişim yönleri.

🌟 GELECEK VE FIRSATLAR (3-4 cümle):
Falda görünen şanslı işaretleri detaylı anlat. Yakın gelecekte $nameDisplay'ı bekleyen kapılar. Kişisel gelişim fırsatları. Dikkat etmesi gereken dönem ve fırsatlar.

💰 MADDİ DURUM (3-4 cümle):
Kahvenin dağılımı ve yoğunluğuna göre finansal durum analizi. Parasal durumda beklenen değişiklikler. Ekonomik refah dönemleri. Dikkat edilmesi gereken finansal konular.

⚠️ DİKKAT EDİLMESİ GEREKENLER (3-4 cümle):
Falda uyarıcı semboller varsa (çarpı, ters ok, vb.) bunları açıkla. Dikkat etmesi gereken konular. Kişisel gelişim için spesifik öneriler. Zorlukların nasıl aşılabileceği.

✨ KAPANIŞ MESAJI (2-3 cümle):
Umut dolu, motive edici ve samimi bir son. $nameDisplay'ın başarısına ve mutluluğuna dua.

📝 ÖZETİ NOT:
- FOTOĞRAFTA GÖRDÜĞÜN HER SEMBOLE REFERANS VER
- Her cümle 12-18 kelime olmalı (okunabilir ama detaylı)
- Emojiler başlıkta kalsın, metinde az kullan
- Çok samimi ve kişisel tonda yaz
- Spesifik sembol analizi = iyi fal yorumu
- Umut verici ama gerçekçi kal
- $nameDisplay için kişiselleştirilmiş tavsiyeleri DHAhil et";

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
            'temperature' => 0.8,
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

    // Log full error response for debugging
    logMessage("API Error - Status: $httpCode");
    logMessage("Full response: " . substr($response, 0, 500));
    $errorInfo = json_decode($response, true);
    if (isset($errorInfo['error']['message'])) {
        logMessage("Gemini error message: " . $errorInfo['error']['message']);
        throw new Exception("Gemini API error: " . $errorInfo['error']['message']);
    }
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