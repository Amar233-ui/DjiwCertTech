import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/training_model.dart';
import '../config/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== PRODUCTS ====================
  
  Stream<List<ProductModel>> getProducts() {
    return _firestore
        .collection(AppConstants.productsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<ProductModel>> getProductsByCategory(String category) {
    return _firestore
        .collection(AppConstants.productsCollection)
        .where('category', isEqualTo: category)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList());
  }

  Future<ProductModel?> getProduct(String productId) async {
    final doc = await _firestore
        .collection(AppConstants.productsCollection)
        .doc(productId)
        .get();
    
    if (doc.exists) {
      return ProductModel.fromFirestore(doc);
    }
    return null;
  }

  // ==================== ORDERS ====================
  
  Future<String> createOrder(OrderModel order) async {
    final docRef = await _firestore
        .collection(AppConstants.ordersCollection)
        .add(order.toFirestore());
    return docRef.id;
  }

  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _firestore
        .collection(AppConstants.ordersCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList());
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestore
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== TRAINING ====================
  
  Stream<List<TrainingModel>> getTrainings() {
    return _firestore
        .collection(AppConstants.trainingCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TrainingModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<TrainingModel>> getTrainingsByCategory(String category) {
    return _firestore
        .collection(AppConstants.trainingCollection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TrainingModel.fromFirestore(doc))
            .toList());
  }

  Future<TrainingModel?> getTraining(String trainingId) async {
    final doc = await _firestore
        .collection(AppConstants.trainingCollection)
        .doc(trainingId)
        .get();
    
    if (doc.exists) {
      return TrainingModel.fromFirestore(doc);
    }
    return null;
  }

  // ==================== CATEGORIES ====================
  
  Future<List<String>> getProductCategories() async {
    final snapshot = await _firestore
        .collection(AppConstants.productsCollection)
        .get();
    
    final categories = snapshot.docs
        .map((doc) => doc.data()['category'] as String?)
        .where((cat) => cat != null)
        .cast<String>()
        .toSet()
        .toList();
    
    return categories;
  }
}
