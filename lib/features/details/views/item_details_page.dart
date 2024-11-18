// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stiuffcoletorinventario/core/models/inventory_item.dart';
import 'package:stiuffcoletorinventario/core/models/package_model.dart';
import 'package:stiuffcoletorinventario/core/providers/inventory_provider.dart';
import 'package:stiuffcoletorinventario/shared/utils/app_colors.dart';

class ItemDetailsPage extends StatefulWidget {
  final InventoryItem item;

  const ItemDetailsPage({super.key, required this.item});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  late String? _barcode, _name, _description, _location, _observations;
  late String? _geolocation;
  late int _packageId;
  late List<String>? _images;
  final ImagePicker _picker = ImagePicker();

  PackageModel? selectedPackage;

  // final List<Package> _existingPackages = [
  //   Package(
  //       id: '0',
  //       name: 'Pacote Default',
  //       description: 'Grupo genérico',
  //       dateSent: DateTime.now(),
  //       tags: [],
  //       items: []),
  //   Package(
  //       id: '1',
  //       name: 'Pacote A',
  //       description: 'Descrição do Pacote A',
  //       dateSent: DateTime.now(),
  //       tags: ['Tag1'],
  //       items: []),
  //   Package(
  //       id: '2',
  //       name: 'Pacote B',
  //       description: 'Descrição do Pacote B',
  //       dateSent: DateTime.now(),
  //       tags: ['Tag2'],
  //       items: []),
  // ];

  @override
  void initState() {
    super.initState();
    _barcode = widget.item.barcode;
    _name = widget.item.name;
    _description = widget.item.description;
    _images = widget.item.images;
    _location = widget.item.location;
    _observations = widget.item.observations;
    _geolocation = widget.item.geolocation;
    _packageId = widget.item.packageId;

    // Atribuir o pacote inicial
    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);
    if (inventoryProvider.packages.isNotEmpty) {
      selectedPackage = inventoryProvider.packages.firstWhere((package) {
        return package.id == _packageId;
      }, orElse: () {
        return inventoryProvider.packages.first;
      });
    }
  }

  InputDecoration _inputDecoration(String label, {bool readOnly = false}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: readOnly ? Colors.grey[200] : Colors.white,
      floatingLabelStyle: const TextStyle(
          color: AppColors.orangeSelectionColor, fontWeight: FontWeight.bold),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide:
            const BorderSide(color: AppColors.greyTextColor, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide:
            const BorderSide(color: AppColors.orangeSelectionColor, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
    );
  }

  Future<void> _addImage() async {
    if (widget.item.images!.length < 3) {
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
            widget.item.images!.add(image.path);
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo de 3 imagens atingido.')),
      );
    }
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 3,
      itemBuilder: (context, index) {
        final imagePath =
            (widget.item.images != null && widget.item.images!.length > index)
                ? widget.item.images![index]
                : '';
        return FutureBuilder<bool>(
          future: File(imagePath).exists(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data == true) {
              return Container(
                width: MediaQuery.of(context).size.width / 3 - 16,
                height: 80,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Image.file(
                        File(imagePath),
                        width: MediaQuery.of(context).size.width / 3 - 16,
                        fit: BoxFit.cover,
                      ),
                      (_isEditing)
                          ? Positioned(
                              top: -5,
                              right: -5,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    widget.item.images!.removeAt(index);
                                  });
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              );
            } else {
              return SizedBox(
                height: 100,
                child: Container(
                  width: MediaQuery.of(context).size.width / 3 - 16,
                  height: 80,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10)),
                  child: IconButton(
                    onPressed: (_isEditing) ? _addImage : null,
                    icon: const Icon(Icons.camera_alt, size: 32),
                    color: Colors.white,
                    highlightColor: const Color.fromARGB(25, 0, 0, 0),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    List<PackageModel> packages = inventoryProvider.packages;

    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: _isEditing
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'cancel',
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                  backgroundColor: Colors.red,
                  child: const Icon(
                    Icons.cancel,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  heroTag: 'save',
                  backgroundColor: Colors.blue,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final inventoryProvider = Provider.of<InventoryProvider>(
                          context,
                          listen: false);
                      // Substituindo o item
                      InventoryItem newItem = InventoryItem(
                        barcode: _barcode ?? '-1',
                        name: _name ?? '',
                        description: _description,
                        packageId: _packageId,
                        images: _images,
                        location: _location ?? '',
                        geolocation: _geolocation,
                        observations: _observations,
                        date: widget.item.date,
                      );
                      // Atualizando o item localmente
                      int response =
                          await inventoryProvider.updateItem(newItem);
                      if (response == 0) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Dados atualizados com sucesso!')),
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Não foi possível realizar a operação.')),
                          );
                        }
                      }
                      setState(() {
                        _isEditing = false;
                      });
                    }
                  },
                  child: const Icon(
                    Icons.save,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          : FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              child: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
            ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              TextFormField(
                cursorColor: AppColors.orangeSelectionColor,
                initialValue: _barcode,
                decoration: _inputDecoration('Código', readOnly: true),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8.0),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Pacote: ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      height: 32,
                      decoration: BoxDecoration(
                        color: (_isEditing)
                            ? Colors.white
                            : const Color.fromARGB(255, 231, 231, 231),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: (packages.isEmpty)
                          ? const Center(
                              child: Text('Sem pacotes disponíveis'),
                            )
                          : AbsorbPointer(
                              absorbing: !_isEditing,
                              child: DropdownButton<PackageModel>(
                                value: selectedPackage,
                                hint: const Text('Selecione um pacote'),
                                items: packages
                                    .map<DropdownMenuItem<PackageModel>>(
                                        (PackageModel package) {
                                  return DropdownMenuItem<PackageModel>(
                                    value: package,
                                    child: Text(package.name),
                                  );
                                }).toList(),
                                onChanged: (PackageModel? value) {
                                  setState(() {
                                    selectedPackage = value;
                                    _packageId = value?.id ?? 0;
                                  });
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: AppColors.orangeSelectionColor,
                initialValue: _name,
                decoration:
                    _inputDecoration('Nome do Objeto', readOnly: !_isEditing),
                readOnly: !_isEditing,
                onChanged: (value) => _name = value,
                validator: (value) => value == null || value.isEmpty
                    ? 'Nome é obrigatório.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: AppColors.orangeSelectionColor,
                initialValue: _description,
                decoration:
                    _inputDecoration('Descrição', readOnly: !_isEditing),
                readOnly: !_isEditing,
                maxLines: 3,
                onChanged: (value) => _description = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: AppColors.orangeSelectionColor,
                initialValue: _location,
                decoration:
                    _inputDecoration('Localidade', readOnly: !_isEditing),
                readOnly: !_isEditing,
                onChanged: (value) => _location = value,
                validator: (value) => value == null || value.isEmpty
                    ? 'Localidade é obrigatória.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: AppColors.orangeSelectionColor,
                initialValue: _geolocation ?? 'Não disponível',
                decoration: _inputDecoration('Geolocalização', readOnly: true),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: AppColors.orangeSelectionColor,
                initialValue: _observations,
                decoration:
                    _inputDecoration('Observações', readOnly: !_isEditing),
                readOnly: !_isEditing,
                maxLines: 3,
                onChanged: (value) => _observations = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: AppColors.orangeSelectionColor,
                initialValue: DateFormat('dd/MM/yyyy').format(widget.item.date),
                decoration:
                    _inputDecoration('Data de Registro', readOnly: true),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.only(
                  left: 8.0,
                ),
                child: Text(
                  'Imagens',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildImageGrid(),
              const SizedBox(height: 72),
            ],
          ),
        ),
      ),
    );
  }
}
