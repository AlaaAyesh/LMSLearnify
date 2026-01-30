import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/payment_model.dart';
import '../models/subscription_model.dart';

abstract class SubscriptionRemoteDataSource {
  /// Get all available subscriptions
  /// Throws [ServerException] on failure
  Future<List<SubscriptionModel>> getSubscriptions();

  /// Get a specific subscription by its ID
  /// Throws [ServerException] on failure
  Future<SubscriptionModel> getSubscriptionById(int id);

  /// Create a new subscription
  /// Throws [ServerException] on failure
  Future<SubscriptionModel> createSubscription(CreateSubscriptionRequest request);

  /// Update an existing subscription
  /// Throws [ServerException] on failure
  Future<SubscriptionModel> updateSubscription(int id, UpdateSubscriptionRequest request);

  /// Process a payment for a subscription or course
  /// Throws [ServerException] on failure
  Future<PaymentResponseModel> processPayment(ProcessPaymentRequest request);

  /// Validate a coupon code for a subscription
  /// Throws [ServerException] on failure
  Future<Map<String, dynamic>> validateCoupon({
    required String code,
    required String type,
    required int id,
  });
  /// Verify In-App Purchase receipt
  Future<void> verifyIapReceipt({
    required String receiptData,
    required String transactionId,
    required int purchaseId,
    required String store,
  });

}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final DioClient dioClient;

  SubscriptionRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<SubscriptionModel>> getSubscriptions() async {
    try {
      final response = await dioClient.get(ApiConstants.subscriptions);

      if (response.statusCode == 200) {
        List<dynamic> subscriptionsJson;
        final responseData = response.data;

        // Handle different response structures
        if (responseData['data'] is Map && responseData['data']['data'] is List) {
          // Nested structure: { data: { data: [...] } }
          subscriptionsJson = responseData['data']['data'];
        } else if (responseData['data'] is List) {
          // Direct structure: { data: [...] }
          subscriptionsJson = responseData['data'];
        } else if (responseData['subscriptions'] is List) {
          // Alternative structure: { subscriptions: [...] }
          subscriptionsJson = responseData['subscriptions'];
        } else if (responseData is List) {
          // Raw list response
          subscriptionsJson = responseData;
        } else {
          subscriptionsJson = [];
        }

        return subscriptionsJson
            .map((json) => SubscriptionModel.fromJson(json))
            .toList();
      }

      throw ServerException(
        message: response.data['message'] ?? 'فشل في جلب الاشتراكات',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل في جلب الاشتراكات');
    }
  }

  @override
  Future<SubscriptionModel> getSubscriptionById(int id) async {
    try {
      final response = await dioClient.get('${ApiConstants.subscriptions}/$id');

      if (response.statusCode == 200) {
        final responseData = response.data;
        Map<String, dynamic> subscriptionData;

        // Handle different response structures
        if (responseData['data'] is Map && responseData['data']['data'] is Map) {
          subscriptionData = responseData['data']['data'];
        } else if (responseData['data'] is Map) {
          subscriptionData = responseData['data'];
        } else if (responseData['subscription'] is Map) {
          subscriptionData = responseData['subscription'];
        } else {
          subscriptionData = responseData;
        }

        return SubscriptionModel.fromJson(subscriptionData);
      }

      throw ServerException(
        message: response.data['message'] ?? 'فشل في جلب الاشتراك',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل في جلب الاشتراك');
    }
  }

  @override
  Future<SubscriptionModel> createSubscription(CreateSubscriptionRequest request) async {
    try {
      final response = await dioClient.post(
        ApiConstants.subscriptions,
        data: FormData.fromMap(request.toFormData()),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        Map<String, dynamic> subscriptionData;

        if (responseData['data'] is Map) {
          subscriptionData = responseData['data'];
        } else if (responseData['subscription'] is Map) {
          subscriptionData = responseData['subscription'];
        } else {
          subscriptionData = responseData;
        }

        return SubscriptionModel.fromJson(subscriptionData);
      }

      throw ServerException(
        message: response.data['message'] ?? 'فشل في إنشاء الاشتراك',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل في إنشاء الاشتراك');
    }
  }

  @override
  Future<SubscriptionModel> updateSubscription(int id, UpdateSubscriptionRequest request) async {
    try {
      // Using POST with _method: PUT for method spoofing
      final response = await dioClient.post(
        '${ApiConstants.subscriptions}/$id',
        data: FormData.fromMap(request.toFormData()),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        Map<String, dynamic> subscriptionData;

        if (responseData['data'] is Map) {
          subscriptionData = responseData['data'];
        } else if (responseData['subscription'] is Map) {
          subscriptionData = responseData['subscription'];
        } else {
          subscriptionData = responseData;
        }

        return SubscriptionModel.fromJson(subscriptionData);
      }

      throw ServerException(
        message: response.data['message'] ?? 'فشل في تحديث الاشتراك',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل في تحديث الاشتراك');
    }
  }

  @override
  Future<PaymentResponseModel> processPayment(ProcessPaymentRequest request) async {
    try {
      final response = await dioClient.post(
        ApiConstants.processPayment,
        data: FormData.fromMap(request.toFormData()),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        return PaymentResponseModel.fromJson(response.data);
      }

      throw ServerException(
        message: response.data['message'] ?? 'فشل في معالجة الدفع',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل في معالجة الدفع');
    }
  }

  @override
  Future<Map<String, dynamic>> validateCoupon({
    required String code,
    required String type,
    required int id,
  }) async {
    try {
      final response = await dioClient.post(
        ApiConstants.validateCoupon,
        data: FormData.fromMap({
          'code': code,
          'type': type,
          'id': id.toString(),
        }),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        // Return the response data which may contain discount info
        return response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : {'valid': true};
      }

      throw ServerException(
        message: response.data['message'] ?? 'فشل في التحقق من الكوبون',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      // Handle 422 validation errors specifically
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        String errorMessage = 'الكوبون غير صالح';
        
        if (errors != null && errors is Map) {
          final codeErrors = errors['code'];
          if (codeErrors is List && codeErrors.isNotEmpty) {
            errorMessage = codeErrors.first.toString();
          } else if (e.response?.data['message'] != null) {
            errorMessage = e.response!.data['message'];
          }
        } else if (e.response?.data['message'] != null) {
          errorMessage = e.response!.data['message'];
        }
        
        throw ServerException(
          message: errorMessage,
          statusCode: 422,
        );
      }
      
      throw _handleDioError(e, 'فشل في التحقق من الكوبون');
    }
  }

  ServerException _handleDioError(DioException e, String defaultMessage) {
    String errorMessage = defaultMessage;

    if (e.response?.statusCode == 401) {
      errorMessage = 'يجب تسجيل الدخول أولاً';
    } else if (e.response?.statusCode == 403) {
      errorMessage = e.response?.data['message'] ?? 'غير مصرح لك بهذا الإجراء';
    } else if (e.response?.statusCode == 404) {
      errorMessage = e.response?.data['message'] ?? 'الاشتراك غير موجود';
    } else if (e.response?.statusCode == 422) {
      final errors = e.response?.data['errors'];
      if (errors != null && errors is Map) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          errorMessage = firstError.first.toString();
        }
      } else {
        errorMessage = e.response?.data['message'] ?? 'بيانات غير صالحة';
      }
    } else if (e.response?.data != null && e.response?.data['message'] != null) {
      errorMessage = e.response?.data['message'];
    }

    return ServerException(
      message: errorMessage,
      statusCode: e.response?.statusCode,
    );
  }
  @override
  Future<void> verifyIapReceipt({
    required String receiptData,
    required String transactionId,
    required int purchaseId,
    required String store,
  }) async {
    try {
      final response = await dioClient.post(
        ApiConstants.validateIapReceipt,
        data: {
          'receipt_data': receiptData,
          'transaction_id': transactionId,
          'purchase_id': purchaseId,
          'store': store, // gplay | iap
        },
      );

      if (response.statusCode == 200) return;

      throw ServerException(
        message: response.data['message'] ?? 'فشل التحقق من عملية الشراء',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل التحقق من عملية الشراء');
    }
  }

}


