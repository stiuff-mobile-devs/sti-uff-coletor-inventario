import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:stiuffcoletorinventario/core/models/inventory_item.dart';
import 'package:stiuffcoletorinventario/core/models/package_model.dart';
import 'package:stiuffcoletorinventario/core/providers/inventory_provider.dart';

class PdfReportController extends ChangeNotifier {
  Future<void> openPdf(File file) async {
    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      debugPrint('Erro ao abrir o arquivo PDF.');
    }
  }

  Future<File> generatePdf(
    BuildContext context,
    String selectedOption,
    String selectedDateRange,
  ) async {
    final pdf = pw.Document();
    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);

    List<InventoryItem> items = inventoryProvider.items;
    List<PackageModel> packages = inventoryProvider.packages;

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Column(
            children: [
              pw.Text('Relatório de Inventário',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Total de Itens: ${items.length}',
                  style: const pw.TextStyle(fontSize: 18)),
              pw.Text('Última Atualização: ${DateTime.now().toString()}',
                  style: const pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(children: [
                    pw.Text('Código de Barras',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Nome',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Descrição',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Localização',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Imagens',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ]),
                  ...items.map(
                    (item) {
                      return pw.TableRow(children: [
                        pw.Text(item.barcode),
                        pw.Text(item.name),
                        pw.Text(item.description ?? 'N/A'),
                        pw.Text(item.location),
                        pw.Text(item.images?.join(', ') ?? 'Sem imagens'),
                      ]);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ));

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/relatorio_inventario.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
