import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:karsa_app/core/constants/app_constants.dart';
import 'package:karsa_app/models/karsa_store_data.dart';
import 'package:karsa_app/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('StorageService & @karsa-demo-v1 JSON compatibility', () {
    test('migrates legacy RN AsyncStorage JSON under @karsa-demo-v1', () async {
      final legacyJson = jsonEncode(<String, dynamic>{
        'teacherSubject': 'IPA',
        'darkMode': true,
        'studentName': 'Dimas Nugroho',
        'tasks': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'legacy-1',
            'subject': 'IPA',
            'title': 'Siklus Air',
            'className': 'Kelas 5',
            'minutes': '25',
          },
        ],
        'attendance': <String, dynamic>{
          '2026-11-14': <String, dynamic>{'dimas': 'Hadir'},
        },
        'classScores': <String, dynamic>{'dimas': 90},
      });

      SharedPreferences.setMockInitialValues(<String, Object>{
        AppConstants.storeKey: legacyJson,
      });

      const service = StorageService();
      final loaded = await service.load(now: DateTime(2026, 11, 14));

      expect(loaded.darkMode, isTrue);
      expect(
        loaded.teacherSubject,
        'Ilmu Pengetahuan Alam dan Sosial (IPAS)',
      );
      expect(
        loaded.tasks.firstWhere((t) => t.id == 'legacy-1').subject,
        'Ilmu Pengetahuan Alam dan Sosial (IPAS)',
      );
      // Missing seed tasks are backfilled automatically
      expect(loaded.tasks.any((t) => t.id == 't1'), isTrue);
      expect(loaded.attendance['2026-11-14']?['dimas'], 'Hadir');
      expect(loaded.classScores['dimas'], 90.0);

      final roundTrip = KarsaStoreData.fromSavedJson(loaded.toJson());
      expect(roundTrip.classScores['dimas'], 90.0);
    });
  });
}
