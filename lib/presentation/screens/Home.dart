import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../data/models/transaction_model.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadInitialData(),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // Balance Summary Card
              Card(
                margin: const EdgeInsets.all(16.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                       Text(
                        'total_balance'.tr,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${controller.netBalance.toStringAsFixed(2)} ${controller.selectedCurrency.value}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: controller.netBalance >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                               Text('income'.tr, style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                '+${controller.totalIncome.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          Container(height: 30, width: 1, color: Colors.grey.shade300),
                          Column(
                            children: [
                               Text('expenses'.tr, style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                '-${controller.totalExpenses.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Transactions List Header
               Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'recent_transactions'.tr,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // Transactions List
              controller.transactions.isEmpty ?  Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: Center(child: Text('no_transactions'.tr)),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.transactions.length,
                itemBuilder: (context, index) {
                  final item = controller.transactions[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item.isExpense ? Colors.red.shade100 : Colors.green.shade100,
                      child: Icon(
                        item.isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                        color: item.isExpense ? Colors.red : Colors.green,
                      ),
                    ),
                    title: Text(item.title),
                    subtitle: Text(
                        '${item.category} | ${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${item.isExpense ? "-" : "+"}${item.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: item.isExpense ? Colors.red : Colors.green,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditTransactionDialog(context, item);
                            } else if (value == 'delete') {
                              Get.defaultDialog(
                                title: "confirm_delete".tr,
                                middleText: "delete_msg".tr,
                                textConfirm: "delete".tr,
                                textCancel: "cancel".tr,
                                confirmTextColor: Colors.white,
                                buttonColor: Colors.red,
                                onConfirm: () {
                                  controller.deleteTransaction(item.id);
                                  Get.back();
                                },
                              );
                            }
                          },
                          itemBuilder: (context) => [
                             PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('edit'.tr),
                                ],
                              ),
                            ),
                             PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('delete'.tr, style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final isExpense = true.obs;

    Get.defaultDialog(
      title: "add_transaction".tr,
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration:  InputDecoration(labelText: 'description'.tr),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration:  InputDecoration(labelText: 'amount'.tr),
            ),
            const SizedBox(height: 10),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label:  Text('expensed'.tr),
                  selected: isExpense.value,
                  onSelected: (val) => isExpense.value = true,
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label:  Text('Income'.tr),
                  selected: !isExpense.value,
                  onSelected: (val) => isExpense.value = false,
                ),
              ],
            )),
          ],
        ),
      ),
      textConfirm: "add".tr,
      textCancel: "cancel".tr,
      onConfirm: () {
        if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
          final newTransaction = TransactionModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: titleController.text,
            amount: double.tryParse(amountController.text) ?? 0.0,
            date: DateTime.now(),
            category: isExpense.value ? 'General Expense' : 'Income',
            isExpense: isExpense.value,
          );
          controller.addTransaction(newTransaction);
          Get.back();
        }
      },
    );
  }

  void _showEditTransactionDialog(BuildContext context, TransactionModel transaction) {
    final titleController = TextEditingController(text: transaction.title);
    final amountController = TextEditingController(text: transaction.amount.toString());
    final isExpense = transaction.isExpense.obs;

    Get.defaultDialog(
      title: "edit_transaction".tr,
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration:  InputDecoration(labelText: 'description'.tr),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration:  InputDecoration(labelText: 'amount'.tr),
            ),
            const SizedBox(height: 10),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label:  Text('expensed'.tr),
                  selected: isExpense.value,
                  onSelected: (val) => isExpense.value = true,
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label:  Text('Income'.tr),
                  selected: !isExpense.value,
                  onSelected: (val) => isExpense.value = false,
                ),
              ],
            )),
          ],
        ),
      ),
      textConfirm: "save".tr,
      textCancel: "cancel".tr,
      onConfirm: () {
        if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
          final updatedTransaction = TransactionModel(
            id: transaction.id,
            title: titleController.text,
            amount: double.tryParse(amountController.text) ?? 0.0,
            date: transaction.date,
            category: isExpense.value ? 'General Expense' : 'Income',
            isExpense: isExpense.value,
          );
          controller.updateTransaction(updatedTransaction);
          Get.back();
        }
      },
    );
  }
}