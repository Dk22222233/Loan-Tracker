class TransactionModel {
  final int id;
  final int personId;
  final int loan;
  final int paid;
  final DateTime dateTime;
  final String? note;
  const TransactionModel(
      {required this.id,
      required this.personId,
      required this.loan,
      required this.paid,
      required this.dateTime,
      this.note});
  Map<String, dynamic> toMap() {
    return {
      'personId': personId,
      'loan': loan,
      'paid': paid,
      'dateTime': dateTime.toIso8601String(),
      'note': note
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
        id: map['id'],
        personId: map['personId'],
        loan: map['loan'],
        paid: map['paid'],
        dateTime: DateTime.parse(map['dateTime']),
        note: map['note']);
  }
}
