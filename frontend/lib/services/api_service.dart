import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Base URL - GANTI DENGAN IP/URL SERVER ANDA
  // Untuk development local:
  // - Android Emulator: http://10.0.2.2:8000
  // - iOS Simulator: http://localhost:8000
  // - Physical Device: http://YOUR_COMPUTER_IP:8000
  static const String baseUrl = 'http://192.168.58.137:8000';
  // static const String baseUrl = 'http://192.168.1.100:8000';

  // Endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String forgotPasswordEndpoint = '/api/auth/forgot-password';
  static const String resetPasswordEndpoint = '/api/auth/reset-password';
  static const String changePasswordEndpoint = '/api/auth/change-password';
  static const String meEndpoint = '/api/auth/me';
  static const String logoutEndpoint = '/api/auth/logout';
  static const String predictEndpoint = '/api/predict';

  // SharedPreferences keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String userNameKey = 'user_name';

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Save token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // Clear token (logout)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userIdKey);
    await prefs.remove(userEmailKey);
    await prefs.remove(userNameKey);
  }

  // Save user data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userIdKey, userData['id'] ?? '');
    await prefs.setString(userEmailKey, userData['email'] ?? '');
    await prefs.setString(userNameKey, userData['full_name'] ?? '');
  }

  // Get user data
  Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString(userIdKey),
      'email': prefs.getString(userEmailKey),
      'name': prefs.getString(userNameKey),
    };
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Get headers with authorization
  Future<Map<String, String>> _getHeaders({bool includeAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ============================================================================
  // AUTH ENDPOINTS
  // ============================================================================

  /// Login user
  /// Returns: {success, message, data, token}
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$loginEndpoint');
      final body = json.encode({
        'email': email,
        'password': password,
      });

      print('[API] POST $url');
      print('[API] Body: $body');

      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: body,
      );

      print('[API] Response status: ${response.statusCode}');
      print('[API] Response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Save token and user data
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        if (data['data'] != null) {
          await saveUserData(data['data']);
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Login berhasil',
          'data': data['data'],
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      print('[API] Error during login: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Register new user
  /// Returns: {success, message, data, token}
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$registerEndpoint');
      final body = json.encode({
        'email': email,
        'password': password,
        'full_name': fullName,
        'phone': phone,
      });

      print('[API] POST $url');
      print('[API] Body: $body');

      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: body,
      );

      print('[API] Response status: ${response.statusCode}');
      print('[API] Response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Save token and user data
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        if (data['data'] != null) {
          await saveUserData(data['data']);
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Registrasi berhasil',
          'data': data['data'],
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Registrasi gagal',
        };
      }
    } catch (e) {
      print('[API] Error during registration: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Forgot password
  /// Returns: {success, message}
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$forgotPasswordEndpoint');
      final body = json.encode({
        'email': email,
      });

      print('[API] POST $url');
      print('[API] Body: $body');

      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: body,
      );

      print('[API] Response status: ${response.statusCode}');
      print('[API] Response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Email reset password telah dikirim',
        };
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Gagal mengirim email reset password',
        };
      }
    } catch (e) {
      print('[API] Error during forgot password: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Reset password (for forgot password flow)
  /// Returns: {success, message}
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$resetPasswordEndpoint');
      final body = json.encode({
        'email': email,
        'new_password': newPassword,
      });

      print('[API] POST $url');
      print(
          '[API] Body: ${body.replaceAll('"new_password": "$newPassword"', '"new_password": "***"')}');

      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: body,
      );

      print('[API] Response status: ${response.statusCode}');
      print('[API] Response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Kata sandi berhasil diubah',
        };
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Gagal mengubah kata sandi',
        };
      }
    } catch (e) {
      print('[API] Error during reset password: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Change password
  /// Returns: {success, message}
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$changePasswordEndpoint');
      final body = json.encode({
        'current_password': currentPassword,
        'new_password': newPassword,
      });

      print('[API] POST $url');
      print(
          '[API] Body: ${body.replaceAll('"current_password": "${currentPassword}"', '"current_password": "***"')}');

      final response = await http.post(
        url,
        headers: await _getHeaders(includeAuth: true),
        body: body,
      );

      print('[API] Response status: ${response.statusCode}');
      print('[API] Response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Kata sandi berhasil diubah',
        };
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Gagal mengubah kata sandi',
        };
      }
    } catch (e) {
      print('[API] Error during change password: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Get current user data
  /// Returns: {success, data}
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final url = Uri.parse('$baseUrl$meEndpoint');

      print('[API] GET $url');

      final response = await http.get(
        url,
        headers: await _getHeaders(includeAuth: true),
      );

      print('[API] Response status: ${response.statusCode}');
      print('[API] Response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Gagal mengambil data user',
        };
      }
    } catch (e) {
      print('[API] Error getting current user: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Logout user
  Future<Map<String, dynamic>> logout() async {
    try {
      final url = Uri.parse('$baseUrl$logoutEndpoint');

      print('[API] POST $url');

      final response = await http.post(
        url,
        headers: await _getHeaders(includeAuth: true),
      );

      print('[API] Response status: ${response.statusCode}');

      // Clear local storage regardless of server response
      await clearToken();

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Logout berhasil',
        };
      } else {
        return {
          'success': true, // Still return success since local data is cleared
          'message': 'Logout berhasil',
        };
      }
    } catch (e) {
      print('[API] Error during logout: $e');
      // Still clear local data
      await clearToken();
      return {
        'success': true,
        'message': 'Logout berhasil',
      };
    }
  }

  // ============================================================================
  // PREDICTION ENDPOINT
  // ============================================================================

  /// Predict waste category from image
  /// Returns: {success, prediction, confidence, category, tips}
  Future<Map<String, dynamic>> predictWaste(String imagePath) async {
    try {
      final url = Uri.parse('$baseUrl$predictEndpoint');

      print('[API] POST $url (multipart)');
      print('[API] Image path: $imagePath');

      var request = http.MultipartRequest('POST', url);

      // Add authorization header if logged in
      final token = await getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add image file dengan Content-Type yang tepat
      final file = await http.MultipartFile.fromPath('file', imagePath);

      // Tentukan content-type berdasarkan file extension
      final extension = imagePath.toLowerCase().split('.').last;
      String contentType = 'image/jpeg'; // default

      if (extension == 'png') {
        contentType = 'image/png';
      } else if (extension == 'gif') {
        contentType = 'image/gif';
      } else if (extension == 'webp') {
        contentType = 'image/webp';
      }

      // Buat MultipartFile dengan content-type yang benar
      final imageFile = http.MultipartFile(
        'file',
        file.finalize(),
        file.length,
        filename: file.filename,
        contentType: MediaType('image', extension),
      );

      request.files.add(imageFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('[API] Response status: ${response.statusCode}');
      print('[API] Response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Backend returns {success: true, data: {wasteType, category, confidence, tips, description, modelInfo}}
        final data = responseData['data'];
        return {
          'success': true,
          'data': {
            'wasteType': data['wasteType'],
            'category': data['category'],
            'confidence': data['confidence'],
            'tips': data['tips'],
            'description': data['description'],
          },
        };
      } else {
        return {
          'success': false,
          'message': responseData['detail'] ?? 'Prediksi gagal',
        };
      }
    } catch (e) {
      print('[API] Error during prediction: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // ============================================================================
  // HEALTH CHECK
  // ============================================================================

  /// Test API connection
  Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$baseUrl/health');
      print('[API] GET $url');

      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      print('[API] Response status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('[API] Connection test failed: $e');
      return false;
    }
  }
}
