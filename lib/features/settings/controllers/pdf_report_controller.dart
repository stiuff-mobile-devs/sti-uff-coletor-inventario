import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:stiuffcoletorinventario/core/models/inventory_item.dart';
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

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Column(
            children: [
              pw.Text('Relatório de Inventário',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Nº de Itens Catalogados: ${items.length}',
                  style: const pw.TextStyle(fontSize: 18)),
              pw.Text(
                  'Última Atualização: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Table(
                        border: pw.TableBorder.all(),
                        children: List.generate(8, (rowIndex) {
                          return pw.TableRow(
                            children: List.generate(1, (colIndex) {
                              return pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                // Tabela Aninhada
                                child: pw.Table(
                                  border: pw.TableBorder.all(),
                                  children: List.generate(1, (innerRowIndex) {
                                    if (rowIndex == 2 || rowIndex == 6) {
                                      return pw.TableRow(
                                        children:
                                            List.generate(1, (innerColIndex) {
                                          return pw.Padding(
                                            padding: const pw.EdgeInsets.all(4),
                                            child: pw.Text('Célula Mesclada'),
                                          );
                                        }),
                                      );
                                    }
                                    return pw.TableRow(
                                      children:
                                          List.generate(2, (innerColIndex) {
                                        return pw.Padding(
                                          padding: const pw.EdgeInsets.all(4),
                                          child: pw.Text(
                                              'R${rowIndex + 1}C${innerColIndex + 1}'),
                                        );
                                      }),
                                    );
                                  }),
                                ),
                              );
                            }),
                          );
                        }),
                      ),
                      pw.Column(
                        children: [
                          // Tabela 1x1 (Header)
                          pw.Table(
                            border: pw.TableBorder.all(),
                            children: [
                              pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Center(
                                      child: pw.Text(
                                        'Imagens do Item',
                                        style: pw.TextStyle(
                                          fontSize: 12,
                                          fontWeight: pw.FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          pw.Table(
                            border: pw.TableBorder.all(),
                            children: List.generate(2, (rowIndex) {
                              return pw.TableRow(
                                children: List.generate(2, (colIndex) {
                                  return pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.SizedBox(
                                      height: 100,
                                      child: pw.Center(
                                        child: pw.Text(
                                            'R${rowIndex + 1}C${colIndex + 1}'),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            }),
                          ),
                        ],
                      )
                    ],
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
