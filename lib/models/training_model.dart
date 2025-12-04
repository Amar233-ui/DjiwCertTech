import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingModel {
  final String id;
  final String title;
  final String description;
  final String? videoUrl;
  final String? imageUrl;
  final String content;
  final String category;
  final int duration; // in minutes
  final DateTime createdAt;

  TrainingModel({
    required this.id,
    required this.title,
    required this.description,
    this.videoUrl,
    this.imageUrl,
    required this.content,
    required this.category,
    required this.duration,
    required this.createdAt,
  });

  factory TrainingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TrainingModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      videoUrl: data['videoUrl'],
      imageUrl: data['imageUrl'],
      content: data['content'] ?? '',
      category: data['category'] ?? '',
      duration: data['duration'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
      'content': content,
      'category': category,
      'duration': duration,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
