import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'data/services/storage_service.dart';
import 'localizations/app_localization.dart';
import 'presentation/bindings/main_binding.dart';
import 'presentation/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Get.putAsync(() => StorageService().init());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = Get.find<StorageService>();

    // استرجاع آخر لغة تم حفظها، ولو مش موجودة يبق الافتراضي عربي
    final savedLang = storageService.readData<String>('app_language') ?? 'ar';

    // استرجاع حالة الثيم (هل هو دارك مود ولا لا؟)
    final isDarkMode = storageService.readData<bool>('is_dark_mode') ?? false;

    return GetMaterialApp(
      title: 'مصاريفي - Masrefi',
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: Locale(savedLang), // اللغة المحفوظة بفضل الله
      fallbackLocale: const Locale('en', 'US'),

      // الثيم النهاري
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),

      // الثيم الليلي (Dark Mode)
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),

      // تفعيل الوضع بناءً على آخر اختيار للمستخدم
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      initialBinding: MainBinding(),
      home: const MainScreen(),
    );
  }
}