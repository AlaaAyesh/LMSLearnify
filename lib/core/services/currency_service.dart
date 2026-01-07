import 'dart:io';
import 'package:flutter/material.dart';

/// Service to determine the appropriate currency based on user's location
class CurrencyService {
  static const String egyptCountryCode = 'EG';
  static const String egpCurrency = 'EGP';
  static const String usdCurrency = 'USD';
  static const String egpSymbol = 'جم';
  static const String usdSymbol = '\$';

  /// Get the user's country code from device locale
  static String getCountryCode() {
    try {
      // Try to get from device locale
      final locale = Platform.localeName;
      if (locale.contains('_')) {
        final parts = locale.split('_');
        if (parts.length >= 2) {
          return parts[1].toUpperCase();
        }
      }
      // Default to Egypt
      return egyptCountryCode;
    } catch (e) {
      return egyptCountryCode;
    }
  }

  /// Check if user is in Egypt
  static bool isInEgypt() {
    final countryCode = getCountryCode();
    return countryCode == egyptCountryCode;
  }

  /// Get the appropriate currency code based on location
  static String getCurrencyCode() {
    return isInEgypt() ? egpCurrency : usdCurrency;
  }

  /// Get the currency symbol for display
  static String getCurrencySymbol() {
    return isInEgypt() ? egpSymbol : usdSymbol;
  }

  /// Format price with currency symbol
  static String formatPrice(String price) {
    final symbol = getCurrencySymbol();
    return isInEgypt() ? '$price $symbol' : '$symbol$price';
  }

  /// Get the currency from BuildContext (using widget locale)
  static String getCurrencyFromContext(BuildContext context) {
    try {
      final locale = Localizations.localeOf(context);
      if (locale.countryCode == egyptCountryCode) {
        return egpCurrency;
      }
      return usdCurrency;
    } catch (e) {
      return egpCurrency;
    }
  }
}



