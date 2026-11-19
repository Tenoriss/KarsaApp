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

    test('kartu "Perjalanan belajar" orang tua ikut mode gelap', () {
      // Bug: warna keras #F8EDF0 dipakai apa adanya. Di mode gelap teks
      // memakai ink yang nyaris putih (#F3EAF0) -> kontras 1.03:1, teks
      // praktis hilang. Mapper harus mengubahnya jadi permukaan rose gelap.
      const hardCoded = Color(0xFFF8EDF0);
      final mapped = DarkColorMapper.surface(hardCoded, isDark: true);
      expect(mapped, const Color(0xFF493640));
      // Kontras terhadap ink gelap harus jauh di atas ambang 3:1.
      final c = mapped;
      final inkR = 0xF3 / 255.0, inkG = 0xEA / 255.0, inkB = 0xF0 / 255.0;
      double chan(double v) =>
          v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) * ((v + 0.055) / 1.055);
      double relLum(double r, double g, double b) =>
          0.2126 * chan(r) + 0.7152 * chan(g) + 0.0722 * chan(b);
      final bgLum = relLum(c.red / 255.0, c.green / 255.0, c.blue / 255.0);
      final inkLum = relLum(inkR, inkG, inkB);
      final ratio = (inkLum + 0.05) / (bgLum + 0.05);
      expect(ratio, greaterThan(4.5),
          reason: 'teks harus terbaca di atas kartu, dapat $ratio:1');
      // Mode terang tidak berubah sama sekali.
      expect(DarkColorMapper.surface(hardCoded, isDark: false), hardCoded);
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
