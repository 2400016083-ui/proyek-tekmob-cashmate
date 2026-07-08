import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction_model.dart';

class TransactionService {
  CollectionReference<Map<String, dynamic>> _transactionsOf(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions');
  }

  Stream<List<TransactionModel>> watchTransactions(String uid) {
    return _transactionsOf(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(TransactionModel.fromFirestore).toList());
  }

  Future<void> addTransaction(String uid, TransactionModel transaction) {
    return _transactionsOf(uid).add(transaction.toFirestoreMap());
  }
}
