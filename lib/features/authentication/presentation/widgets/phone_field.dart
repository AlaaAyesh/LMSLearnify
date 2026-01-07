import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String? countryCode;
  final ValueChanged<String> onCountryChanged;

  const PhoneField({
    super.key,
    required this.controller,
    this.countryCode,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          // Country Code Selector
          InkWell(
            onTap: () => _showCountryPicker(context),
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: AppColors.inputBorder),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getFlag(countryCode) ?? '🌍',
                    style: const TextStyle(fontSize: 20),
                  ),
                  SizedBox(width: 4),
                  Text(
                    countryCode ?? '+20',
                    style: TextStyle(
                      fontFamily: cairoFontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          // Phone Number Input
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: cairoFontFamily,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: 'رقم الهاتف',
                  hintStyle: TextStyle(
                    color: AppColors.textHint,
                    fontFamily: cairoFontFamily,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: Validators.phone,
              ),
            ),
          ),
          // Phone Icon
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(
              Icons.phone_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CountryPickerSheet(
        selectedCode: countryCode,
        onSelected: (code) {
          onCountryChanged(code);
          Navigator.pop(context);
        },
      ),
    );
  }

  String? _getFlag(String? code) {
    if (code == null) return null;
    final country = _countries.firstWhere(
      (c) => c['code'] == code,
      orElse: () => {'flag': '🇪🇬'},
    );
    return country['flag'];
  }

  static const List<Map<String, String>> _countries = [
    {'code': '+20', 'name': 'مصر', 'flag': '🇪🇬'},
    {'code': '+966', 'name': 'السعودية', 'flag': '🇸🇦'},
    {'code': '+971', 'name': 'الإمارات', 'flag': '🇦🇪'},
    {'code': '+965', 'name': 'الكويت', 'flag': '🇰🇼'},
    {'code': '+974', 'name': 'قطر', 'flag': '🇶🇦'},
    {'code': '+973', 'name': 'البحرين', 'flag': '🇧🇭'},
    {'code': '+968', 'name': 'عمان', 'flag': '🇴🇲'},
    {'code': '+962', 'name': 'الأردن', 'flag': '🇯🇴'},
    {'code': '+961', 'name': 'لبنان', 'flag': '🇱🇧'},
    {'code': '+964', 'name': 'العراق', 'flag': '🇮🇶'},
    {'code': '+963', 'name': 'سوريا', 'flag': '🇸🇾'},
    {'code': '+212', 'name': 'المغرب', 'flag': '🇲🇦'},
    {'code': '+216', 'name': 'تونس', 'flag': '🇹🇳'},
    {'code': '+213', 'name': 'الجزائر', 'flag': '🇩🇿'},
    {'code': '+218', 'name': 'ليبيا', 'flag': '🇱🇾'},
    {'code': '+249', 'name': 'السودان', 'flag': '🇸🇩'},
    {'code': '+967', 'name': 'اليمن', 'flag': '🇾🇪'},
  ];
}

class _CountryPickerSheet extends StatelessWidget {
  final String? selectedCode;
  final ValueChanged<String> onSelected;

  const _CountryPickerSheet({
    required this.selectedCode,
    required this.onSelected,
  });

  static const List<Map<String, String>> _countries = [
    {'code': '+20', 'name': 'مصر', 'flag': '🇪🇬'},
    {'code': '+966', 'name': 'السعودية', 'flag': '🇸🇦'},
    {'code': '+971', 'name': 'الإمارات', 'flag': '🇦🇪'},
    {'code': '+965', 'name': 'الكويت', 'flag': '🇰🇼'},
    {'code': '+974', 'name': 'قطر', 'flag': '🇶🇦'},
    {'code': '+973', 'name': 'البحرين', 'flag': '🇧🇭'},
    {'code': '+968', 'name': 'عمان', 'flag': '🇴🇲'},
    {'code': '+962', 'name': 'الأردن', 'flag': '🇯🇴'},
    {'code': '+961', 'name': 'لبنان', 'flag': '🇱🇧'},
    {'code': '+964', 'name': 'العراق', 'flag': '🇮🇶'},
    {'code': '+963', 'name': 'سوريا', 'flag': '🇸🇾'},
    {'code': '+212', 'name': 'المغرب', 'flag': '🇲🇦'},
    {'code': '+216', 'name': 'تونس', 'flag': '🇹🇳'},
    {'code': '+213', 'name': 'الجزائر', 'flag': '🇩🇿'},
    {'code': '+218', 'name': 'ليبيا', 'flag': '🇱🇾'},
    {'code': '+249', 'name': 'السودان', 'flag': '🇸🇩'},
    {'code': '+967', 'name': 'اليمن', 'flag': '🇾🇪'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.greyLight),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'اختر الدولة',
                  style: TextStyle(
                    fontFamily: cairoFontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        // Country List
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _countries.length,
            itemBuilder: (context, index) {
              final country = _countries[index];
              final isSelected = country['code'] == selectedCode;
              
              return ListTile(
                onTap: () => onSelected(country['code']!),
                leading: Text(
                  country['flag']!,
                  style: const TextStyle(fontSize: 28),
                ),
                title: Text(
                  country['name']!,
                  style: TextStyle(
                    fontFamily: cairoFontFamily,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  country['code']!,
                  style: TextStyle(
                    fontFamily: cairoFontFamily,
                    fontSize: 14,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                selected: isSelected,
                selectedTileColor: AppColors.primary.withOpacity(0.1),
              );
            },
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}



