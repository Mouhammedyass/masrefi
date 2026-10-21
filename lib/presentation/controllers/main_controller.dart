import 'package:get/get.dart';

import 'converter_controller.dart';
import 'home_controller.dart';

class MainController extends GetxController {
  var currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;

    // لما المستخدم يدوس على تاب الـ Home (مؤشر 0)
    if (index == 0) {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadDefaultCurrency();
      }
    }
    // لما المستخدم يدوس على تاب الـ Converter (مؤشر 1)
    else if (index == 1) {
      if (Get.isRegistered<ConverterController>()) {
        Get.find<ConverterController>().loadBaseCurrency();
      }
    }
  }
}