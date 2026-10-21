import 'package:get/get.dart';
import '../../data/services/storage_service.dart';
import 'package:flutter/material.dart';
class SettingsController extends GetxController {
  final StorageService storageService = Get.find<StorageService>();

  // 1. Declare selectedCurrency
  RxString selectedCurrency = 'EGP'.obs;
  RxString currentLanguage = 'en'.obs;
  RxBool isDarkMode = false.obs;
  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = storageService.readData<bool>('is_dark_mode') ?? false;
    selectedCurrency.value = storageService.readData<String>('default_currency') ?? 'EGP';
    String savedLang = storageService.readData<String>('app_language') ?? Get.locale?.languageCode ?? 'en';
    currentLanguage.value = savedLang;
  }

  // 2. Implement changeDefaultCurrency
  void changeDefaultCurrency(String newCurrency) {
    selectedCurrency.value = newCurrency;
    storageService.writeData('default_currency', newCurrency);
  }
  void changeLanguage(String langCode) {
    currentLanguage.value = langCode;
    storageService.writeData('app_language', langCode);
    Get.updateLocale(Locale(langCode));
  }

  void clearAllData() {
    Get.defaultDialog(
      title: 'confirm_clear_title'.tr,
      middleText: 'confirm_clear_msg'.tr,
      textConfirm: 'clear_data'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        storageService.clearAll();
        Get.back(); // قفل الـ Dialog
        Get.snackbar(
          'success'.tr,
          'deleted_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    storageService.writeData('is_dark_mode', value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }
}