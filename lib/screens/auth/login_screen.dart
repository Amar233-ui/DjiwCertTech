import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _selectedCountryCode = '+225';

  final List<Map<String, String>> _countryCodes = [
    {'code': '+225', 'country': 'CI', 'flag': '🇨🇮'},
    {'code': '+33', 'country': 'FR', 'flag': '🇫🇷'},
    {'code': '+1', 'country': 'US', 'flag': '🇺🇸'},
    {'code': '+237', 'country': 'CM', 'flag': '🇨🇲'},
    {'code': '+221', 'country': 'SN', 'flag': '🇸🇳'},
    {'code': '+223', 'country': 'ML', 'flag': '🇲🇱'},
    {'code': '+226', 'country': 'BF', 'flag': '🇧🇫'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOTP() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final phoneNumber = '$_selectedCountryCode${_phoneController.text.trim()}';
      
      await authProvider.sendOTP(phoneNumber);
      
      if (!mounted) return;
      
      if (authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
        authProvider.clearError();
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OTPScreen(phoneNumber: phoneNumber),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                FadeInDown(
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.eco,
                        size: 40,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: const Text(
                    'Bienvenue',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInDown(
                  delay: const Duration(milliseconds: 300),
                  child: const Text(
                    'Connectez-vous avec votre numero de telephone',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: const Text(
                    'Numero de telephone',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCountryCode,
                            items: _countryCodes.map((country) {
                              return DropdownMenuItem(
                                value: country['code'],
                                child: Text(
                                  '${country['flag']} ${country['code']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCountryCode = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _phoneController,
                          hintText: '07 00 00 00 00',
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre numero';
                            }
                            if (value.length < 8) {
                              return 'Numero invalide';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      return CustomButton(
                        text: 'Recevoir le code',
                        isLoading: auth.isLoading,
                        onPressed: _sendOTP,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 700),
                  child: Center(
                    child: Text(
                      'En continuant, vous acceptez nos conditions\nd\'utilisation et notre politique de confidentialite',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}