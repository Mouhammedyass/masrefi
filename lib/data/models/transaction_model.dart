class TransactionModel {
  // TODO: 1. عرف المتغيرات الأساسية للمعاملة (id, title, amount, category, date, isExpense, note)
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isExpense;
  final String? note;


  // TODO: 2. اعمل الـ Constructor واجعله يتطلب (required) البيانات الأساسية، والـ note تكون nullable
  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isExpense,
    this.note});


  // TODO: 3. اكتب الـ factory constructor اللي اسمه fromJson
  // - بياخد Map<String, dynamic> json
  // - بيرجع TransactionModel
  // - خلي بالك: الـ amount تحوله لـ double باستخدام (as num).toDouble()
  // - الـ date تحوله لـ DateTime باستخدام DateTime.parse()
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
        id: json['id'],
        title: json['title'],
        amount: (json['amount'] as num).toDouble(),
        category: json['category'],
        date: DateTime.parse(json['date']),
        isExpense: json['isExpense'],
        note: json['note']
    );
  }

  // TODO: 4. اكتب الـ method اللي اسمه toJson
  // - بيرجع Map<String, dynamic>
  // - تحول الـ date فيه لـ String باستخدام .toIso8601String()
  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'title' : title,
      'amount' : amount,
      'category' : category,
      'date' : date.toIso8601String(),
      'isExpense' : isExpense,
      'note' : note,
    };
  }
}