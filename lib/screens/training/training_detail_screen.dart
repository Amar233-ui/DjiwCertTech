import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/training_model.dart';
import '../../widgets/custom_button.dart';

class TrainingDetailScreen extends StatelessWidget {
  final TrainingModel training;

  const TrainingDetailScreen({super.key, required this.training});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: training.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: training.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppTheme.backgroundColor,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        child: const Icon(
                          Icons.school,
                          size: 80,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    )
                  : Container(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      child: const Icon(
                        Icons.school,
                        size: 80,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: FadeInUp(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category and duration
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            training.category,
                            style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${training.duration} min',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      training.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Description
                    Text(
                      training.description,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Media buttons
                    if (training.videoUrl != null || training.audioUrl != null) ...[
                      if (training.videoUrl != null)
                        CustomButton(
                          text: 'Regarder la vidéo',
                          icon: Icons.play_circle_outline,
                          onPressed: () {
                            // TODO: Ouvrir lecteur vidéo
                          },
                        ),
                      if (training.audioUrl != null) ...[
                        const SizedBox(height: 12),
                        CustomButton(
                          text: 'Écouter l\'audio',
                          icon: Icons.headphones,
                          onPressed: () {
                            // TODO: Ouvrir lecteur audio
                          },
                          isOutlined: true,
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                    // Download button
                    if (training.isDownloadable)
                      CustomButton(
                        text: training.isOfflineAvailable 
                            ? 'Téléchargé (Disponible hors-ligne)' 
                            : 'Télécharger pour hors-ligne',
                        icon: training.isOfflineAvailable 
                            ? Icons.check_circle 
                            : Icons.download,
                        onPressed: () {
                          // TODO: Implémenter téléchargement
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(training.isOfflineAvailable
                                  ? 'Déjà téléchargé'
                                  : 'Téléchargement en cours...'),
                              backgroundColor: AppTheme.primaryGreen,
                            ),
                          );
                        },
                        isOutlined: training.isOfflineAvailable,
                      ),
                    const SizedBox(height: 24),
                    // Content
                    const Text(
                      'Contenu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Text(
                        training.content,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          height: 1.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
