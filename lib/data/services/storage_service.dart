import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  final GetStorage _box = GetStorage();

  // تهيئة المكتبة عند بداية تشغيل التطبيق
  Future<StorageService> init() async {
    await GetStorage.init();
    return this;
  }

  // قراءة بيانات بـ Key معين
  T? readData<T>(String key) {
    return _box.read<T>(key);
  }

  // كتابة بيانات بـ Key معين
  Future<void> writeData(String key, dynamic value) async {
    await _box.write(key, value);
  }

  // مسح عنصر معين
  Future<void> removeData(String key) async {
    await _box.remove(key);
  }

  // مسح كل البيانات المسجلة
  Future<void> clearAll() async {
    await _box.erase();
  }
}