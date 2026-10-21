import 'package:get/get.dart';
import '../../data/data_sources/local_data_source.dart';
import '../../data/data_sources/remote_data_source.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../data/services/storage_service.dart';
import '../../domain/repositories/expense_repository.dart';
import '../controllers/main_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/converter_controller.dart';
import '../controllers/settings_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // 1. حقن الـ Data Sources أولاً
// استبدل سطر LocalDataSource بالسطر ده:
    Get.lazyPut<LocalDataSource>(() => LocalDataSourceImpl(Get.find<StorageService>()));
    Get.lazyPut<RemoteDataSource>(() => RemoteDataSourceImpl());

    // 2. حقن الـ Repository المطلوب (ExpenseRepository)
    Get.lazyPut<ExpenseRepository>(
          () => ExpenseRepositoryImpl(
        localDataSource: Get.find<LocalDataSource>(),
        remoteDataSource: Get.find<RemoteDataSource>(),
      ),
    );

    // 3. حقن الـ Controllers بعد توفر الـ Repository
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<HomeController>(() => HomeController(repository: Get.find<ExpenseRepository>()));
    Get.lazyPut<ConverterController>(() => ConverterController(repository: Get.find<ExpenseRepository>()));
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}