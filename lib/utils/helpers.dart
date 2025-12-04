import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  // Format price
  static String formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return '${formatter.format(price)} FCFA';
  }

  // Format date
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'fr_FR').format(date);
  }

  // Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(date);
  }

  // Format day name
  static String formatDayName(DateTime date) {
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[date.weekday - 1];
  }

  // Format full day name
  static String formatFullDayName(DateTime date) {
    final days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ];
    return days[date.weekday - 1];
  }

  // Show snackbar
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Phone number validation
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone.replaceAll(' ', ''));
  }

  // Format phone number for display
  static String formatPhoneNumber(String phone) {
    phone = phone.replaceAll(' ', '');
    if (phone.length >= 10) {
      return '${phone.substring(0, 3)} ${phone.substring(3, 5)} ${phone.substring(5, 7)} ${phone.substring(7, 9)} ${phone.substring(9)}';
    }
    return phone;
  }
}
