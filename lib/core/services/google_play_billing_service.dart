import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class GooglePlayBillingService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  static const Map<int, String> productIdMap = {
    1: 'one_month_sub',
    2: 'six_months_sub',
    3: 'one_year_sub',
  };

  static String? getProductId(int planId) {
    return productIdMap[planId];
  }

  static int? getPlanId(String productId) {
    for (var entry in productIdMap.entries) {
      if (entry.value == productId) {
        return entry.key;
      }
    }
    return null;
  }

  static String getDisplayName(String productId, String originalTitle) {
    if (productId == 'one_year_sub' || productId == '3') {
      return 'Lifetime Access';
    }
    if (originalTitle.contains('1 Year Subscription') ||
        originalTitle.contains('Year Subscription')) {
      return 'Lifetime Access';
    }
    return originalTitle;
  }

  static String extractCurrency(String price) {
    if (price.isEmpty) return 'EGP';

    final currencyMatch = RegExp(r'^([A-Z]{3})\s').firstMatch(price);
    if (currencyMatch != null) {
      return currencyMatch.group(1) ?? 'EGP';
    }

    return 'EGP';
  }

  static String getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'EGP':
        return 'جم';
      case 'USD':
        return '\$';
      default:
        return 'جم';
    }
  }

  static String extractPriceValue(String price) {
    if (price.isEmpty) return '0';

    final priceWithoutCurrency = price.replaceFirst(RegExp(r'^[A-Z]{3}\s*'), '');

    return priceWithoutCurrency.trim();
  }

  @Deprecated('Use getPlanId instead')
  static int? getSubscriptionId(String productId) {
    return getPlanId(productId);
  }

  Future<bool> isAvailable() async {
    try {
      return await _inAppPurchase.isAvailable();
    } catch (e) {
      print('Error checking billing availability: $e');
      return false;
    }
  }

  Future<void> initialize({
    required Function(PurchaseDetails) onPurchaseUpdated,
    required Function(String) onError,
  }) async {
    try {
      final bool available = await isAvailable();
      if (!available) {
        throw Exception('متجر Google Play غير متاح على هذا الجهاز');
      }

      await _purchaseSubscription?.cancel();

      _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
        (List<PurchaseDetails> purchaseDetailsList) {
          _handlePurchaseUpdates(purchaseDetailsList, onPurchaseUpdated, onError);
        },
        onDone: () {
          print('Purchase stream closed');
        },
        onError: (error) {
          print('Purchase stream error: $error');
          onError('خطأ في نظام الدفع: $error');
        },
      );

      print('Google Play Billing initialized successfully');
    } catch (e) {
      print('Billing initialization error: $e');
      onError('فشل تهيئة نظام الدفع: $e');
      rethrow;
    }
  }

  void _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
    Function(PurchaseDetails) onPurchaseUpdated,
    Function(String) onError,
  ) {
    for (final purchaseDetails in purchaseDetailsList) {
      print('Purchase update: ${purchaseDetails.status}, Product: ${purchaseDetails.productID}');

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          print('Purchase pending: ${purchaseDetails.productID}');
          break;

        case PurchaseStatus.error:
          final errorMsg = purchaseDetails.error?.message ?? 'خطأ في عملية الشراء';
          final errorCode = purchaseDetails.error?.code;
          print('Purchase error: $errorMsg');
          print('Error code: $errorCode');
          print('Error details: ${purchaseDetails.error}');

          String detailedError = errorMsg;
          if (errorCode != null) {
            detailedError += '\n\nكود الخطأ: $errorCode';
          }

          if (errorMsg.contains('could not be found') ||
              errorMsg.contains('not found') ||
              errorCode == 'ITEM_UNAVAILABLE') {
            detailedError += '\n\nالسبب المحتمل:\n';
            detailedError += '1. التطبيق غير مفعّل في Internal Testing\n';
            detailedError += '2. حسابك غير مضاف كـ Tester\n';
            detailedError += '3. التطبيق لم يتم نشره في Internal Testing Track\n';
            detailedError += '4. انتظر 2-3 ساعات بعد رفع التطبيق\n';
            detailedError += '5. تأكد من تسجيل الدخول بحساب Tester على الجهاز';
          }
          
          onError(detailedError);
          if (purchaseDetails.pendingCompletePurchase) {
            _inAppPurchase.completePurchase(purchaseDetails);
          }
          break;

        case PurchaseStatus.purchased:
          print('Purchase completed: ${purchaseDetails.productID}');
          onPurchaseUpdated(purchaseDetails);
          break;

        case PurchaseStatus.restored:
          print('Purchase restored: ${purchaseDetails.productID}');
          onPurchaseUpdated(purchaseDetails);
          if (purchaseDetails.pendingCompletePurchase) {
            _inAppPurchase.completePurchase(purchaseDetails);
          }
          break;

        case PurchaseStatus.canceled:
          print('Purchase canceled: ${purchaseDetails.productID}');
          onError('تم إلغاء عملية الشراء');
          if (purchaseDetails.pendingCompletePurchase) {
            _inAppPurchase.completePurchase(purchaseDetails);
          }
          break;
      }
    }
  }

  Future<List<ProductDetails>> getProducts(List<String> productIds) async {
    print('Querying products: $productIds');

    final bool available = await isAvailable();
    if (!available) {
      throw Exception('متجر Google Play غير متاح');
    }

    print('Google Play Billing is available, querying products...');
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(productIds.toSet());

    print('Query response received');
    print('Error: ${response.error}');
    print('Product details count: ${response.productDetails.length}');
    print('Not found IDs: ${response.notFoundIDs}');

    if (response.error != null) {
      print('Product query error: ${response.error!.message}');
      print('Error code: ${response.error!.code}');
      throw Exception('خطأ في جلب المنتجات: ${response.error!.message}');
    }

    if (response.productDetails.isEmpty) {
      print('No products found for IDs: $productIds');
      print('Not found IDs: ${response.notFoundIDs}');
      
      String errorMessage = 'لم يتم العثور على المنتجات المطلوبة.\n\n';
      errorMessage += 'المعرفات المطلوبة: $productIds\n';
      if (response.notFoundIDs.isNotEmpty) {
        errorMessage += 'المعرفات غير الموجودة: ${response.notFoundIDs}\n';
      }
      errorMessage += '\nتأكد من:\n';
      errorMessage += '1. رفع التطبيق على Google Play Console (Internal Testing أو أعلى)\n';
      errorMessage += '2. تفعيل المنتجات في Google Play Console\n';
      errorMessage += '3. إضافة حسابك كـ Tester في Internal Testing\n';
      errorMessage += '4. استخدام نفس Package Name الموجود في Google Play Console\n';
      errorMessage += '5. الانتظار 2-3 ساعات بعد رفع التطبيق للمرة الأولى\n';
      errorMessage += '6. التأكد من أن المنتجات من نوع "One-time products" (ProductType.inapp) وليست "Subscriptions"\n';
      errorMessage += '7. في Google Play Console: Products > One-time products (وليس Subscriptions)';
      
      throw Exception(errorMessage);
    }

    print('Found ${response.productDetails.length} products');
    for (var product in response.productDetails) {
      final displayName = getDisplayName(product.id, product.title);
      print('Product: ${product.id}, Price: ${product.price}, Title: $displayName (Original: ${product.title})');
    }

    return response.productDetails;
  }

  Future<void> purchaseProduct(ProductDetails productDetails) async {
    final displayName = getDisplayName(productDetails.id, productDetails.title);
    print('Starting purchase for: ${productDetails.id}');
    print('Product details:');
    print('  - ID: ${productDetails.id}');
    print('  - Price: ${productDetails.price}');
    print('  - Title: $displayName (Original: ${productDetails.title})');
    print('  - Description: ${productDetails.description}');

    PurchaseParam purchaseParam;

    if (Platform.isAndroid) {
      final GooglePlayPurchaseParam androidParam = GooglePlayPurchaseParam(
        productDetails: productDetails,
        changeSubscriptionParam: null,
        applicationUserName: null,
      );
      purchaseParam = androidParam;
    } else {
      purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );
    }

    try {
      print('Calling buyNonConsumable for Lifetime access (One-time product)...');
      print('Product Type: ProductType.inapp (One-time product)');
      print('Purchase param type: ${purchaseParam.runtimeType}');

      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!success) {
        print('buyNonConsumable returned false');
        throw Exception('فشل بدء عملية الشراء.\n\n'
            'تأكد من:\n'
            '1. رفع التطبيق على Google Play Console في Internal Testing\n'
            '2. تفعيل التطبيق في Internal Testing Track (ليس فقط رفعه)\n'
            '3. إضافة حسابك كـ Tester في Internal Testing\n'
            '4. تسجيل الدخول بحساب Tester على الجهاز\n'
            '5. تفعيل المنتجات في Google Play Console\n'
            '6. الانتظار 2-3 ساعات بعد رفع التطبيق للمرة الأولى');
      }

      print('Purchase initiated successfully - waiting for Google Play response...');
      print('Note: If you see "item not found" error, check Internal Testing setup');
    } catch (e) {
      print('Purchase error: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: ${StackTrace.current}');
      if (e is Exception) {
        throw e;
      }
      throw Exception('خطأ في عملية الشراء: $e');
    }
  }

  Future<void> completePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.pendingCompletePurchase) {
      print('Completing purchase: ${purchaseDetails.productID}');
      await _inAppPurchase.completePurchase(purchaseDetails);
      print('Purchase completed successfully: ${purchaseDetails.productID}');
    } else {
      print('Purchase ${purchaseDetails.productID} does not need completion');
    }
  }

  Future<void> restorePurchases() async {
    print('Restoring purchases...');
    try {
      await _inAppPurchase.restorePurchases();
      print('Restore purchases completed');
    } catch (e) {
      print('Restore purchases error: $e');
      throw Exception('فشل استرجاع المشتريات: $e');
    }
  }

  void dispose() {
    print('Disposing GooglePlayBillingService');
    _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
  }
}
