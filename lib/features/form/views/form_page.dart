// ignore_for_file: use_build_context_synchronously, prefer_final_fields, no_leading_underscores_for_local_identifiers

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:stiuffcoletorinventario/core/models/inventory_item.dart';
import 'package:stiuffcoletorinventario/core/providers/inventory_provider.dart';
import 'package:stiuffcoletorinventario/features/home/models/package_item.dart';
import 'package:stiuffcoletorinventario/shared/utils/app_colors.dart';

class FormPage extends StatefulWidget {
  final String? barcode;

  const FormPage({super.key, this.barcode});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _name, _description, _location, _observations, _userEntryBarcode;
  String _packageId = '0';
  List<String> _images = [];
  String? _geolocation;
  DateTime _currentDate = DateTime.now();
  final ImagePicker _picker = ImagePicker();

  bool _hasBarcodeError = false;

  List<Package> _existingPackages = [
    Package(
        id: '0',
        name: 'Pacote Default',
        description: 'Grupo genérico',
        dateSent: DateTime.now(),
        tags: [],
        items: []),
    Package(
        id: '1',
        name: 'Pacote A',
        description: 'Descrição do Pacote A',
        dateSent: DateTime.now(),
        tags: ['Tag1'],
        items: []),
    Package(
        id: '2',
        name: 'Pacote B',
        description: 'Descrição do Pacote B',
        dateSent: DateTime.now(),
        tags: ['Tag2'],
        items: []),
  ];

  Future<void> _captureGeolocation() async {
    setState(() {
      _isLoading = true;
    });
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high),
        );
        setState(() {
          _isLoading = false;
          _geolocation =
              "Latitude: ${position.latitude}, Longitude: ${position.longitude}, Altitude: ${position.altitude}";
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao obter localização: $e')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão de localização não concedida')),
      );
    }
  }

  Future<void> _addImage() async {
    if (_images.length < 3) {
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Escolha a origem da imagem'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: () {
                  Navigator.pop(context, ImageSource.camera);
                },
                tooltip: 'Câmera',
              ),
              IconButton(
                icon: const Icon(Icons.photo_library),
                onPressed: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
                tooltip: 'Galeria',
              ),
            ],
          );
        },
      );

      if (source != null) {
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null) {
          setState(() {
            _images.add(image.path);
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo de 3 imagens atingido.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration inputDecoration(
        {required String label, bool readOnly = false, bool hasError = false}) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.greyTextColor,
        ),
        filled: true,
        fillColor: readOnly ? Colors.grey[200] : Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: hasError ? Colors.red : AppColors.greyTextColor,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
              color: AppColors.orangeSelectionColor, width: 2.0),
        ),
        hoverColor: AppColors.orangeSelectionColor,
        floatingLabelStyle: const TextStyle(
            color: AppColors.orangeSelectionColor, fontWeight: FontWeight.bold),
        hintStyle: const TextStyle(color: AppColors.greyTextColor),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        focusColor: AppColors.orangeSelectionColor,
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
      );
    }

    Widget _imageItem(int index) {
      if (index < _images.length) {
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Image.file(
                  File(_images[index]),
                  width: MediaQuery.of(context).size.width / 3 - 16,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: -5,
                  right: -5,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _images.removeAt(index);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(
            width: MediaQuery.of(context).size.width / 3 - 16,
            height: 80,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              onPressed: _addImage,
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
              tooltip: 'Adicionar imagem',
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
          ),
        );
      }
    }

    Widget _geolocationInfo() {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Informações de Geolocalização:',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _isLoading
                    ? const Center(
                        child: LinearProgressIndicator(
                          color: AppColors.orangeSelectionColor,
                          backgroundColor: Colors.grey,
                          minHeight: 15,
                        ),
                      )
                    : Text(
                        _geolocation ??
                            "As coordenadas associadas a este item não foram disponibilizadas.",
                        style: TextStyle(
                            color: _geolocation != null
                                ? Colors.green
                                : Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _captureGeolocation,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.orangeSelectionColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 4),
                      blurRadius: 4)
                ],
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Capturar Geolocalização',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              TextFormField(
                initialValue: widget.barcode ?? '',
                decoration: inputDecoration(
                  label: 'Código',
                  readOnly: widget.barcode != null,
                  hasError: _hasBarcodeError,
                ),
                readOnly: widget.barcode != null,
                onChanged: widget.barcode == null
                    ? (value) {
                        _userEntryBarcode = value;
                        setState(() {
                          _hasBarcodeError = value.isEmpty;
                        });
                      }
                    : null,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: TextInputType.number,
                // IssueFix: Doesn't work for whatever reason.
                // validator: (value) {
                //   if (widget.barcode == null || widget.barcode!.isEmpty) {
                //     return (_userEntryBarcode == null ||
                //             _userEntryBarcode!.isEmpty)
                //         ? 'O código não pode estar vazio'
                //         : null;
                //   }
                //   return null;
                // },
              ),
              if (_hasBarcodeError)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Padding(
                    padding: EdgeInsets.only(left: 13.5),
                    child: Text(
                      'O campo do código é obrigatório.',
                      style: TextStyle(
                          color: Color.fromARGB(255, 179, 12, 1), fontSize: 12),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: AppColors.orangeSelectionColor,
                decoration: inputDecoration(label: 'Nome do Objeto'),
                onChanged: (value) => _name = value,
                validator: (value) => value == null || value.isEmpty
                    ? 'O nome do objeto é obrigatório.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: AppColors.orangeSelectionColor,
                decoration: inputDecoration(label: 'Descrição'),
                maxLines: 3,
                onChanged: (value) => _description = value,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Pacote: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.grey.withOpacity(0.5), width: 1),
                    ),
                    child: DropdownButton<String>(
                      padding: const EdgeInsets.only(left: 8.0),
                      value: _packageId,
                      hint: const Text(
                        'Selecione um pacote',
                        style: TextStyle(color: Colors.black54),
                      ),
                      items: [
                        ..._existingPackages.map((package) {
                          return DropdownMenuItem<String>(
                            value: package.id,
                            child: Text(
                              package.name,
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _packageId = value ?? '0';
                        });
                      },
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.black54),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) => _imageItem(index),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: AppColors.orangeSelectionColor,
                decoration: inputDecoration(
                    label: 'Localidade (Departamento, Andar, Sala)'),
                onChanged: (value) => _location = value,
                validator: (value) => value == null || value.isEmpty
                    ? 'A localidade é obrigatória.'
                    : null,
              ),
              const Divider(),
              _geolocationInfo(),
              const Divider(),
              TextFormField(
                cursorColor: AppColors.orangeSelectionColor,
                decoration: inputDecoration(label: 'Observações'),
                maxLines: 3,
                onChanged: (value) => _observations = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: DateFormat('dd/MM/yyyy').format(_currentDate),
                decoration:
                    inputDecoration(label: 'Data Atual', readOnly: true),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // IssueFix: Validator on TextFormController doesn't work properly.
                    if ((widget.barcode == null || widget.barcode!.isEmpty) &&
                        (_userEntryBarcode == null ||
                            _userEntryBarcode!.isEmpty)) {
                      setState(() {
                        _hasBarcodeError = true;
                      });
                      return;
                    }
                    final inventoryProvider =
                        Provider.of<InventoryProvider>(context, listen: false);
                    // Criando um NOVO item de inventário
                    InventoryItem newItem = InventoryItem(
                      barcode: widget.barcode ?? _userEntryBarcode ?? '',
                      name: _name ?? '',
                      description: _description,
                      packageId: _packageId,
                      images: _images,
                      location: _location ?? '',
                      geolocation: _geolocation,
                      observations: _observations,
                      date: DateTime.now(),
                    );
                    // Salvando o item localmente
                    await inventoryProvider.addItem(newItem);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Dados catalogados com sucesso!')));
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  side: const BorderSide(color: Colors.blue, width: 1.5),
                ),
                child: const Text('Salvar Item',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
