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
          title: Row(
            children: [
              const Icon(Icons.verified, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              const Text('Informations de Traçabilité'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Nom du produit', product.name),
                if (product.origin != null && product.origin!.isNotEmpty)
                  _buildInfoRow('Origine', product.origin!),
                if (product.certificationNumber != null && product.certificationNumber!.isNotEmpty)
                  _buildInfoRow('Numéro de certification', product.certificationNumber!),
                if (product.producerName != null && product.producerName!.isNotEmpty)
                  _buildInfoRow('Producteur', product.producerName!),
                if (product.producerId != null && product.producerId!.isNotEmpty)
                  _buildInfoRow('ID Producteur', product.producerId!),
                if (product.packagingDate != null)
                  _buildInfoRow('Date de conditionnement', 
                    '${product.packagingDate!.day}/${product.packagingDate!.month}/${product.packagingDate!.year}'),
                if (product.packagingLocation != null && product.packagingLocation!.isNotEmpty)
                  _buildInfoRow('Lieu de conditionnement', product.packagingLocation!),
                if (product.season != null && product.season!.isNotEmpty)
                  _buildInfoRow('Saison', product.season!),
                if (product.agroEcologicalZone != null && product.agroEcologicalZone!.isNotEmpty)
                  _buildInfoRow('Zone agro-écologique', product.agroEcologicalZone!),
                if (product.qrCode != null && product.qrCode!.isNotEmpty)
                  _buildInfoRow('Code QR', product.qrCode!),
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
              child: const Text('Fermer'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
