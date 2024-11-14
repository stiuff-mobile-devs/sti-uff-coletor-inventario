import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  // Barcode
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.first;

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      setState(() {});

      // Inicia o stream de imagem
      _cameraController!.startImageStream((CameraImage image) {
        if (_isDetecting) return;
        _isDetecting = true;

        _scanBarcode(image).then((_) {
          _isDetecting = false;
        });
      });
    } catch (e) {
      debugPrint('Erro ao inicializar a câmera: $e');
    }
  }

  Future<void> _scanBarcode(CameraImage image) async {
    try {
      // Converte a imagem da câmera em uma lista de bytes
      final WriteBuffer allBytes = WriteBuffer();
      for (Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      // Obtém bytesPerRow do primeiro plano da imagem
      final bytesPerRow = image.planes[0].bytesPerRow;

      // Cria o InputImage para o scanner
      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotationValue.fromRawValue(
                  _cameraController!.description.sensorOrientation) ??
              InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: bytesPerRow,
        ),
      );

      // Processa a imagem para detectar códigos de barras
      final barcodes = await _barcodeScanner.processImage(inputImage);

      for (Barcode barcode in barcodes) {
        debugPrint('Código de barras detectado: ${barcode.rawValue}');
      }
    } catch (e) {
      debugPrint('Erro ao processar imagem: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _cameraController != null) {
            return Stack(
              children: [
                FittedBox(
                  fit: BoxFit.fill,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Center(
                  child: Opacity(
                    opacity: 0.5,
                    child: SvgPicture.asset(
                      'assets/icons/scan-surface.svg',
                      width: 100,
                      height: 100,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingActionButton(
                      backgroundColor: Colors.red,
                      onPressed: () async {
                        try {
                          if (_cameraController != null) {
                            final image =
                                await _cameraController!.takePicture();
                            debugPrint('Imagem capturada: ${image.path}');
                          }
                        } catch (e) {
                          debugPrint(e.toString());
                        }
                      },
                      child: const Icon(Icons.camera, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
        },
      ),
    );
  }
}
