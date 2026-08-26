import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/storage_keys.dart';
import '../storage/i_storage.dart';

class LocaleController extends GetxController {
  LocaleController(this._storage);

  final IStorage _storage;

  Locale locale = const Locale('en', 'US');

  bool get isArabic => locale.languageCode == 'ar';

  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  void toggleLocale() {
    setLocale(isArabic ? const Locale('en', 'US') : const Locale('ar', 'SA'));
  }

  void setLocale(Locale value) {
    locale = value;
    Get.updateLocale(value);
    _storage.write(StorageKeys.languageCode, value.languageCode);
    _storage.write(StorageKeys.countryCode, value.countryCode);
    update();
  }

  void _restore() {
    final language = _storage.read<String>(StorageKeys.languageCode);
    final country = _storage.read<String>(StorageKeys.countryCode);
    if (language == null) return;
    locale = Locale(language, country);
    Get.updateLocale(locale);
  }
}
