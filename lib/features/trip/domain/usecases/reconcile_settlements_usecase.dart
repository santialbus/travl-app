/*import '../entities/expense_entity.dart';
import '../entities/settlement_entity.dart';

class ReconcileSettlementsUseCase {
  List<SettlementEntity> call({
    required String tripId,
    required List<ExpenseEntity> expenses,
    required List<SettlementEntity> settlements,
    required Map<String, double> balances,
    required Map<String, double> rates,
    required String currency,
  }) {
    final coveredExpenseIds =
        settlements.expand((settlement) => settlement.expenseIds).toSet();

    final unsettledExpenses = expenses
        .where((expense) => !coveredExpenseIds.contains(expense.id))
        .toList();

    if (unsettledExpenses.isEmpty) {
      return [];
    }

    final debtMatrix = <String, Map<String, double>>{};

    for (final expense in unsettledExpenses) {
      if (expense.participants.isEmpty) continue;

      final rate = rates[expense.currency] ?? 1;
      final convertedShare =
          (expense.amount / expense.participants.length) * rate;

      for (final participant in expense.participants) {
        if (participant == expense.paidBy) continue;

        final creditorDebts = debtMatrix.putIfAbsent(
          participant,
          () => {},
        );

        creditorDebts[expense.paidBy] =
            (creditorDebts[expense.paidBy] ?? 0) + convertedShare;
      }
    }

    final debtors = <String, double>{};
    final creditors = <String, double>{};

    for (final entry in debtMatrix.entries) {
      final debtor = entry.key;

      for (final debt in entry.value.entries) {
        final creditor = debt.key;
        final amount = debt.value;

        debtors[debtor] = (debtors[debtor] ?? 0) + amount;
        creditors[creditor] = (creditors[creditor] ?? 0) + amount;
      }
    }

    final sortedDebtors = debtors.entries
        .where((entry) => entry.value > 0.01)
        .map((entry) => MapEntry(entry.key, entry.value))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sortedCreditors = creditors.entries
        .where((entry) => entry.value > 0.01)
        .map((entry) => MapEntry(entry.key, entry.value))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final newSettlements = <SettlementEntity>[];

    int debtorIndex = 0;
    int creditorIndex = 0;

    while (debtorIndex < sortedDebtors.length &&
        creditorIndex < sortedCreditors.length) {
      final debtor = sortedDebtors[debtorIndex];
      final creditor = sortedCreditors[creditorIndex];

      final amount =
          debtor.value < creditor.value ? debtor.value : creditor.value;

      final expenseIds = _getExpenseIdsForPair(
        debtor: debtor.key,
        creditor: creditor.key,
        expenses: unsettledExpenses,
        rates: rates,
        requiredAmount: amount,
      );

      if (amount > 0.01 && expenseIds.isNotEmpty) {
        newSettlements.add(
          SettlementEntity(
            id: '',
            tripId: tripId,
            fromUserId: debtor.key,
            toUserId: creditor.key,
            amount: amount,
            currency: currency,
            expenseIds: expenseIds,
            isPaid: false,
            paidAt: null,
          ),
        );
      }

      final remainingDebtor = debtor.value - amount;
      final remainingCreditor = creditor.value - amount;

      sortedDebtors[debtorIndex] = MapEntry(
        debtor.key,
        remainingDebtor,
      );

      sortedCreditors[creditorIndex] = MapEntry(
        creditor.key,
        remainingCreditor,
      );

      if (remainingDebtor < 0.01) {
        debtorIndex++;
      }

      if (remainingCreditor < 0.01) {
        creditorIndex++;
      }
    }

    return _mergePendingSettlements(
      newSettlements: newSettlements,
      settlements: settlements,
    );
  }

  List<String> _getExpenseIdsForPair({
    required String debtor,
    required String creditor,
    required List<ExpenseEntity> expenses,
    required Map<String, double> rates,
    required double requiredAmount,
  }) {
    final expenseIds = <String>[];
    double accumulatedAmount = 0;

    for (final expense in expenses) {
      if (expense.paidBy != creditor) continue;
      if (!expense.participants.contains(debtor)) continue;
      if (expense.participants.isEmpty) continue;

      final rate = rates[expense.currency] ?? 1;
      final share = (expense.amount / expense.participants.length) * rate;

      expenseIds.add(expense.id);
      accumulatedAmount += share;

      if (accumulatedAmount >= requiredAmount - 0.01) {
        break;
      }
    }

    return expenseIds;
  }

  List<SettlementEntity> _mergePendingSettlements({
    required List<SettlementEntity> newSettlements,
    required List<SettlementEntity> settlements,
  }) {
    final result = <SettlementEntity>[];

    for (final newSettlement in newSettlements) {
      final pendingSettlement =
          settlements.cast<SettlementEntity?>().firstWhere(
                (settlement) =>
                    settlement != null &&
                    !settlement.isPaid &&
                    settlement.fromUserId == newSettlement.fromUserId &&
                    settlement.toUserId == newSettlement.toUserId &&
                    settlement.currency == newSettlement.currency,
                orElse: () => null,
              );

      if (pendingSettlement == null) {
        result.add(newSettlement);
        continue;
      }

      result.add(
        SettlementEntity(
          id: pendingSettlement.id,
          tripId: pendingSettlement.tripId,
          fromUserId: pendingSettlement.fromUserId,
          toUserId: pendingSettlement.toUserId,
          amount: pendingSettlement.amount + newSettlement.amount,
          currency: pendingSettlement.currency,
          expenseIds: [
            ...pendingSettlement.expenseIds,
            ...newSettlement.expenseIds,
          ],
          isPaid: false,
          paidAt: null,
        ),
      );
    }

    return result;
  }
}
*/
