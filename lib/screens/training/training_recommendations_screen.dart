import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/gemini_service.dart';
import '../../providers/auth_provider.dart';
import '../../config/regions_constants.dart';

class TrainingRecommendationsScreen extends StatefulWidget {
  const TrainingRecommendationsScreen({super.key});

  @override
  State<TrainingRecommendationsScreen> createState() => _TrainingRecommendationsScreenState();
}

class _TrainingRecommendationsScreenState extends State<TrainingRecommendationsScreen> {
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;
  List<Map<String, String>> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final recommendations = await _geminiService.recommendTraining(
        userRegion: user?.region ?? RegionsConstants.regions.first,
        agroEcologicalZone: user?.agroEcologicalZone ?? RegionsConstants.agroEcologicalZones.first,
        userInterests: ['Semences', 'Cultures'],
        currentCrops: null,
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
        title: const Text('Formations Recommandées'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recommendations.isEmpty
              ? const Center(child: Text('Aucune recommandation disponible'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _recommendations.length,
                  itemBuilder: (context, index) {
                    final rec = _recommendations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.school,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        title: Text(
                          rec['title'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(rec['description'] ?? ''),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // TODO: Navigate to training detail
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
