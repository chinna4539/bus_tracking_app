import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateProvider extends ChangeNotifier {
  int _selectedTab = 0;
  ThemeMode _themeMode = ThemeMode.light;
  String _profileName = 'chinna';
  String _profileEmail = 'karrichinna631@gmail.com';
  String _profilePhone = '+91 9014733260';

  int get selectedTab => _selectedTab;
  ThemeMode get themeMode => _themeMode;
  String get profileName => _profileName;
  String get profileEmail => _profileEmail;
  String get profilePhone => _profilePhone;

  Future<void> loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? ThemeMode.light.index;
    _themeMode = ThemeMode.values[themeIndex];
    _profileName = prefs.getString('profileName') ?? _profileName;
    _profileEmail = prefs.getString('profileEmail') ?? _profileEmail;
    _profilePhone = prefs.getString('profilePhone') ?? _profilePhone;
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    if (name != null) _profileName = name;
    if (email != null) _profileEmail = email;
    if (phone != null) _profilePhone = phone;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileName', _profileName);
    await prefs.setString('profileEmail', _profileEmail);
    await prefs.setString('profilePhone', _profilePhone);
    notifyListeners();
  }

  void updateSelectedTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }
}
