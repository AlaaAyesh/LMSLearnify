class Validators {
  // Email Validator
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  // Password Validator
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }
// Required Field Validator
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }
// Phone Validator
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    if (value.length < 10) {
      return 'رقم الهاتف غير صحيح';
    }
    return null;
  }
// Age Validator
  static String? age(String? value) {
    if (value == null || value.isEmpty) {
      return 'السن مطلوب';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'السن يجب أن يكون رقماً';
    }
    if (age < 5 || age > 18) {
      return 'السن يجب أن يكون بين 5 و 18';
    }
    return null;
  }
}