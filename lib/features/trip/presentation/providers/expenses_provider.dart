import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/expense_remote_datasource.dart';
import '../../domain/entities/expense_entity.dart';

final expenseDataSourceProvider = Provider<ExpenseRemoteDataSource>((ref) {
  return ExpenseRemoteDataSource();
});

final tripExpensesProvider = StreamProvider.family<List<ExpenseEntity>, String>(
  (ref, tripId) {
    final dataSource = ref.watch(expenseDataSourceProvider);
    return dataSource.getTripExpenses(tripId);
  },
);

final expenseControllerProvider =
    StateNotifierProvider<ExpenseController, ExpenseState>((ref) {
  final dataSource = ref.watch(expenseDataSourceProvider);
  return ExpenseController(dataSource);
});

class ExpenseState {
  final bool isLoading;
  final String? error;

  ExpenseState({this.isLoading = false, this.error});

  ExpenseState copyWith({bool? isLoading, String? error}) {
    return ExpenseState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ExpenseController extends StateNotifier<ExpenseState> {
  final ExpenseRemoteDataSource _dataSource;

  ExpenseController(this._dataSource) : super(ExpenseState());

  Future<bool> createExpense({
    required String tripId,
    required String title,
    required double amount,
    required String currency,
    required String paidBy,
    required List<String> participants,
    required ExpenseCategory category,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dataSource.createExpense(
        tripId: tripId,
        title: title,
        amount: amount,
        currency: currency,
        paidBy: paidBy,
        participants: participants,
        category: category,
      );
      state = ExpenseState();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateExpense({
    required String expenseId,
    required String title,
    required double amount,
    required String currency,
    required List<String> participants,
    required ExpenseCategory category,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dataSource.updateExpense(
        expenseId: expenseId,
        title: title,
        amount: amount,
        currency: currency,
        participants: participants,
        category: category,
      );
      state = ExpenseState();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteExpense(String expenseId) async {
    try {
      await _dataSource.deleteExpense(expenseId);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}
