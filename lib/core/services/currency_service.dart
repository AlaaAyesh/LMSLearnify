import 'dart:io';
import 'package:flutter/material.dart';

class CurrencyService {
  static const String egyptCountryCode = 'EG';
  static const String egpCurrency = 'EGP';
  static const String usdCurrency = 'USD';
  static const String egpSymbol = 'جم';
  static const String usdSymbol = '\$';

  static String getCountryCode() {
    try {
      final locale = Platform.localeName;
      if (locale.contains('_')) {
        final parts = locale.split('_');
        if (parts.length >= 2) {
          return parts[1].toUpperCase();
        }
      }
      return egyptCountryCode;
    } catch (e) {
      return egyptCountryCode;
    }
  }

  static bool isInEgypt() {
    final countryCode = getCountryCode();
    return countryCode == egyptCountryCode;
  }

  static String getCurrencyCode() {
    return isInEgypt() ? egpCurrency : usdCurrency;
  }

  static String getCurrencySymbol() {
    return isInEgypt() ? egpSymbol : usdSymbol;
  }

  static String formatPrice(String price) {
    final symbol = getCurrencySymbol();
    return isInEgypt() ? '$price $symbol' : '$symbol$price';
  }

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



