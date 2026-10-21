import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencies = ['USD', 'EGP', 'EUR', 'GBP', 'SAR', 'AED'];

    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // 1. تغيير العملة الأساسية
            Obx(() => ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.teal),
              title:  Text('default_currency'.tr),
              subtitle:  Text('base_currency'.tr),
              trailing: DropdownButton<String>(
                value: controller.selectedCurrency.value,
                items: currencies.map((curr) {
                  return DropdownMenuItem(value: curr, child: Text(curr));
                }).toList(),
                onChanged: (val) {
                  if (val != null) controller.changeDefaultCurrency(val);
                },
              ),
            )),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.language, color: Colors.blue),
              title: Text('app_language'.tr),
              subtitle: Text('display_language'.tr),
              trailing: Obx(() => DropdownButton<String>(
                // ربط القيمة بمتغير تفاعلي صريح داخل الـ Obx
                value: controller.currentLanguage.value,
                items: const [
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    controller.changeLanguage(val);
                  }
                },
              )),
            ),
            const Divider(),
            Obx(() => SwitchListTile(
              secondary: const Icon(Icons.dark_mode, color: Colors.indigo),
              title: Text('dark_mode'.tr),
              subtitle: Text('dark_mode_desc'.tr),
              value: controller.isDarkMode.value,
              onChanged: (val) {
                controller.toggleDarkMode(val);
              },
            )),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title:  Text('delete_transactions'.tr),
              subtitle:  Text('delete_description'.tr),
              onTap: () => controller.clearAllData(),
            ),
          ],
        ),
      ),
    );
  }
}