import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pet.dart';
import '../models/daily_log.dart';
import '../models/user.dart';

/// Thrown for any non-2xx response, carrying the backend's
/// {"status":"error","message": "..."} payload when available.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

/// Thin wrapper around the "AI Wellness Pet" Go/Fiber backend.
///
/// ### Core Loop
/// 1. `registerUser()` — create or retrieve a user (idempotent).
/// 2. `setupPet()`     — initialise a pet for that user (onboarding).
/// 3. `logActivity()`  — record daily wellness → Logic Engine + Gemini AI.
/// 4. `getPet()`       — latest pet state.
/// 5. `getHistory()`   — last 10 activity logs.
///
/// ### Demo / Testing Utilities
/// - `resetPet()`         — set pet back to 50/50/Neutral.
/// - `simulateNeglect()`  — fast-forward to 20/20/Sad.
class ApiService {
  ApiService({required this.baseUrl});

  /// e.g. "https://ai-wellness-pet.onrender.com/api/v1"
  final String baseUrl;

  Uri _u(String path) => Uri.parse('$baseUrl$path');

  Map<String, dynamic> _decode(http.Response res) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      body = {};
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg = body['message'] as String? ??
          'Request failed (${res.statusCode})';
      throw ApiException(res.statusCode, msg);
    }
    return body;
  }

  // ─── Health ───────────────────────────────────────────────────────

  /// `GET /health` — returns true if the server responds 200.
  Future<bool> healthCheck() async {
    try {
      // /health is at the root, not under /api/v1
      final rootUrl = baseUrl.replaceAll('/api/v1', '');
      final res = await http.get(Uri.parse('$rootUrl/health'));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── User ─────────────────────────────────────────────────────────

  /// `POST /user/register` — idempotent. Returns the registered (or
  /// already-existing) [AppUser] with a backend-generated UUID.
  Future<AppUser> registerUser({
    required String name,
    required String email,
  }) async {
    final res = await http.post(
      _u('/user/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email}),
    );
    
    // If the endpoint isn't deployed to Render yet, fallback to the demo user.
    if (res.statusCode == 404) {
      return AppUser(
        id: '1f4dba8f-07c9-4aa3-9738-5b1c9ec18573',
        name: name,
        email: email,
      );
    }

    final body = _decode(res);
    return AppUser.fromJson(body['user'] as Map<String, dynamic>);
  }

  // ─── Pet ──────────────────────────────────────────────────────────

  Future<Pet> setupPet({required String userId, required String petName}) async {
    final res = await http.post(
      _u('/pet/setup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'pet_name': petName}),
    );
    final body = _decode(res);
    return Pet.fromJson(body['pet'] as Map<String, dynamic>);
  }

  Future<Pet> getPet(String userId) async {
    final res = await http.get(_u('/pet/$userId'));
    final body = _decode(res);
    return Pet.fromJson(body['pet'] as Map<String, dynamic>);
  }

  Future<Pet> resetPet(String userId) async {
    final res = await http.post(_u('/pet/$userId/reset'));
    final body = _decode(res);
    return Pet.fromJson(body['pet'] as Map<String, dynamic>);
  }

  Future<Pet> simulateNeglect(String userId) async {
    final res = await http.post(_u('/pet/$userId/simulate-neglect'));
    final body = _decode(res);
    return Pet.fromJson(body['pet'] as Map<String, dynamic>);
  }

  // ─── Activity ─────────────────────────────────────────────────────

  /// Returns the updated pet plus Milo's AI-generated message.
  Future<(Pet, String)> logActivity({
    required String userId,
    required int waterGlasses,
    required double sleepHours,
    required String journalText,
  }) async {
    final res = await http.post(
      _u('/activity'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'water_glasses': waterGlasses,
        'sleep_hours': sleepHours,
        'journal_text': journalText,
      }),
    );
    final body = _decode(res);
    final pet = Pet.fromJson(body['pet'] as Map<String, dynamic>);
    final aiMessage = body['ai_message'] as String? ?? '';
    return (pet, aiMessage);
  }

  Future<List<DailyLog>> getHistory(String userId) async {
    final res = await http.get(_u('/activity/$userId'));
    final body = _decode(res);
    final data = (body['data'] as List<dynamic>? ?? []);
    return data
        .map((e) => DailyLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
