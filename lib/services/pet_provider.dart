import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';
import '../models/daily_log.dart';
import '../models/user.dart';
import 'api_service.dart';

/// Central app state: holds the current user/pet, today's in-progress
/// log values (for the "Log My Wellness" screen), and talks to the API.
///
/// Persists `user_id`, `user_name`, `user_email`, and `pet_name` locally
/// with shared_preferences so onboarding only happens once per device.
class PetProvider extends ChangeNotifier {
  PetProvider(this.api);

  final ApiService api;

  static const _kUserId = 'milos_corner.user_id';
  static const _kUserName = 'milos_corner.user_name';
  static const _kUserEmail = 'milos_corner.user_email';
  static const _kPetName = 'milos_corner.pet_name';
  static const _kOnboarded = 'milos_corner.onboarded';

  String? userId;
  String? userName;
  String? userEmail;
  Pet? pet;
  String lastAiMessage = "I'm feeling great because you're taking care of yourself!";
  List<DailyLog> history = [];

  bool isLoading = false;
  bool onboarded = false;
  String? error;

  // Draft values for today's log, edited on the Activities screen.
  int draftWater = 3;
  double draftSleepHours = 7.5;
  String draftJournal = '';

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(_kUserId);
    userName = prefs.getString(_kUserName);
    userEmail = prefs.getString(_kUserEmail);
    onboarded = prefs.getBool(_kOnboarded) ?? false;
    final petName = prefs.getString(_kPetName);
    if (userId != null) {
      pet = Pet.placeholder(userId: userId!, petName: petName ?? 'Milo');
    }
    notifyListeners();

    if (onboarded && userId != null) {
      await refreshPet();
      await refreshHistory();
    }
  }

  /// Full onboarding flow:
  /// 1. ~~Register user~~ (skipped — backend PR not deployed yet).
  /// 2. Setup pet via `POST /pet/setup`.
  ///
  /// TODO: Re-enable registration once the backend PR is merged.
  /// Replace the hardcoded `_kDemoUserId` with `api.registerUser()`.
  static const _kDemoUserId = '1f4dba8f-07c9-4aa3-9738-5b1c9ec18573';

  Future<void> completeOnboarding({
    required String userName,
    required String userEmail,
    required String petName,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Registration bypassed — use demo user ID until backend PR lands.
      final resolvedUserId = _kDemoUserId;

      // Setup pet with the demo user's ID.
      final createdPet = await api.setupPet(
        userId: resolvedUserId,
        petName: petName,
      );

      userId = resolvedUserId;
      this.userName = userName;
      this.userEmail = userEmail;
      pet = createdPet;
      onboarded = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kUserId, resolvedUserId);
      await prefs.setString(_kUserName, userName);
      await prefs.setString(_kUserEmail, userEmail);
      await prefs.setString(_kPetName, petName);
      await prefs.setBool(_kOnboarded, true);

      await refreshHistory();
    } on ApiException catch (e) {
      error = e.message;
    } catch (e) {
      error = 'Could not reach the server. Check your connection.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshPet() async {
    if (userId == null) return;
    try {
      pet = await api.getPet(userId!);
      notifyListeners();
    } on ApiException catch (e) {
      error = e.message;
      notifyListeners();
    } catch (_) {
      // Silent: keep showing the last known pet state if offline.
    }
  }

  Future<void> refreshHistory() async {
    if (userId == null) return;
    try {
      history = await api.getHistory(userId!);
      notifyListeners();
    } on ApiException catch (e) {
      error = e.message;
      notifyListeners();
    } catch (_) {
      // Silent: history is non-critical, keep whatever we had.
    }
  }

  void setDraftWater(int glasses) {
    draftWater = glasses.clamp(0, 12);
    notifyListeners();
  }

  void setDraftSleep(double hours) {
    draftSleepHours = hours.clamp(0, 12);
    notifyListeners();
  }

  void setDraftJournal(String text) {
    draftJournal = text;
  }

  /// Submits today's check-in (the "Check-in with Milo" button).
  Future<bool> checkIn() async {
    if (userId == null) return false;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final (updatedPet, aiMessage) = await api.logActivity(
        userId: userId!,
        waterGlasses: draftWater,
        sleepHours: draftSleepHours,
        journalText: draftJournal,
      );
      pet = updatedPet;
      lastAiMessage = aiMessage.isNotEmpty ? aiMessage : lastAiMessage;

      // Reset draft values after successful check-in.
      draftWater = 3;
      draftSleepHours = 7.5;
      draftJournal = '';

      await refreshHistory();
      return true;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } catch (e) {
      error = 'Could not reach the server. Check your connection.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPet() async {
    if (userId == null) return;
    try {
      pet = await api.resetPet(userId!);
      notifyListeners();
    } on ApiException catch (e) {
      error = e.message;
      notifyListeners();
    }
  }

  Future<void> simulateNeglect() async {
    if (userId == null) return;
    try {
      pet = await api.simulateNeglect(userId!);
      notifyListeners();
    } on ApiException catch (e) {
      error = e.message;
      notifyListeners();
    }
  }

  /// Clears all local state and shared_preferences, returning the user
  /// to onboarding. Useful for testing or "log out".
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserId);
    await prefs.remove(_kUserName);
    await prefs.remove(_kUserEmail);
    await prefs.remove(_kPetName);
    await prefs.remove(_kOnboarded);

    userId = null;
    userName = null;
    userEmail = null;
    pet = null;
    history = [];
    onboarded = false;
    error = null;
    lastAiMessage = "I'm feeling great because you're taking care of yourself!";
    draftWater = 3;
    draftSleepHours = 7.5;
    draftJournal = '';
    notifyListeners();
  }
}
