import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/theme.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'orders_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user?.address != null) {
      _addressController.text = user!.address!;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (cart.items.isEmpty) return;

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer une adresse de livraison'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final order = OrderModel(
        id: '',
        userId: auth.firebaseUser!.uid,
        items: cart.toOrderItems(),
        totalAmount: cart.totalAmount,
        address: _addressController.text.trim(),
        note: _noteController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _firestoreService.createOrder(order);
      cart.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande passee avec succes !'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OrdersScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: AppTheme.textLight.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Votre panier est vide',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Parcourez le catalogue pour ajouter des produits',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cart items
                      FadeInUp(
                        child: const Text(
                          'Articles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...cart.items.values.map((item) => FadeInUp(
                            child: _CartItemCard(
                              item: item,
                              onIncrease: () =>
                                  cart.increaseQuantity(item.product.id),
                              onDecrease: () =>
                                  cart.decreaseQuantity(item.product.id),
                              onRemove: () =>
                                  cart.removeItem(item.product.id),
                            ),
                          )),
                      const SizedBox(height: 24),
                      // Delivery address
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: CustomTextField(
                          controller: _addressController,
                          labelText: 'Adresse de livraison',
                          hintText: 'Entrez votre adresse complete',
                          prefixIcon: Icons.location_on_outlined,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Note
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: CustomTextField(
                          controller: _noteController,
                          labelText: 'Note (optionnel)',
                          hintText: 'Instructions speciales...',
                          prefixIcon: Icons.note_outlined,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Order summary
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: Container(
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
                            children: [
                              _SummaryRow(
                                label: 'Sous-total',
                                value:
                                    '${cart.totalAmount.toStringAsFixed(0)} FCFA',
                              ),
                              const SizedBox(height: 8),
                              const _SummaryRow(
                                label: 'Livraison',
                                value: 'Gratuite',
                                valueColor: AppTheme.primaryGreen,
                              ),
                              const Divider(height: 24),
                              _SummaryRow(
                                label: 'Total',
                                value:
                                    '${cart.totalAmount.toStringAsFixed(0)} FCFA',
                                isBold: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: CustomButton(
                    text: 'Commander (${cart.totalAmount.toStringAsFixed(0)} FCFA)',
                    isLoading: _isLoading,
                    onPressed: _placeOrder,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
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
          // Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: item.product.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: item.product.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.eco,
                    color: AppTheme.primaryGreen,
                    size: 30,
                  ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.product.price.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onTap: onDecrease,
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onTap: onIncrease,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Remove button
          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (isBold ? AppTheme.textPrimary : AppTheme.textSecondary),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 18 : 14,
          ),
        ),
      ],
    );
  }
}
