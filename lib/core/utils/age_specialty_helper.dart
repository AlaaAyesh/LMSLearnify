/// Helper class to calculate age and determine specialty based on birthday
class AgeSpecialtyHelper {
  /// Specialty age ranges
  static const Map<int, AgeRange> specialtyAgeRanges = {
    1: AgeRange(minAge: 3, maxAge: 5, nameAr: 'الأطفال 3-5 سنوات', nameEn: 'Ages 3-5'),
    2: AgeRange(minAge: 6, maxAge: 9, nameAr: 'الأطفال 6-9 سنوات', nameEn: 'Ages 6-9'),
    3: AgeRange(minAge: 10, maxAge: 12, nameAr: 'الأطفال 10-12 سنوات', nameEn: 'Ages 10-12'),
    4: AgeRange(minAge: 13, maxAge: 15, nameAr: 'الأطفال 13-15 سنوات', nameEn: 'Ages 13-15'),
  };

  /// Calculate age from birthday
  static int calculateAge(DateTime birthday) {
    final now = DateTime.now();
    int age = now.year - birthday.year;
    
    // Adjust if birthday hasn't occurred this year
    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    
    return age;
  }

  /// Get specialty ID based on age
  /// Returns null if age is out of range (< 3 or > 15)
  static int? getSpecialtyIdFromAge(int age) {
    if (age >= 3 && age <= 5) return 1;
    if (age >= 6 && age <= 9) return 2;
    if (age >= 10 && age <= 12) return 3;
    if (age >= 13 && age <= 15) return 4;
    return null; // Age out of range
  }

  /// Get specialty ID from birthday string (YYYY-MM-DD)
  static int? getSpecialtyIdFromBirthday(String? birthday) {
    if (birthday == null || birthday.isEmpty) return null;
    
    try {
      final parts = birthday.split('-');
      if (parts.length != 3) return null;
      
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      
      final birthDate = DateTime(year, month, day);
      final age = calculateAge(birthDate);
      
      return getSpecialtyIdFromAge(age);
    } catch (e) {
      return null;
    }
  }

  /// Get specialty name in Arabic based on age
  static String? getSpecialtyNameAr(int age) {
    final specialtyId = getSpecialtyIdFromAge(age);
    if (specialtyId == null) return null;
    return specialtyAgeRanges[specialtyId]?.nameAr;
  }

  /// Check if age is valid for registration (3-15 years)
  static bool isValidAge(int age) {
    return age >= 3 && age <= 15;
  }

  /// Get age validation message
  static String? getAgeValidationMessage(int age) {
    if (age < 3) {
      return 'العمر يجب أن يكون 3 سنوات على الأقل';
    }
    if (age > 15) {
      return 'العمر يجب أن يكون 15 سنة أو أقل';
    }
    return null;
  }
}

class AgeRange {
  final int minAge;
  final int maxAge;
  final String nameAr;
  final String nameEn;

  const AgeRange({
    required this.minAge,
    required this.maxAge,
    required this.nameAr,
    required this.nameEn,
  });
}

