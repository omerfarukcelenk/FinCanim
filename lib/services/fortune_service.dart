import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:falcim_benim/utils/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:falcim_benim/utils/toast_helper.dart';
import 'package:image/image.dart' as img;

class FortuneService {
  static const String baseUrl = 'https://omerfarukcelenk.com/api';
  static const int maxRetries = 3;
  static const Duration timeout = Duration(seconds: 60);
  static const Duration retryDelay = Duration(seconds: 2);

  Future<Map<String, dynamic>> readFortune(
    List<File> imageFiles,
    String userId,
    String idToken, {
    int? age,
    String? gender,
    String? maritalStatus,
  }) async {
    try {
      // Prepare base64 images for up to 3 entries: image1, image2, image3
      final Map<String, String> base64Map = {};
      for (var i = 0; i < imageFiles.length && i < 3; i++) {
        final File f = imageFiles[i];
        final Uint8List imageBytes = await f.readAsBytes();

        img.Image? decoded;
        try {
          decoded = img.decodeImage(imageBytes);
        } catch (e) {
          Logger.warn('Image decode failed: $e', tag: 'FORTUNE');
          decoded = null;
        }

        Uint8List bytesToSend = imageBytes;
        if (decoded != null) {
          try {
            const int maxSide = 800;
            const int quality = 85;
            img.Image processed = decoded;
            if (decoded.width > maxSide || decoded.height > maxSide) {
              processed = img.copyResize(
                decoded,
                width: decoded.width > decoded.height ? maxSide : null,
                height: decoded.height > decoded.width ? maxSide : null,
                interpolation: img.Interpolation.linear,
              );
            }

            final Uint8List encoded = Uint8List.fromList(
              img.encodeJpg(processed, quality: quality),
            );
            // Only use the encoded/compressed bytes if they actually reduce size.
            if (encoded.isNotEmpty && encoded.length < imageBytes.length) {
              bytesToSend = encoded;
              Logger.debug(
                'Image ${i + 1} compressed: ${imageBytes.length} → ${encoded.length} bytes',
                tag: 'FORTUNE',
              );
            } else {
              Logger.debug(
                'Image ${i + 1} compression skipped (no size gain): original=${imageBytes.length}, encoded=${encoded.length}',
                tag: 'FORTUNE',
              );
            }
          } catch (e) {
            Logger.warn(
              'Compression failed for image ${i + 1}: $e',
              tag: 'FORTUNE',
            );
            bytesToSend = imageBytes;
          }
        }

        if (bytesToSend.length > 5 * 1024 * 1024) {
          Logger.error(
            'Image ${i + 1} too large: ${bytesToSend.length} bytes',
            tag: 'FORTUNE',
          );
          return {'success': false, 'message': 'Image too large', 'data': null};
        }

        base64Map['image${i + 1}'] = base64Encode(bytesToSend);
      }

      final Map<String, dynamic> requestBody = {
        ...base64Map,
        'userId': userId,
        'idToken': idToken,
      };

      if (age != null) requestBody['age'] = age;
      if (gender != null) requestBody['gender'] = gender;
      if (maritalStatus != null) requestBody['maritalStatus'] = maritalStatus;

      // Retry logic with exponential backoff
      http.Response? response;
      for (int attempt = 0; attempt < maxRetries; attempt++) {
        try {
          Logger.info(
            'Fortune API request attempt ${attempt + 1}/$maxRetries',
            tag: 'FORTUNE',
          );
          response = await http
              .post(
                Uri.parse('$baseUrl/fortune.php'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(requestBody),
              )
              .timeout(timeout);

          // Success or non-retryable error
          if (response.statusCode == 200 || response.statusCode == 400) {
            break;
          }

          // Retryable errors (503, 429, 500, timeout)
          if (response.statusCode >= 500 || response.statusCode == 429) {
            if (attempt < maxRetries - 1) {
              final delay = retryDelay * (attempt + 1);
              Logger.warn(
                'HTTP ${response.statusCode}, retrying in ${delay.inSeconds}s...',
                tag: 'FORTUNE',
              );
              await Future.delayed(delay);
              continue;
            }
          }
          break;
        } on SocketException catch (e) {
          Logger.warn('Network error: $e', tag: 'FORTUNE');
          if (attempt < maxRetries - 1) {
            await Future.delayed(retryDelay * (attempt + 1));
            continue;
          }
          rethrow;
        } on TimeoutException catch (e) {
          Logger.warn('Timeout on attempt ${attempt + 1}: $e', tag: 'FORTUNE');
          if (attempt < maxRetries - 1) {
            await Future.delayed(retryDelay * (attempt + 1));
            continue;
          }
          rethrow;
        }
      }

      if (response == null) {
        return {
          'success': false,
          'message': 'No response from server',
          'data': null,
        };
      }

      // Save raw response body for debug in release builds (internal testing)
      try {
        final rawBody = response.body;
        final dir = await getTemporaryDirectory();
        final file = File(
          '${dir.path}/fortune_response_${DateTime.now().millisecondsSinceEpoch}.json',
        );
        await file.writeAsString(rawBody);
        Logger.info(
          'Saved fortune raw response to: ${file.path}',
          tag: 'FORTUNE',
        );
        // Small user-visible hint for internal testing
        try {
          ToastHelper.showInfo('Fortune response kaydedildi');
        } catch (_) {}
      } catch (e) {
        Logger.warn('Failed to save raw fortune response: $e', tag: 'FORTUNE');
      }

      final int status = response.statusCode;
      final String body = response.body;
      Logger.debug('Status: $status', tag: 'FORTUNE');

      if (status == 200) {
        final Map<String, dynamic> data =
            jsonDecode(body) as Map<String, dynamic>;

        Logger.debug('=== FORTUNE API RESPONSE ===', tag: 'FORTUNE');
        Logger.debug('Full response: $data', tag: 'FORTUNE');
        Logger.debug('success: ${data['success']}', tag: 'FORTUNE');
        Logger.debug('message: ${data['message']}', tag: 'FORTUNE');
        Logger.debug('data type: ${data['data'].runtimeType}', tag: 'FORTUNE');
        Logger.debug('data content: ${data['data']}', tag: 'FORTUNE');

        if (data['success'] == true) {
          Logger.info('Fortune API success', tag: 'FORTUNE');
          return {
            'success': true,
            'message': data['message'] ?? '',
            'data': data['data'],
          };
        } else {
          Logger.error(
            'API returned success=false: message=${data['message']}',
            tag: 'FORTUNE',
          );
          Logger.debug('Response body: $body', tag: 'FORTUNE');
          return {
            'success': false,
            'message': data['message'] ?? 'Unknown error',
            'data': data['data'],
          };
        }
      } else {
        Logger.error('HTTP Hatası: $status', tag: 'FORTUNE');
        Logger.debug('Response body: $body', tag: 'FORTUNE');
        try {
          final dynamic errorData = jsonDecode(body);
          if (errorData is Map && errorData.containsKey('message')) {
            Logger.error(
              'Backend error: ${errorData['message']}',
              tag: 'FORTUNE',
            );
            return {
              'success': false,
              'message': errorData['message'] ?? 'HTTP $status',
              'data': null,
            };
          }
        } catch (_) {
          Logger.error('Raw response: $body', tag: 'FORTUNE');
        }
        return {'success': false, 'message': 'HTTP $status', 'data': null};
      }
    } catch (e) {
      Logger.error('İstek hatası: $e', tag: 'FORTUNE');
      return {'success': false, 'message': 'Request error: $e', 'data': null};
    }
  }

  /// Submit fortune request to queue (NEW - Queue System)
  Future<Map<String, dynamic>> submitFortuneToQueue(
    List<File> imageFiles,
    String userId, {
    String? name,
    int? age,
    String? gender,
    String? maritalStatus,
  }) async {
    try {
      Logger.info('📋 Submitting fortune request to queue...', tag: 'FORTUNE');

      // Prepare multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/fortune.php'),
      );

      // Add user data
      request.fields['user_id'] = userId;
      if (name != null) request.fields['name'] = name;
      if (age != null) request.fields['age'] = age.toString();
      if (gender != null) request.fields['gender'] = gender;
      if (maritalStatus != null)
        request.fields['marital_status'] = maritalStatus;

      // Add image files
      for (var i = 0; i < imageFiles.length && i < 3; i++) {
        final file = imageFiles[i];
        request.files.add(
          await http.MultipartFile.fromPath('image${i + 1}', file.path),
        );
      }

      Logger.debug('Sending request to queue...', tag: 'FORTUNE');
      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final requestId = data['request_id'];
          final position = data['queue_position'] ?? 1;
          final estimatedWait = data['estimated_wait'] ?? 30;

          // Check if fortune is already cached (instant response)
          final bool isInstant =
              data['instant'] == true || data['fortune'] != null;
          final fortuneText = data['fortune'];

          if (isInstant &&
              fortuneText != null &&
              fortuneText.toString().isNotEmpty) {
            Logger.success(
              '⚡ Cache hit! Instant fortune returned',
              tag: 'FORTUNE',
            );
            return {
              'success': true,
              'instant': true,
              'fortune': fortuneText.toString(),
              'message': data['message'] ?? 'Falınız hazır!',
            };
          }

          Logger.success(
            '✅ Request queued! ID: $requestId, Position: $position, Wait: ${estimatedWait}s',
            tag: 'FORTUNE',
          );

          return {
            'success': true,
            'instant': false,
            'request_id': requestId,
            'status': 'pending',
            'queue_position': position,
            'estimated_wait': estimatedWait,
            'message': data['message'] ?? 'Kuyruğa alındı',
          };
        } else {
          Logger.error(
            'Queue submit failed: ${data['message']}',
            tag: 'FORTUNE',
          );
          return {
            'success': false,
            'message': data['message'] ?? 'Queue error',
          };
        }
      } else if (response.statusCode == 429) {
        // Rate limited
        final data = jsonDecode(response.body);
        Logger.warn('Rate limited: ${data['message']}', tag: 'FORTUNE');
        return {
          'success': false,
          'rate_limited': true,
          'wait_seconds': data['wait_seconds'] ?? 300,
          'wait_minutes': data['wait_minutes'] ?? 5,
          'message': data['message'] ?? 'Lütfen bekleyin',
        };
      } else {
        Logger.error('HTTP ${response.statusCode}', tag: 'FORTUNE');
        return {'success': false, 'message': 'HTTP ${response.statusCode}'};
      }
    } catch (e) {
      Logger.error('Queue submit error: $e', tag: 'FORTUNE');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Check fortune request status (NEW - Queue System)
  Future<Map<String, dynamic>> checkFortuneStatus(String requestId) async {
    try {
      Logger.debug('Checking status for request: $requestId', tag: 'FORTUNE');

      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/fortune.php?action=status&request_id=$requestId',
            ),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final statusData = data['data'];
          final status = statusData['status'];

          Logger.debug('Status: $status', tag: 'FORTUNE');

          if (status == 'completed') {
            Logger.success('✅ Fortune ready!', tag: 'FORTUNE');
            final fortune =
                statusData['fortune'] ?? 'Falınız henüz hazırlanıyor...';
            return {
              'success': true,
              'status': 'completed',
              'fortune': fortune,
              'processed_at': statusData['processed_at'],
            };
          } else if (status == 'pending' || status == 'processing') {
            final position = statusData['queue_position'] ?? 1;
            final estimatedWait = statusData['estimated_wait'] ?? 30;

            return {
              'success': true,
              'status': status,
              'queue_position': position,
              'estimated_wait': estimatedWait,
            };
          } else if (status == 'failed') {
            Logger.error(
              'Request failed: ${statusData['error']}',
              tag: 'FORTUNE',
            );
            return {
              'success': false,
              'status': 'failed',
              'error': statusData['error'],
            };
          }
        }

        return {
          'success': false,
          'message': data['message'] ?? 'Unknown error',
        };
      } else if (response.statusCode == 404) {
        Logger.warn('Request not found: $requestId', tag: 'FORTUNE');
        return {'success': false, 'message': 'İstek bulunamadı'};
      } else {
        Logger.error('HTTP ${response.statusCode}', tag: 'FORTUNE');
        return {'success': false, 'message': 'HTTP ${response.statusCode}'};
      }
    } catch (e) {
      Logger.error('Status check error: $e', tag: 'FORTUNE');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Trigger queue processing on backend
  Future<bool> triggerQueueProcessing() async {
    try {
      Logger.debug('Triggering queue processing...', tag: 'FORTUNE');

      final response = await http
          .get(Uri.parse('$baseUrl/fortune.php?action=process_queue'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Logger.debug(
          'Queue trigger response: ${data['message']}',
          tag: 'FORTUNE',
        );
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      Logger.warn('Queue trigger error (non-critical): $e', tag: 'FORTUNE');
      return false;
    }
  }
}
