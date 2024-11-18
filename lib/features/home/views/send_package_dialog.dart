import 'package:flutter/material.dart';
import 'package:stiuffcoletorinventario/core/models/package_model.dart';

class SendPackageModal extends StatefulWidget {
  final List<PackageModel> packages;
  final void Function(List<PackageModel>) onDispatch;

  const SendPackageModal({
    super.key,
    required this.packages,
    required this.onDispatch,
  });

  @override
  State<SendPackageModal> createState() => _SendPackageModalState();
}

class _SendPackageModalState extends State<SendPackageModal> {
  final List<PackageModel> _selectedPackages = [];

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
            const Text(
              'Enviar Pacotes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Selecione os pacotes para envio:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.packages.length,
                itemBuilder: (context, index) {
                  final package = widget.packages[index];
                  return CheckboxListTile(
                    title: Text(
                      package.name,
                      style: const TextStyle(color: Colors.black),
                    ),
                    value: _selectedPackages.contains(package),
                    activeColor: Colors.blue,
                    onChanged: (isSelected) {
                      setState(() {
                        if (isSelected == true) {
                          _selectedPackages.add(package);
                        } else {
                          _selectedPackages.remove(package);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onDispatch(_selectedPackages);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Despachar',
                    style: TextStyle(color: Colors.white),
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
