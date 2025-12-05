import 'package:flutter/material.dart';
import '../../config/theme.dart';

class VendorFinanceScreen extends StatelessWidget {
  const VendorFinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finances'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Suivi financier - À implémenter'),
      ),
    );
  }
}
