import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/karsa_store_data.dart';

class StorageService {
  final SharedPreferences? _injectedPrefs;

  const StorageService({SharedPreferences? prefs}) : _injectedPrefs = prefs;

  Future<SharedPreferences> _prefs() async {
    return _injectedPrefs ?? await SharedPreferences.getInstance();
  }

  /// Membaca JSON pada kunci "@karsa-demo-v1" (kompatibel 1:1 dengan AsyncStorage RN).
  Future<KarsaStoreData> load({DateTime? now}) async {
    try {
      final prefs = await _prefs();
      final raw = prefs.getString(AppConstants.storeKey);
      if (raw == null || raw.isEmpty) {
        return KarsaStoreData.defaults(now: now);
      }
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return KarsaStoreData.fromSavedJson(decoded, now: now);
      }
      if (decoded is Map) {
        return KarsaStoreData.fromSavedJson(
          decoded.map((k, v) => MapEntry(k.toString(), v)),
          now: now,
        );
      }
      return KarsaStoreData.defaults(now: now);
    } catch (_) {
      return KarsaStoreData.defaults(now: now);
    }
  }

  /// Menyimpan seluruh state ke kunci "@karsa-demo-v1".
  Future<bool> save(KarsaStoreData data) async {
    try {
      final prefs = await _prefs();
      final encoded = jsonEncode(data.toJson());
      return await prefs.setString(AppConstants.storeKey, encoded);
    } catch (_) {
      return false;
    }
  }

  int estimateSerializedLength(KarsaStoreData data) {
    try {
      return jsonEncode(data.toJson()).length;
    } catch (_) {
      return 0;
    }
  }
}
