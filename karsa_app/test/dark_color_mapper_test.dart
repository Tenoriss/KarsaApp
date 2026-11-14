import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karsa_app/core/theme/dark_color_mapper.dart';
import 'package:karsa_app/models/grade_report_row.dart';
import 'package:karsa_app/services/grade_export_service.dart';

void main() {
  group('DarkColorMapper & GradeExportService', () {
    test('maps rose, blue, and neutral pastel surfaces to dark equivalents', () {
      expect(
        DarkColorMapper.surface(const Color(0xFFF9EBEE), isDark: true),
        const Color(0xFF493640),
      );
      expect(
        DarkColorMapper.surface(const Color(0xFFE5F0F8), isDark: true),
        const Color(0xFF34414E),
      );
      expect(
        DarkColorMapper.surface(const Color(0xFFFFFDFB), isDark: true),
        const Color(0xFF332D36),
      );
      expect(
        DarkColorMapper.border(const Color(0xE0FFFFFF), isDark: true),
        const Color(0xFF554A54),
      );
    });

    test('builds non-empty XLSX and PDF byte streams', () async {
      const exporter = GradeExportService();
      const payload = GradeReportPayload(
        className: 'Kelas 5',
        subject: 'Matematika',
        teacher: 'Ibu Sari',
        rows: <GradeReportRow>[
          GradeReportRow(
            name: 'Dimas Nugroho',
            task: 'Pecahan dan perbandingan',
            grade: 80,
            note: 'Hasil lokal',
          ),
        ],
      );

      final xlsx = exporter.buildExcelBytes(payload);
      final pdf = await exporter.buildPdfBytes(payload);
      expect(xlsx.isNotEmpty, isTrue);
      expect(pdf.isNotEmpty, isTrue);
    });
  });
}
