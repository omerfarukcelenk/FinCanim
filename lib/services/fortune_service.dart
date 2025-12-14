import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:falcim_benim/utils/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:falcim_benim/utils/toast_helper.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

class FortuneService {
  static const String baseUrl = 'https://omerfarukcelenk.com/api';
  static const int maxRetries = 3;
  static const Duration timeout = Duration(seconds: 60);
  static const Duration retryDelay = Duration(seconds: 2);

  /// Get the appropriate endpoint based on build mode
  static String get fortuneEndpoint {
    if (kDebugMode) {
      Logger.info('Using DEBUG endpoint: fortune_debug.php', tag: 'FORTUNE');
      return '$baseUrl/fortune_debug.php';
    } else {
      Logger.info('Using PRODUCTION endpoint: fortune.php', tag: 'FORTUNE');
      return '$baseUrl/fortune.php';
    }
  }

  Map<String, dynamic> _safeDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'_raw': decoded};
    } catch (e) {
      Logger.warn('JSON decode failed: $e', tag: 'FORTUNE');
      return <String, dynamic>{};
    }
  }

  Future<Map<String, dynamic>> submitFortuneToQueue(
    List<File> imageFiles,
    String userId, {
    String? name,
    int? age,
    String? gender,
    String? maritalStatus,
  }) async {
    const submitRetries = 3;
    const submitRetryDelay = Duration(seconds: 1);
    const submitTimeout = Duration(seconds: 120);

    for (int attempt = 0; attempt < submitRetries; attempt++) {
      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse(fortuneEndpoint),
        );
        request.fields['user_id'] = userId;
        if (name != null) request.fields['name'] = name;
        if (age != null) request.fields['age'] = age.toString();
        if (gender != null) request.fields['gender'] = gender;
        if (maritalStatus != null)
          request.fields['marital_status'] = maritalStatus;

        for (var i = 0; i < imageFiles.length && i < 3; i++) {
          final file = imageFiles[i];
          request.files.add(
            await http.MultipartFile.fromPath('image${i + 1}', file.path),
          );
        }

        final streamed = await request.send().timeout(submitTimeout);
        final response = await http.Response.fromStream(streamed);
        final data = _safeDecode(response.body);
        return {'success': data['success'] == true, ...data};
      } on SocketException catch (e) {
        Logger.warn(
          'Socket error on attempt ${attempt + 1}/$submitRetries: $e',
          tag: 'FORTUNE',
        );
        if (attempt < submitRetries - 1) {
          final delay = submitRetryDelay * (attempt + 1);
          await Future.delayed(delay);
          continue;
        }
        Logger.error(
          'Queue submit failed after $submitRetries retries: $e',
          tag: 'FORTUNE',
        );
        return {'success': false, 'message': 'Connection error: $e'};
      } on TimeoutException catch (e) {
        Logger.warn(
          'Timeout on attempt ${attempt + 1}/$submitRetries: $e',
          tag: 'FORTUNE',
        );
        if (attempt < submitRetries - 1) {
          final delay = submitRetryDelay * (attempt + 1);
          await Future.delayed(delay);
          continue;
        }
        Logger.error(
          'Queue submit timeout after $submitRetries retries',
          tag: 'FORTUNE',
        );
        return {'success': false, 'message': 'Upload timeout'};
      } catch (e) {
        Logger.error('Queue submit error: $e', tag: 'FORTUNE');
        return {'success': false, 'message': 'Error: $e'};
      }
    }

    return {'success': false, 'message': 'Queue submit failed'};
  }

  Future<Map<String, dynamic>> checkFortuneStatus(String requestId) async {
    const maxStatusRetries = 5;
    const statusRetryDelay = Duration(milliseconds: 500);
    const statusTimeout = Duration(seconds: 15);

    for (int attempt = 0; attempt < maxStatusRetries; attempt++) {
      try {
        final response = await http
            .get(
              Uri.parse(
                '${fortuneEndpoint}?action=status&request_id=$requestId',
              ),
            )
            .timeout(statusTimeout);
        final data = _safeDecode(response.body);
        return {
          'success': data['success'] == true,
          'data': data['data'] ?? {},
          'message': data['message'] ?? '',
        };
      } on SocketException catch (e) {
        Logger.warn(
          'Socket error on attempt ${attempt + 1}/$maxStatusRetries: $e',
          tag: 'FORTUNE',
        );
        if (attempt < maxStatusRetries - 1) {
          final delay = statusRetryDelay * (attempt + 1); // exponential backoff
          await Future.delayed(delay);
          continue;
        }
        Logger.error(
          'Status check failed after $maxStatusRetries retries: $e',
          tag: 'FORTUNE',
        );
        return {'success': false, 'message': 'Connection error: $e'};
      } on TimeoutException catch (e) {
        Logger.warn(
          'Timeout on attempt ${attempt + 1}/$maxStatusRetries: $e',
          tag: 'FORTUNE',
        );
        if (attempt < maxStatusRetries - 1) {
          final delay = statusRetryDelay * (attempt + 1);
          await Future.delayed(delay);
          continue;
        }
        Logger.error(
          'Status check timeout after $maxStatusRetries retries',
          tag: 'FORTUNE',
        );
        return {'success': false, 'message': 'Request timeout'};
      } catch (e) {
        Logger.error('Status check error: $e', tag: 'FORTUNE');
        return {'success': false, 'message': 'Error: $e'};
      }
    }

    return {'success': false, 'message': 'Status check failed'};
  }

  Future<bool> triggerQueueProcessing() async {
    try {
      final response = await http
          .get(Uri.parse('${fortuneEndpoint}?action=process_queue'))
          .timeout(const Duration(seconds: 10));
      final data = _safeDecode(response.body);
      return data['success'] == true;
    } on SocketException catch (e) {
      Logger.warn('Queue trigger socket error: $e', tag: 'FORTUNE');
      return false;
    } on TimeoutException catch (e) {
      Logger.warn('Queue trigger timeout: $e', tag: 'FORTUNE');
      return false;
    } catch (e) {
      Logger.warn('Queue trigger error (non-critical): $e', tag: 'FORTUNE');
      return false;
    }
  }
}
