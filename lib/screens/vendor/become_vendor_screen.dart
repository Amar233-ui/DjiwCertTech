import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../config/theme.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class BecomeVendorScreen extends StatefulWidget {
  const BecomeVendorScreen({super.key});

  @override
  State<BecomeVendorScreen> createState() => _BecomeVendorScreenState();
}

class _BecomeVendorScreenState extends State<BecomeVendorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _certificationNumberController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();
  
  File? _certificationDocument;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _companyNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _certificationNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _certificationDocument = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_certificationDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez joindre votre document de certification'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Upload certification document
      final docUrl = await _storageService.uploadProductImage(
        _certificationDocument!,
        'vendor_requests_${user.id}',
      );

      // Create vendor request
      await _firestoreService.createVendorRequest(
        userId: user.id,
        companyName: _companyNameController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        certificationNumber: _certificationNumberController.text.trim().isEmpty 
            ? null 
            : _certificationNumberController.text.trim(),
        certificationDocumentUrl: docUrl,
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande envoyée avec succès ! Nous vous contacterons bientôt.'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devenir Vendeur'),
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
                    Icon(Icons.store, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Demande de Vendeur Certifié',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Remplissez le formulaire pour devenir vendeur',
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
              
              CustomTextField(
                controller: _companyNameController,
                labelText: 'Nom de l\'entreprise *',
                hintText: 'Ex: Ferme Agricole XYZ',
                prefixIcon: Icons.business,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom de l\'entreprise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description *',
                hintText: 'Décrivez votre activité',
                prefixIcon: Icons.description,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              CustomTextField(
                controller: _addressController,
                labelText: 'Adresse complète *',
                hintText: 'Adresse de votre entreprise',
                prefixIcon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une adresse';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              CustomTextField(
                controller: _certificationNumberController,
                labelText: 'Numéro de certification',
                hintText: 'Ex: CERT-2024-001',
                prefixIcon: Icons.verified_user,
              ),
              const SizedBox(height: 20),
              
              const Text(
                'Document de certification *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDocument,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _certificationDocument != null 
                          ? AppTheme.primaryGreen 
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _certificationDocument != null 
                            ? Icons.check_circle 
                            : Icons.upload_file,
                        color: _certificationDocument != null 
                            ? AppTheme.primaryGreen 
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _certificationDocument != null 
                              ? 'Document sélectionné' 
                              : 'Appuyez pour sélectionner un document',
                          style: TextStyle(
                            color: _certificationDocument != null 
                                ? AppTheme.primaryGreen 
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              CustomButton(
                text: 'Envoyer la demande',
                isLoading: _isSubmitting,
                onPressed: _submitRequest,
                icon: Icons.send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
