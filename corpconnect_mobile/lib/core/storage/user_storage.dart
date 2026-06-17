import 'package:shared_preferences/shared_preferences.dart';

/// Stores logged-in user profile data from the login response.
class UserStorage {
  UserStorage._();

  static final UserStorage instance = UserStorage._();

  static const _nameKey = 'user_name';
  static const _emailKey = 'user_email';
  static const _userIdKey = 'user_id';
  static const _currentCityKey = 'user_current_city';
  static const _baseCityKey = 'user_base_city';
  static const _companyNameKey = 'company_name';
  static const _companyIdKey = 'company_id';

  Future<void> saveEmployeeData({
    required String name,
    required String email,
    required int userId,
    required String currentCity,
    required String baseCity,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_currentCityKey, currentCity);
    await prefs.setString(_baseCityKey, baseCity);
  }

  Future<void> saveCompanyData({
    required String companyName,
    required int userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_companyNameKey, companyName);
    await prefs.setInt(_userIdKey, userId);
  }

  Future<void> updateCurrentCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentCityKey, city);
  }

  Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  Future<String?> getCurrentCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentCityKey);
  }

  Future<String?> getBaseCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_baseCityKey);
  }

  Future<String?> getCompanyName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_companyNameKey);
  }

  Future<int?> getCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_companyIdKey);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_currentCityKey);
    await prefs.remove(_baseCityKey);
    await prefs.remove(_companyNameKey);
    await prefs.remove(_companyIdKey);
  }
}
