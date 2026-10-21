import 'package:get/get.dart';
import '../../data/data_sources/local_data_source.dart';
import '../../data/data_sources/remote_data_source.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../data/services/storage_service.dart';
import '../../domain/repositories/expense_repository.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Remote DataSource
    Get.lazyPut<RemoteDataSource>(
          () => RemoteDataSourceImpl(),
    );

    // 2. Local DataSource (Injecting StorageService)
    Get.lazyPut<LocalDataSource>(
          () => LocalDataSourceImpl(Get.find<StorageService>()),
    );

    // 3. Repository (Injecting Local & Remote DataSources)
    Get.lazyPut<ExpenseRepository>(
          () => ExpenseRepositoryImpl(
        localDataSource: Get.find<LocalDataSource>(),
        remoteDataSource: Get.find<RemoteDataSource>(),
      ),
    );

    // 4. Controller (Injecting ExpenseRepository)
    Get.lazyPut<HomeController>(
          () => HomeController(repository: Get.find<ExpenseRepository>()),
    );
  }
}