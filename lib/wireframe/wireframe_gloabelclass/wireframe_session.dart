import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ════════════════════════════════════════════════════════════════════════════
// PERSISTENT LOGIN SESSION — SECURE STORAGE
//
// Per the API guide's "Token Persistence" section, the token must never be
// stored in plain SharedPreferences/local storage — it needs Keychain
// (iOS) / Keystore (Android) backed secure storage. FlutterSecureStorage
// is used here for exactly that.
// ════════════════════════════════════════════════════════════════════════════
class WireframeSession {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
  );

  static const String _keyToken = 'auth_token';
  static const String _keyRole = 'user_role'; // 'student' | 'driver'

  static String? _cachedToken;

  /// Called right after a successful login (student or driver) to persist
  /// the real backend token.
  static Future<void> saveSession({required String token, required String role}) async {
    _cachedToken = token;
    try {
      await _storage.write(key: _keyToken, value: token);
      await _storage.write(key: _keyRole, value: role);
    } catch (_) {}
  }

  /// Synchronous fast getter if token is already in memory
  static String? get cachedToken => _cachedToken;

  /// Retrieves the persisted token securely.
  static Future<String?> getToken() async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty) return _cachedToken;
    try {
      final token = await _storage.read(key: _keyToken);
      if (token != null && token.isNotEmpty) {
        _cachedToken = token;
        return _cachedToken;
      }
    } catch (_) {}
    return null;
  }

  /// Called from the splash screen to check whether a valid session already
  /// exists.
  static Future<Map<String, String>?> getSession() async {
    try {
      final role = await _storage.read(key: _keyRole);
      if (role == null || role.isEmpty) return null;

      final token = await getToken();
      if (token == null || token.isEmpty) return null;

      return {'role': role, 'token': token};
    } catch (_) {
      return null;
    }
  }

  /// Only called when the user explicitly taps "Logout".
  static Future<void> clearSession() async {
    _cachedToken = null;
    try {
      await _storage.delete(key: _keyToken);
      await _storage.delete(key: _keyRole);
    } catch (_) {}
  }
}
