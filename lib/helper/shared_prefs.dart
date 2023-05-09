import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsProvider = Provider<SharedPrefs>((ref) => SharedPrefs());

class SharedPrefs {
  static SharedPreferences? _preferences;

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static const String KEY_LICENSE_KEY = "key_license_key";
  static const String KEY_FREE_CREDITS_COUNT = "key_free_credits_count";

  Future setLicenseKey(String licenseKey) async {
    await _preferences?.setString(KEY_LICENSE_KEY, licenseKey);
  }

  String? getLicenseKey() => _preferences?.getString(KEY_LICENSE_KEY);

  Future removeLicenseKey() async {
    await _preferences?.remove(KEY_LICENSE_KEY);
  }

  Future setFreeCreditsCount(int count) async {
    await _preferences?.setInt(KEY_FREE_CREDITS_COUNT, count);
  }

  int? getFreeCreditsCount() => _preferences?.getInt(KEY_FREE_CREDITS_COUNT);
}
