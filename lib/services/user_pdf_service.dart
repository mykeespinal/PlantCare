import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/app_user.dart';

class UserPdfService {
  static Future<void> printUsers(List<AppUser> users) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'Plantas Medicinales — usuarios',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['Nombre', 'Correo', 'Rol', 'Estado'],
            data: users
                .map(
                  (user) => [
                    user.fullName,
                    user.email,
                    user.role,
                    user.status == 'active' ? 'Activo' : 'Inactivo',
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green100),
            cellPadding: const pw.EdgeInsets.all(7),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(
      onLayout: (_) async => document.save(),
      name: 'usuarios_plantas_medicinales.pdf',
    );
  }
}
