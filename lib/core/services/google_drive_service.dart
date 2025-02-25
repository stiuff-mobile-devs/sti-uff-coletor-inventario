import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:intl/intl.dart'; // Import intl package for date formatting
import 'package:flutter/material.dart'; // Import Flutter Material package

class GoogleDriveService {
  final _scopes = [
    drive.DriveApi.driveFileScope,
    sheets.SheetsApi.spreadsheetsScope,
  ];
  final _credentialsFile = 'assets/credentials.json';

  Future<AutoRefreshingAuthClient> _getAuthenticatedClient() async {
    final credentialsJson = await rootBundle.loadString(_credentialsFile);
    final credentials = ServiceAccountCredentials.fromJson(credentialsJson);
    return clientViaServiceAccount(credentials, _scopes);
  }

  Future<void> saveDataToSheet(BuildContext context, List<List<String>> data) async {
    try {
      final client = await _getAuthenticatedClient();
      final sheetsApi = sheets.SheetsApi(client);
      final driveApi = drive.DriveApi(client);

      // Get the current date and time
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      // Create a new spreadsheet with a specific name including the current date and time
      final spreadsheet = sheets.Spreadsheet()
        ..properties = (sheets.SpreadsheetProperties()..title = 'Dados dos pacotes $formattedDate'); // Defina o nome desejado aqui

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

      // Get the authenticated user's email
      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email;

      if (userEmail != null) {
        // Share the spreadsheet with the authenticated user's email
        final permission = drive.Permission()
          ..type = 'user'
          ..role = 'writer'
          ..emailAddress = userEmail;

        await driveApi.permissions.create(permission, createdSpreadsheet.spreadsheetId!);

        print('Planilha compartilhada com sucesso com $userEmail.');

        // Show a SnackBar with the success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Planilha compartilhada com sucesso com $userEmail.'),
          ),
        );
      } else {
        print('Erro: Usuário não autenticado.');
      }
    } catch (e) {
      print('Erro ao salvar dados na planilha: $e');
    }
  }
}