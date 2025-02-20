import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class GoogleDriveService {
  final _scopes = [
    drive.DriveApi.driveFileScope,
    sheets.SheetsApi.spreadsheetsScope,
  ];
  final _credentialsFile = 'assets/credentials.json';
  final _userEmail = 'jfontinele@id.uff.br'; // Substitua pelo seu e-mail

  Future<AutoRefreshingAuthClient> _getAuthenticatedClient() async {
    final credentialsJson = await rootBundle.loadString(_credentialsFile);
    final credentials = ServiceAccountCredentials.fromJson(credentialsJson);
    return clientViaServiceAccount(credentials, _scopes);
  }

  Future<void> saveDataToSheet(List<List<String>> data) async {
    try {
      final client = await _getAuthenticatedClient();
      final sheetsApi = sheets.SheetsApi(client);
      final driveApi = drive.DriveApi(client);

      // Create a new spreadsheet
      final spreadsheet = sheets.Spreadsheet();
      final createdSpreadsheet = await sheetsApi.spreadsheets.create(spreadsheet);

      print('Planilha criada com sucesso: ${createdSpreadsheet.spreadsheetUrl}');

      // Add data to the spreadsheet
      final valueRange = sheets.ValueRange(values: data);
      await sheetsApi.spreadsheets.values.append(
        valueRange,
        createdSpreadsheet.spreadsheetId!,
        'Sheet1',
        valueInputOption: 'RAW',
      );

      print('Dados adicionados com sucesso à planilha.');

      // Share the spreadsheet with your user email
      final permission = drive.Permission()
        ..type = 'user'
        ..role = 'writer'
        ..emailAddress = _userEmail;

      await driveApi.permissions.create(permission, createdSpreadsheet.spreadsheetId!);

      print('Planilha compartilhada com sucesso com $_userEmail.');
    } catch (e) {
      print('Erro ao salvar dados na planilha: $e');
    }
  }
}