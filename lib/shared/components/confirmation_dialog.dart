import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String title;
  final String message;
  final String action;
  final Color onConfirmColor;

  const ConfirmationDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    this.title = 'Confirmar ação',
    this.message = 'Você tem certeza de que deseja realizar esta ação?',
    this.action = 'Continuar',
    this.onConfirmColor = Colors.redAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: onConfirmColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    action,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
