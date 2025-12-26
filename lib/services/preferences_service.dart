import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _cycleLengthKey = 'cycle_length';
  static const String _periodDurationKey = 'period_duration';
  static const String _userIdKey = 'user_id';
  static const String _lastPeriodDateKey = 'last_period_date';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Premier lancement
  bool get isFirstLaunch => _prefs.getBool(_isFirstLaunchKey) ?? true;

  Future<void> setFirstLaunchCompleted() async {
    await _prefs.setBool(_isFirstLaunchKey, false);
  }

  // Configuration du cycle
  int get cycleLength => _prefs.getInt(_cycleLengthKey) ?? 28;

  Future<void> setCycleLength(int value) async {
    await _prefs.setInt(_cycleLengthKey, value);
  }

  int get periodDuration => _prefs.getInt(_periodDurationKey) ?? 5;

  Future<void> setPeriodDuration(int value) async {
    await _prefs.setInt(_periodDurationKey, value);
  }

  String get userId => _prefs.getString(_userIdKey) ?? 'default_user';

  Future<void> setUserId(String value) async {
    await _prefs.setString(_userIdKey, value);
  }

  DateTime? get lastPeriodDate {
    final dateStr = _prefs.getString(_lastPeriodDateKey);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  Future<void> setLastPeriodDate(DateTime date) async {
    await _prefs.setString(_lastPeriodDateKey, date.toIso8601String());
  }

  // Sauvegarder la configuration complète
  Future<void> saveConfiguration({
    required int cycleLength,
    required int periodDuration,
    DateTime? lastPeriodDate,
  }) async {
    await setCycleLength(cycleLength);
    await setPeriodDuration(periodDuration);
    if (lastPeriodDate != null) {
      await setLastPeriodDate(lastPeriodDate);
    }
    await setFirstLaunchCompleted();
  }
}
