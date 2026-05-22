import '../repositories/trip_repository.dart';
import '../entities/expense_entity.dart';

class AddExpense {
  final TripRepository repository;
  AddExpense(this.repository);

  Future<void> call(String tripId, ExpenseEntity expense) async {}
}
