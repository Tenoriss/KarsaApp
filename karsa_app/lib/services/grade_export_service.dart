import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/grade_report_row.dart';
import 'file_bridge.dart';

/// Port 1:1 dari `gradeReports.js` (`buildGradeReport` + `exportGrades` di App.js).
/// Menghasilkan file Excel (.xlsx) dan PDF (842×595 pt landscape) yang benar-benar valid.
class GradeExportService {
  const GradeExportService();

  static const List<String> headers = <String>[
    'Nama siswa',
    'Kelas',
    'Mata pelajaran',
    'Tugas',
    'Nilai (0–100)',
    'Keterangan',
  ];

  String _cleanPdfText(String value) {
    return value.replaceAll(RegExp(r'[^\x20-\x7e\xa0-\xff]'), '-');
  }

  Uint8List buildExcelBytes(GradeReportPayload report) {
    final excel = Excel.createExcel();
    const sheetName = 'Rekap Nilai';
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null && defaultSheet != sheetName) {
      excel.rename(defaultSheet, sheetName);
    }
    final sheet = excel[sheetName];

    sheet.appendRow(<CellValue>[TextCellValue('REKAP NILAI KARSA - DATA DEMO')]);
    sheet.appendRow(<CellValue>[TextCellValue('Kelas'), TextCellValue(report.className)]);
    sheet.appendRow(<CellValue>[TextCellValue('Mata pelajaran'), TextCellValue(report.subject)]);
    sheet.appendRow(<CellValue>[TextCellValue('Guru'), TextCellValue(report.teacher)]);
    sheet.appendRow(<CellValue>[
      TextCellValue('Data lokal, bukan nilai resmi. Nilai kosong berarti belum ada nilai.'),
    ]);
    sheet.appendRow(<CellValue>[]);
    sheet.appendRow(headers.map(TextCellValue.new).toList());

    for (final r in report.rows) {
      sheet.appendRow(<CellValue?>[
        TextCellValue(r.name),
        TextCellValue(report.className),
        TextCellValue(report.subject),
        TextCellValue(r.task),
        r.grade == null ? null : DoubleCellValue(r.grade!),
        TextCellValue(r.note),
      ]);
    }

    final colWidths = <double>[25, 12, 32, 42, 18, 40];
    for (int i = 0; i < colWidths.length; i++) {
      sheet.setColumnWidth(i, colWidths[i]);
    }

    final encoded = excel.encode();
    if (encoded == null) {
      throw StateError('Gagal membuat berkas Excel.');
    }
    return Uint8List.fromList(encoded);
  }

  Future<Uint8List> buildPdfBytes(GradeReportPayload report) async {
    final doc = pw.Document();
    const pageFormat = PdfPageFormat(842, 595, marginAll: 30);

    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            pw.Text(
              'REKAP NILAI KARSA - DATA DEMO',
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
                color: const PdfColor(0.15, 0.18, 0.23),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              _cleanPdfText(
                'Kelas: ${report.className}    Mata pelajaran: ${report.subject}    Guru: ${report.teacher}',
              ),
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColor(0.15, 0.18, 0.23),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Data lokal, bukan nilai resmi. Nilai kosong berarti belum ada nilai.',
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColor(0.15, 0.18, 0.23),
              ),
            ),
            pw.SizedBox(height: 12),
          ],
        ),
        build: (context) {
          if (report.rows.isEmpty) {
            return <pw.Widget>[
              pw.Text(
                'Belum ada tugas pada kelas dan mata pelajaran ini.',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ];
          }
          return <pw.Widget>[
            pw.TableHelper.fromTextArray(
              border: const pw.TableBorder(
                horizontalInside: pw.BorderSide(color: PdfColor(0.85, 0.85, 0.85), width: 0.4),
                top: pw.BorderSide(color: PdfColor(0.7, 0.7, 0.7), width: 0.5),
                bottom: pw.BorderSide(color: PdfColor(0.7, 0.7, 0.7), width: 0.5),
              ),
              headerStyle: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: const PdfColor(0.15, 0.18, 0.23),
              ),
              cellStyle: const pw.TextStyle(
                fontSize: 9,
                color: PdfColor(0.15, 0.18, 0.23),
              ),
              columnWidths: const <int, pw.TableColumnWidth>{
                0: pw.FixedColumnWidth(175),
                1: pw.FixedColumnWidth(310),
                2: pw.FixedColumnWidth(60),
                3: pw.FlexColumnWidth(),
              },
              headers: const <String>['Nama siswa', 'Tugas', 'Nilai', 'Keterangan'],
              data: report.rows
                  .map(
                    (r) => <String>[
                      _cleanPdfText(r.name),
                      _cleanPdfText(r.task),
                      r.grade == null ? '-' : _cleanPdfText(r.formattedGrade),
                      _cleanPdfText(r.note),
                    ],
                  )
                  .toList(),
            ),
          ];
        },
      ),
    );

    return await doc.save();
  }

  String buildFileName({
    required String className,
    required String subject,
    required bool isExcel,
  }) {
    final ext = isExcel ? 'xlsx' : 'pdf';
    final cleanClass = className.replaceAll(RegExp(r'\s+'), '-');
    var cleanSubj = subject.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '-').replaceAll(RegExp(r'-+$'), '');
    if (cleanSubj.length > 45) {
      cleanSubj = cleanSubj.substring(0, 45);
    }
    return 'KARSA-Rekap-$cleanClass-$cleanSubj.$ext';
  }

  Future<String> exportAndShare({
    required String format, // 'Excel' | 'PDF'
    required GradeReportPayload report,
  }) async {
    final isExcel = format == 'Excel';
    if (!isExcel && format != 'PDF') {
      throw ArgumentError('Format ekspor tidak dikenal: $format');
    }

    final Uint8List bytes =
        isExcel ? buildExcelBytes(report) : await buildPdfBytes(report);
    final mime = isExcel
        ? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        : 'application/pdf';
    final fileName = buildFileName(
      className: report.className,
      subject: report.subject,
      isExcel: isExcel,
    );

    final tempPath = await FileBridge.writeTempExport(
      isWeb: kIsWeb,
      fileName: fileName,
      bytes: bytes,
    );

    if (tempPath != null) {
      await Share.shareXFiles(
        <XFile>[XFile(tempPath, name: fileName, mimeType: mime)],
        subject: 'Bagikan rekap ${report.className}',
      );
      return 'Pilih penerima di menu berbagi perangkat. Aplikasi tidak mengirim otomatis.';
    } else {
      await Share.shareXFiles(
        <XFile>[XFile.fromData(bytes, name: fileName, mimeType: mime)],
        subject: 'Bagikan rekap ${report.className}',
      );
      return 'File diunduh. Bagikan secara manual kepada wali kelas yang sesuai.';
    }
  }
}
