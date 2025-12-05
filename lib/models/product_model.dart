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
  // Traçabilité
  final String? origin;
  final String? certificationNumber;
  final String? producerId;
  final String? producerName;
  final DateTime? packagingDate;
  final String? packagingLocation;
  final String? qrCode;
  final String? season;
  final String? agroEcologicalZone;
  final bool isForestSeed;
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
    this.origin,
    this.certificationNumber,
    this.producerId,
    this.producerName,
    this.packagingDate,
    this.packagingLocation,
    this.qrCode,
    this.season,
    this.agroEcologicalZone,
    this.isForestSeed = false,
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
      origin: data['origin'],
      certificationNumber: data['certificationNumber'],
      producerId: data['producerId'],
      producerName: data['producerName'],
      packagingDate: data['packagingDate'] != null ? (data['packagingDate'] as Timestamp).toDate() : null,
      packagingLocation: data['packagingLocation'],
      qrCode: data['qrCode'],
      season: data['season'],
      agroEcologicalZone: data['agroEcologicalZone'],
      isForestSeed: data['isForestSeed'] ?? false,
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
      'origin': origin,
      'certificationNumber': certificationNumber,
      'producerId': producerId,
      'producerName': producerName,
      'packagingDate': packagingDate != null ? Timestamp.fromDate(packagingDate!) : null,
      'packagingLocation': packagingLocation,
      'qrCode': qrCode,
      'season': season,
      'agroEcologicalZone': agroEcologicalZone,
      'isForestSeed': isForestSeed,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
