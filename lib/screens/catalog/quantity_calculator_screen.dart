import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/regions_constants.dart';
import '../../models/product_model.dart';
import '../../services/gemini_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class QuantityCalculatorScreen extends StatefulWidget {
  final ProductModel product;

  const QuantityCalculatorScreen({
    super.key,
    required this.product,
  });

  @override
  State<QuantityCalculatorScreen> createState() => _QuantityCalculatorScreenState();
}

class _QuantityCalculatorScreenState extends State<QuantityCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _areaController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  
  String? _selectedRegion;
  String? _selectedSeason;
  bool _isCalculating = false;
  Map<String, dynamic>? _calculationResult;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _selectedRegion = user?.region ?? RegionsConstants.regions.first;
    _selectedSeason = RegionsConstants.seasons.first;
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _calculateQuantity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
      _calculationResult = null;
    });

    try {
      final area = double.tryParse(_areaController.text) ?? 0.0;
      final result = await _geminiService.calculateSeedQuantity(
        seedName: widget.product.name,
        areaHectares: area,
        region: _selectedRegion ?? '',
        season: _selectedSeason ?? '',
      );

      setState(() {
        _calculationResult = result;
        _isCalculating = false;
      });
    } catch (e) {
      setState(() {
        _isCalculating = false;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculateur de quantité'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info produit
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.eco, color: AppTheme.primaryGreen, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.product.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Superficie
              CustomTextField(
                controller: _areaController,
                labelText: 'Superficie (hectares)',
                hintText: 'Ex: 2.5',
                prefixIcon: Icons.square_foot,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une superficie';
                  }
                  final area = double.tryParse(value);
                  if (area == null || area <= 0) {
                    return 'Superficie invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Région
              DropdownButtonFormField<String>(
                value: _selectedRegion,
                decoration: InputDecoration(
                  labelText: 'Région',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: RegionsConstants.regions.map((region) {
                  return DropdownMenuItem(
                    value: region,
                    child: Text(region),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRegion = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              
              // Saison
              DropdownButtonFormField<String>(
                value: _selectedSeason,
                decoration: InputDecoration(
                  labelText: 'Saison',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: RegionsConstants.seasons.map((season) {
                  return DropdownMenuItem(
                    value: season,
                    child: Text(season),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSeason = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              
              // Bouton calculer
              CustomButton(
                text: 'Calculer la quantité',
                isLoading: _isCalculating,
                onPressed: _calculateQuantity,
                icon: Icons.calculate,
              ),
              
              // Résultats
              if (_calculationResult != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Résultats du calcul',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildResultRow(
                        'Quantité nécessaire',
                        '${_calculationResult!['quantity']} kg',
                        Icons.scale,
                      ),
                      const SizedBox(height: 12),
                      _buildResultRow(
                        'Densité de semis',
                        '${_calculationResult!['density']} kg/hectare',
                        Icons.grid_on,
                      ),
                      const SizedBox(height: 12),
                      _buildResultRow(
                        'Plants attendus',
                        '${_calculationResult!['expectedPlants']}',
                        Icons.eco,
                      ),
                      const SizedBox(height: 12),
                      _buildResultRow(
                        'Espacement',
                        _calculationResult!['spacing'],
                        Icons.straighten,
                      ),
                      if (_calculationResult!['advice'] != null) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        Text(
                          'Conseils',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _calculationResult!['advice'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.visible,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
