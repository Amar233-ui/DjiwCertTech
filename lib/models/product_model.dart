import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String? detailedDescription;
  final double price;
  final double? deferredPrice;
  final String? imageUrl;
  final String category;
  final String? zone;
  final String? certification;
  final int stock;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    this.detailedDescription,
    required this.price,
    this.deferredPrice,
    this.imageUrl,
    required this.category,
    this.zone,
    this.certification,
    required this.stock,
    this.isAvailable = true,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      detailedDescription: data['detailedDescription'],
      price: (data['price'] ?? 0).toDouble(),
      deferredPrice: data['deferredPrice'] != null ? (data['deferredPrice'] as num).toDouble() : null,
      imageUrl: data['imageUrl'],
      category: data['category'] ?? '',
      zone: data['zone'],
      certification: data['certification'],
      stock: data['stock'] ?? 0,
      isAvailable: data['isAvailable'] ?? true,
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'detailedDescription': detailedDescription,
      'price': price,
      'deferredPrice': deferredPrice,
      'imageUrl': imageUrl,
      'category': category,
      'zone': zone,
      'certification': certification,
      'stock': stock,
      'isAvailable': isAvailable,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
