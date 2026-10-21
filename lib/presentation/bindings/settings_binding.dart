import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: 1. Inject SettingsController via Get.lazyPut
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}