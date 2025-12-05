import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/theme.dart';
import '../models/product_model.dart';
import '../widgets/custom_button.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController? _controller;
  bool _isScanning = true;
  String? _scannedCode;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _handleScan(String code) async {
    if (!_isScanning) return;
    
    setState(() {
      _isScanning = false;
      _scannedCode = code;
    });

    try {
      // Rechercher le produit avec ce QR code dans Firestore directement
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('qrCode', isEqualTo: code)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) {
        throw Exception('Produit non trouvé pour ce QR code');
      }
      
      final product = ProductModel.fromFirestore(snapshot.docs.first);

      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Produit trouvé'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nom: ${product.name}'),
                const SizedBox(height: 8),
                Text('Origine: ${product.origin ?? "N/A"}'),
                if (product.certificationNumber != null) ...[
                  const SizedBox(height: 8),
                  Text('Certification: ${product.certificationNumber}'),
                ],
                if (product.producerName != null) ...[
                  const SizedBox(height: 8),
                  Text('Producteur: ${product.producerName}'),
                ],
                if (product.packagingDate != null) ...[
                  const SizedBox(height: 8),
                  Text('Date conditionnement: ${product.packagingDate!.day}/${product.packagingDate!.month}/${product.packagingDate!.year}'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isScanning = true;
                  _scannedCode = null;
                });
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur'),
          content: Text('Produit non trouvé pour ce QR code: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isScanning = true;
                  _scannedCode = null;
                });
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleScan(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          if (!_isScanning)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Code scanné',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _scannedCode ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Scanner à nouveau',
                      onPressed: () {
                        setState(() {
                          _isScanning = true;
                          _scannedCode = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
