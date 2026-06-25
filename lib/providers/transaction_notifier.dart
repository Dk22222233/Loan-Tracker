import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qarazdare/database/dbhelper.dart';
import 'package:qarazdare/models/transaction_model.dart';

class TransactionNotifier extends Notifier<List<TransactionModel>> {
  @override
  List<TransactionModel> build() {
    return [];
  }

  Future<void> insertTransactions(TransactionModel transactions) async {
    final db = Dbhelper();
    await db.insertLoan(transactions);
    final List<TransactionModel> newList = List.from(state);
    newList.add(transactions);
    state = newList;
  }

  Future<void> getTransPerson(int personId) async {
    final db = Dbhelper();
    final maps = await db.getTranPerson(personId);
    List<TransactionModel> newObj = [];

    for (var map in maps) {
      newObj.add(TransactionModel.fromMap(map)); // ✅ ADD to list
    }

    state = newObj;
  }

  int getTotalLoan() {
    int totalLoan =
        state.fold<int>(0, (sum, transaction) => sum + transaction.loan);
    int totalPaid =
        state.fold<int>(0, (sum, transaction) => sum + transaction.paid);

    return totalLoan - totalPaid; // This returns the leftover amount
  }

  // In transaction_notifier.dart

  Future<List<Map<String, dynamic>>> getDailyLoanAmounts() async {
    final db = Dbhelper();
    return await db.getDailyLoanAmounts();
  }
}

final transactionProvider =
    NotifierProvider<TransactionNotifier, List<TransactionModel>>(
        () => TransactionNotifier());
