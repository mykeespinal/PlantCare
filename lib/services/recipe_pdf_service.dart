import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/recipe.dart';

class RecipePdfService {
  static Future<void> download({
    required PlantRecipe recipe,
    required String categoryName,
  }) async {
    final document = pw.Document();
    const forest = PdfColor.fromInt(0xFF245B45);
    const paleSage = PdfColor.fromInt(0xFFE7F0E5);
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(42),
        header: (_) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: paleSage, width: 2),
            ),
          ),
          child: pw.Row(
            children: [
              pw.Text(
                'PLANTAS MEDICINALES',
                style: pw.TextStyle(
                  color: forest,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              pw.Spacer(),
              pw.Text(
                categoryName,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ),
        build: (_) => [
          pw.SizedBox(height: 24),
          pw.Text(
            recipe.title,
            style: pw.TextStyle(
              color: forest,
              fontSize: 25,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Categoría: $categoryName'
            '${recipe.plantName.isEmpty ? '' : '  ·  Planta: ${recipe.plantName}'}',
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 22),
          _section('Ingredientes', recipe.ingredients, forest, numbered: false),
          pw.SizedBox(height: 18),
          _section('Preparación', recipe.steps, forest, numbered: true),
          pw.SizedBox(height: 18),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: const pw.BoxDecoration(
              color: paleSage,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Beneficio esperado',
                  style: pw.TextStyle(
                    color: forest,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(recipe.result, style: const pw.TextStyle(fontSize: 11)),
              ],
            ),
          ),
          pw.SizedBox(height: 22),
          pw.Text(
            'Aviso: contenido educativo. No sustituye la valoración, el '
            'diagnóstico ni las indicaciones de un profesional de salud.',
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );

    final safeName = recipe.title
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    await Printing.sharePdf(
      bytes: await document.save(),
      filename: '${safeName.isEmpty ? 'receta' : safeName}.pdf',
    );
  }

  static pw.Widget _section(
    String title,
    List<String> lines,
    PdfColor forest, {
    required bool numbered,
  }) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        title,
        style: pw.TextStyle(
          color: forest,
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 10),
      ...lines.asMap().entries.map(
        (entry) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 7),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: 24,
                child: pw.Text(
                  numbered ? '${entry.key + 1}.' : '•',
                  style: pw.TextStyle(
                    color: forest,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Text(entry.value, style: const pw.TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
