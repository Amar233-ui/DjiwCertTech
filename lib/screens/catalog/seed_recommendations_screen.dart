import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/gemini_service.dart';
import '../../providers/auth_provider.dart';
import '../../config/regions_constants.dart';
import '../../widgets/custom_button.dart';

class SeedRecommendationsScreen extends StatefulWidget {
  const SeedRecommendationsScreen({super.key});

  @override
  State<SeedRecommendationsScreen> createState() => _SeedRecommendationsScreenState();
}

class _SeedRecommendationsScreenState extends State<SeedRecommendationsScreen> {
  final GeminiService _geminiService = GeminiService();
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedRegion;
  String? _selectedAgroZone;
  String? _selectedSeason;
  String? _userPreferences;
  bool _isLoading = false;
  List<String> _recommendations = [];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _selectedRegion = user?.region ?? RegionsConstants.regions.first;
    _selectedAgroZone = user?.agroEcologicalZone ?? RegionsConstants.agroEcologicalZones.first;
    _selectedSeason = RegionsConstants.seasons.first;
  }

  Future<void> _getRecommendations() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _recommendations = [];
    });

    try {
      final recommendations = await _geminiService.recommendSeeds(
        region: _selectedRegion ?? '',
        agroEcologicalZone: _selectedAgroZone ?? '',
        season: _selectedSeason ?? '',
        userPreferences: _userPreferences?.trim(),
      );

      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
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
        title: const Text('Recommandations de Semences'),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recommandations IA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Semences adaptées à votre contexte',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
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
              
              DropdownButtonFormField<String>(
                value: _selectedAgroZone,
                decoration: InputDecoration(
                  labelText: 'Zone agro-écologique',
                  prefixIcon: const Icon(Icons.map),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: RegionsConstants.agroEcologicalZones.map((zone) {
                  return DropdownMenuItem(
                    value: zone,
                    child: Text(zone),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAgroZone = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              
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
              const SizedBox(height: 20),
              
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Préférences (optionnel)',
                  hintText: 'Ex: Résistant à la sécheresse',
                  prefixIcon: const Icon(Icons.favorite),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 2,
                onChanged: (value) {
                  _userPreferences = value;
                },
              ),
              const SizedBox(height: 24),
              
              CustomButton(
                text: 'Obtenir des recommandations',
                isLoading: _isLoading,
                onPressed: _getRecommendations,
                icon: Icons.auto_awesome,
              ),
              
              if (_recommendations.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Recommandations',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ..._recommendations.map((rec) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          rec,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
