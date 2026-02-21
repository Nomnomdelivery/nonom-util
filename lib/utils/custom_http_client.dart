// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/widgets.dart';
// import 'package:http/http.dart' as http;

// abstract class CustomHttpClient {
//   static final http.Client _client = http.Client();
//   // static final EnvService _env = EnvService.instance;
//   // static final DataCacher _cacher = DataCacher.instance;
//   // static final FirebaseFirestoreSupport _firestore = FirebaseFirestoreSupport();

//   // static final String _baseUrl = _env.prod; // Replace with your API URL
//   // static final String _baseDomainUrl = _env.domain; // Replace with your API URL

//   static final Map<String, String> _defaultHeaders = {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//   };

//   static Future<Map<String, String>> _buildHeaders([
//     Map<String, String>? customHeaders,
//   ]) async {
//     final headers = Map<String, String>.from(_defaultHeaders);
//     if (_cacher.getUserToken() != null && _cacher.getUserToken()!.isNotEmpty) {
//       headers['Authorization'] = 'Bearer ${_cacher.getUserToken()}';
//     }
//     // Add app version
//     final packageInfo = await PackageInfo.fromPlatform();
//     headers['App-Version'] = packageInfo.version;
//     headers['App-Platform'] = Platform.isAndroid ? 'android' : 'ios';

//     if (customHeaders != null) {
//       headers.addAll(customHeaders);
//     }
//     return headers;
//   }

//   static Uri _buildUri(String path) {
//     return Uri.parse('$_baseUrl$path');
//   }

//   static Uri _buildDomainUri(String path) {
//     return Uri.parse('$_baseDomainUrl/api$path');
//   }

//   static Future<http.Response> _handleResponse(
//     Future<http.Response> future,
//   ) async {
//     final response = await future;

//     // 🔐 Auto logout if 401 Unauthorized
//     if (response.statusCode == 401) {
//       debugPrint(response.body);

//       debugPrint('[HttpClient] 401 received — token cleared');
//       debugPrint("current user 401 ${_cacher.getUserID()}");
//       debugPrint("current uid ${_cacher.getUID()}");
//       debugPrint("current getFcmToken ${_cacher.getFcmToken()}");
//       debugPrint("current getUserToken ${_cacher.getUserToken()}");

//       // Clean up FCM token if available
//       final userId = _cacher.getUserID();
//       final fcmToken = _cacher.getFcmToken();
//       if (userId != null && fcmToken != null) {
//         try {
//           await _firestore.removeToken(userId, fcmToken);
//         } catch (e) {
//           debugPrint('Failed to remove FCM token: $e');
//         }
//       }

//       await _cacher.logout();

//       // Navigate to splash screen on next frame to ensure proper state reset
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         final context = RouteConfig.navigatorKey.currentContext;
//         if (context != null && context.mounted) {
//           context.go('/');
//         }
//       });
//     }
//     return response;
//   }

//   // GET
//   static Future<http.Response> get(
//     String path, {
//     Map<String, String>? headers,
//   }) async {
//     debugPrint("GET $path");
//     return _handleResponse(
//       _client.get(_buildUri(path), headers: await _buildHeaders(headers)),
//     );
//   }

//   // POST
//   static Future<http.Response> post(
//     String path, {
//     Map<String, dynamic>? body,
//     Map<String, String>? headers,
//     bool useDomainUrl = false,
//     Duration? timeout,
//   }) async {
//     debugPrint("POST $path");

//     return _handleResponse(
//       _client
//           .post(
//             useDomainUrl ? _buildDomainUri(path) : _buildUri(path),
//             headers: await _buildHeaders(headers),
//             body: jsonEncode(body),
//           )
//           .timeout(
//             timeout ?? const Duration(seconds: 30),
//             onTimeout: () => throw TimeoutException(
//               'Request timed out after ${timeout?.inSeconds ?? 30} seconds',
//               timeout ?? const Duration(seconds: 30),
//             ),
//           ),
//     );
//   }

//   // PUT
//   static Future<http.Response> put(
//     String path, {
//     Map<String, dynamic>? body,
//     Map<String, String>? headers,
//   }) async {
//     return _handleResponse(
//       _client.put(
//         _buildUri(path),
//         headers: await _buildHeaders(headers),
//         body: jsonEncode(body),
//       ),
//     );
//   }

//   // DELETE
//   static Future<http.Response> delete(
//     String path, {
//     Map<String, String>? headers,
//   }) async {
//     return _handleResponse(
//       _client.delete(_buildUri(path), headers: await _buildHeaders(headers)),
//     );
//   }
// }
