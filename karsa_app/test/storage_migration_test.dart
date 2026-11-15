import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:karsa_app/core/constants/app_constants.dart';
import 'package:karsa_app/models/karsa_store_data.dart';
import 'package:karsa_app/models/operator_profile.dart';
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

    test('profil operator bertahan setelah simpan dan muat ulang', () {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final fresh = KarsaStoreData.defaults();
      expect(fresh.operatorProfile.nip, '19870003');
      expect(fresh.operatorProfile.unit, 'SD Karitas Purwokerto');
      expect(fresh.operatorProfile.email, isEmpty);

      final saved = fresh.copyWith(
        operatorName: 'Sari Operator',
        operatorProfile: fresh.operatorProfile.copyWith(
          name: 'Sari Operator',
          nip: '19870099',
          role: 'Operator Data',
          email: 'sari@sekolah.sch.id',
          phone: '081234567890',
          unit: 'SD Karitas Purwokerto',
        ),
      );
      final loaded = KarsaStoreData.fromSavedJson(saved.toJson());
      expect(loaded.operatorName, 'Sari Operator');
      expect(loaded.operatorProfile.nip, '19870099');
      expect(loaded.operatorProfile.role, 'Operator Data');
      expect(loaded.operatorProfile.email, 'sari@sekolah.sch.id');
      expect(loaded.operatorProfile.phone, '081234567890');
    });

    test('store lama tanpa operatorProfile tetap terbaca', () {
      // Data tersimpan sebelum profil operator ada: hanya ada operatorName.
      final legacy = <String, dynamic>{
        'operatorName': 'Pak Lama',
      };
      final loaded = KarsaStoreData.fromSavedJson(legacy);
      expect(loaded.operatorName, 'Pak Lama');
      // Nama dari data lama dipakai, kolom lain memakai nilai bawaan.
      expect(loaded.operatorProfile.name, 'Pak Lama');
      expect(loaded.operatorProfile.nip, '19870003');
      expect(loaded.operatorProfile.unit, 'SD Karitas Purwokerto');
    });

    test('inisial dan kelengkapan profil operator dihitung benar', () {
      const full = OperatorProfile(
        name: 'Sari Operator',
        nip: '19870099',
        role: 'Operator Sekolah',
        email: 'sari@sekolah.sch.id',
        phone: '081234567890',
        unit: 'SD Karitas Purwokerto',
      );
      expect(full.initials, 'SO');
      expect(full.filledFields, OperatorProfile.totalFields);
      expect(full.hasContact, isTrue);

      const minimal = OperatorProfile(name: 'Sari');
      expect(minimal.initials, 'S');
      expect(minimal.hasContact, isFalse);
      expect(minimal.filledFields, 1);
    });
  });
}
