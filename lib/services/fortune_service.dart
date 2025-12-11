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

      final response = await http
          .post(
            Uri.parse('$baseUrl/fortune.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

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
}
