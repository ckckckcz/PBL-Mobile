import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class ProfileService {
  static const String _storageKey = 'user_profile';

  // Default user data
  static final UserModel _defaultUser = UserModel(
    name: 'Riana Salsabila',
    email: 'rianasalsabila@email.com',
    phone: '81234567890',
    birthDate: '23/05/2000',
  );

  Future<void> saveProfile(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(user.toJson()));
  }

  Future<UserModel> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString != null) {
      try {
        return UserModel.fromJson(jsonDecode(jsonString));
      } catch (e) {
        return _defaultUser;
      }
    }

    return _defaultUser;
  }
}
