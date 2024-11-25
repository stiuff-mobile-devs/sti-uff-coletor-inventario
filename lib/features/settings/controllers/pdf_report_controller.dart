import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:stiuffcoletorinventario/core/models/inventory_item.dart';
import 'package:stiuffcoletorinventario/core/models/package_model.dart';
import 'package:stiuffcoletorinventario/core/providers/inventory_provider.dart';

extension MapIndexed<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E element) f) sync* {
    var index = 0;
    for (var element in this) {
      yield f(index, element);
      index++;
    }
  }
}

class PdfReportController extends ChangeNotifier {
  Future<void> openPdf(File file) async {
    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      debugPrint('Erro ao abrir o arquivo PDF.');
    }
  }

  pw.Align getPackageHeader(PackageModel package) {
    return pw.Align(
      alignment: pw.Alignment.centerLeft,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: package.name,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          package.tags.isNotEmpty && package.tags.first != ""
              ? pw.Text(
                  'Tags: "${package.tags.join('"; "')}".',
                  style: const pw.TextStyle(fontSize: 12),
                )
              : pw.Text(
                  'Tags: Nenhuma tag associada.',
                  style: pw.TextStyle(
                      fontSize: 12, fontStyle: pw.FontStyle.italic),
                ),
        ],
      ),
    );
  }

  pw.Align getItemHeader(InventoryItem item, int index) {
    return pw.Align(
      alignment: pw.Alignment.centerLeft,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: '$index. ${item.name} ',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.TextSpan(
                  text: '(#${item.barcode})',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF808080),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Paragraph(
            text: item.description ?? "N/A",
            textAlign: pw.TextAlign.justify,
            style: const pw.TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  pw.Table fillAndGetTable(InventoryItem item) {
    final parts = (item.geolocation ?? 'N/A').split(',');
    String? latitude;
    String? longitude;
    String? altitude;

    if (parts.length >= 3) {
      latitude = parts[0].split(':')[1].trim();
      longitude = parts[1].split(':')[1].trim();
      altitude = parts[2].split(':')[1].trim();
    }

    final table = getTableSkeleton(
      nestedTableData: [
        [
          'Data de Captura:',
          (DateFormat('dd/MM/yyyy HH:mm').format(item.date))
        ],
        [
          'Localização:',
          item.location,
        ],
        ['Cell 5', 'Cell 6'],
        [
          'Latitude:',
          latitude ?? 'N/A',
        ],
        [
          'Longitude:',
          longitude ?? 'N/A',
        ],
        [
          'Altitude:',
          altitude ?? 'N/A',
        ],
        ['Cell 13', 'Cell 14'],
        ['Cell 15', 'Cell 16'],
      ],
      mergedCellData: [
        'Coordenadas',
        'Observações',
        item.description ?? 'N/A',
      ],
      imageTableData: [
        [
          item.images != null && item.images!.isNotEmpty
              ? item.images![0]
              : 'N/A',
          item.images != null && item.images!.length > 1
              ? item.images![1]
              : 'N/A'
        ],
        [
          item.images != null && item.images!.length > 2
              ? item.images![2]
              : 'N/A',
          item.images != null && item.images!.length > 3
              ? item.images![3]
              : 'N/A'
        ],
      ],
    );
    return table;
  }

  pw.Table getTableSkeleton({
    required List<List<String>> nestedTableData,
    required List<String> mergedCellData,
    required List<List<String>> imageTableData,
  }) {
    return pw.Table(
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
                      child: pw.Table(
                        border: pw.TableBorder.all(),
                        children: List.generate(1, (innerRowIndex) {
                          if (rowIndex == 2 || rowIndex == 6 || rowIndex == 7) {
                            return pw.TableRow(
                              children: List.generate(1, (innerColIndex) {
                                return pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    mergedCellData[rowIndex == 2
                                        ? 0
                                        : rowIndex == 6
                                            ? 1
                                            : 2],
                                  ),
                                );
                              }),
                            );
                          }
                          return pw.TableRow(
                            children: List.generate(2, (innerColIndex) {
                              return pw.SizedBox(
                                width: 110,
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    nestedTableData[rowIndex][innerColIndex],
                                  ),
                                ),
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
                        final imagePath = imageTableData[rowIndex][colIndex];
                        if (imagePath.isNotEmpty &&
                            File(imagePath).existsSync()) {
                          return pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.SizedBox(
                              height: 100,
                              child: pw.Center(
                                child: pw.Image(
                                  pw.MemoryImage(
                                    File(imagePath).readAsBytesSync(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.SizedBox(
                              height: 100,
                              width: 100,
                              child: pw.Center(
                                child: pw.Text('N/A'),
                              ),
                            ),
                          );
                        }
                      }),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<File> generatePdf(
    BuildContext context,
    String selectedOption,
    String selectedDateRange,
  ) async {
    final pdf = pw.Document();
    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);

    List<PackageModel> packages = inventoryProvider.packages;
    List<InventoryItem> items = inventoryProvider.items;

    pdf.addPage(pw.MultiPage(
      build: (pw.Context context) {
        return [
          pw.Center(
            child: pw.Text(
              'Relatório de Inventário Local',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Center(
            child: pw.Text(
              'Gerado Em: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 16),
            ),
          ),
          pw.SizedBox(height: 20),
          ...packages.map((package) {
            final packageItems =
                items.where((item) => item.packageId == package.id).toList();

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                getPackageHeader(package),
                pw.SizedBox(height: 20),
                ...packageItems.mapIndexed((index, item) {
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      getItemHeader(item, index + 1),
                      fillAndGetTable(item),
                      pw.SizedBox(height: 20),
                    ],
                  );
                }),
                if (packageItems.isEmpty)
                  pw.Text(
                    'Nenhum item encontrado neste pacote.',
                    style: pw.TextStyle(
                        fontSize: 12, fontStyle: pw.FontStyle.italic),
                  ),
                pw.SizedBox(height: 40),
              ],
            );
          }),
        ];
      },
    ));

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/relatorio_inventario.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
