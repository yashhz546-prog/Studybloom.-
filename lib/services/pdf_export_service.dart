import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/daily_entry.dart';

/// Builds a simple, clean monthly progress summary and hands it to the
/// system print/share sheet (works for both "save as PDF" and printing).
class PdfExportService {
  Future<void> exportMonth(DateTime month, List<DailyEntry> entries) async {
    final scored = entries.where((e) {
      final d = DateFormat('yyyy-MM-dd').parse(e.dateKey);
      return e.score != null && d.year == month.year && d.month == month.month;
    }).toList()
      ..sort((a, b) => a.dateKey.compareTo(b.dateKey));

    final doc = pw.Document();
    final avg = scored.isEmpty
        ? 0
        : scored.map((e) => e.score!).reduce((a, b) => a + b) / scored.length;

    doc.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'StudyBloom — ${DateFormat('MMMM yyyy').format(month)}',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text('Monthly average score: ${avg.toStringAsFixed(1)} / 100'),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Date', 'Homework', 'Self Study', 'Activity', 'Phone', 'Score'],
                data: scored.map((e) {
                  return [
                    e.dateKey,
                    '${e.completedHomeworkCount}/${kSubjects.length}',
                    '${e.selfStudyMinutes ?? 0} min',
                    e.physicalActivity.label,
                    '${e.phoneUsageMinutes ?? 0} min',
                    '${e.score}',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'studybloom_${DateFormat('yyyy_MM').format(month)}.pdf',
    );
  }
}
