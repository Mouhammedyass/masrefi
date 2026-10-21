import 'package:get/get.dart';
import '../../domain/repositories/expense_repository.dart';
import '../controllers/converter_controller.dart';

class ConverterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConverterController>(
          () => ConverterController(repository: Get.find<ExpenseRepository>()),
    );
    // TODO: 1. Inject ConverterController via Get.lazyPut
    // Hint: Pass Get.find<ExpenseRepository>() to its constructor
  }
}