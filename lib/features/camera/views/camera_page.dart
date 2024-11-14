import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:stiuffcoletorinventario/shared/utils/barcode_painter.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _isDetecting = false;
  List<Rect> _barcodeRects = [];
  Size? _imageSize;

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
      setState(() {
        _imageSize = Size(
          _cameraController!.value.previewSize!.height,
          _cameraController!.value.previewSize!.width,
        );
      });

      // Inicia o stream de imagem
      _cameraController!.startImageStream((CameraImage image) {
        if (_isDetecting) return;
        _isDetecting = true;

        _scanBarcode(image).then((_) {
          setState(() {}); // Atualiza a UI para desenhar o retângulo
          _isDetecting = false;
        });
      });
    } catch (e) {
      debugPrint('Erro ao inicializar a câmera: $e');
    }
  }

  Future<void> _scanBarcode(CameraImage image) async {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();
      final bytesPerRow = image.planes[0].bytesPerRow;

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

      setState(() {
        _barcodeRects = barcodes.map((barcode) {
          final rect = barcode.boundingBox;
          return _scaleRect(rect, _imageSize!, context);
        }).toList();
      });
    } catch (e) {
      debugPrint('Erro ao processar imagem: $e');
    }
  }

  // Função para ajustar o retângulo ao tamanho da tela
  Rect _scaleRect(Rect rect, Size imageSize, BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    double scaleX = screenSize.width / imageSize.width;
    double scaleY = screenSize.height / imageSize.height;

    return Rect.fromLTRB(
      rect.left * scaleX,
      rect.top * scaleY,
      rect.right * scaleX,
      rect.bottom * scaleY,
    );
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
                // Desenha os retângulos de foco
                CustomPaint(
                  painter: BarcodePainter(barcodeRects: _barcodeRects),
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
