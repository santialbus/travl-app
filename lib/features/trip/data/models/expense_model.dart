import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    required super.tripId,
    required super.title,
    required super.amount,
    required super.currency,
    required super.paidBy,
    required super.participants,
    required super.category,
    required super.createdAt,
  });

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id: doc.id,
      tripId: data['tripId'] as String,
      title: data['title'] as String,
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] as String,
      paidBy: data['paidBy'] as String,
      participants: List<String>.from(data['participants'] ?? []),
      category: ExpenseCategory.fromString(data['category'] as String),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'tripId': tripId,
      'title': title,
      'amount': amount,
      'currency': currency,
      'paidBy': paidBy,
      'participants': participants,
      'category': category.value,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}