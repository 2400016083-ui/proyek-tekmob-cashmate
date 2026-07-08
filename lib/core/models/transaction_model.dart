import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String title;
  final String category;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String? note;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.type,
    required this.amount,
    required this.date,
    this.note,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'type': type.name,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory TransactionModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TransactionModel(
      id: doc.id,
      title: data['title'] as String,
      category: data['category'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.expense,
      ),
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'] as String?,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'title': title,
      'category': category,
      'type': type.name,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'note': note,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
