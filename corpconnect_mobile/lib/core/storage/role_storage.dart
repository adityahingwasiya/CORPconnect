import 'package:shared_preferences/shared_preferences.dart';

class RoleStorage {
  RoleStorage._();

  static final RoleStorage instance = RoleStorage._();

  static const _roleKey = 'user_role';

  Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  Future<void> clearRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleKey);
  }
}
