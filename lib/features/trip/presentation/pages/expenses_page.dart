import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:travl/features/trip/presentation/providers/currency_provider.dart';
import 'package:travl/features/trip/presentation/providers/permissions_provider.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/expense_entity.dart';
import '../providers/expenses_provider.dart';
import '../providers/trip_provider.dart';
import '../providers/users_provider.dart';

class ExpensesPage extends ConsumerWidget {
  final String tripId;
  final bool isReadOnly;

  const ExpensesPage(
      {super.key, required this.tripId, this.isReadOnly = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(tripExpensesProvider(tripId));

    return expensesAsync.when(
      data: (expenses) => _ExpensesContent(
        tripId: tripId,
        expenses: expenses,
        isReadOnly: isReadOnly,
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(
            child: Text(
          context.tr('generic_error', params: {'error': e.toString()}),
        )),
      ),
    );
  }
}

class _ExpensesContent extends ConsumerWidget {
  final String tripId;
  final List<ExpenseEntity> expenses;
  final bool isReadOnly;

  const _ExpensesContent({
    required this.tripId,
    required this.expenses,
    this.isReadOnly = false,
  });

  Map<String, Map<String, double>> _calculateBalances() {
    final balances = <String, Map<String, double>>{};

    for (final expense in expenses) {
      if (expense.participants.isEmpty) continue;

      final currencyBalances = balances.putIfAbsent(expense.currency, () => {});
      final splitAmount = expense.amount / expense.participants.length;

      currencyBalances[expense.paidBy] =
          (currencyBalances[expense.paidBy] ?? 0) + expense.amount;

      for (final participant in expense.participants) {
        currencyBalances[participant] =
            (currencyBalances[participant] ?? 0) - splitAmount;
      }
    }

    return balances;
  }

  Map<String, List<ExpenseEntity>> _groupByDate() {
    final grouped = <String, List<ExpenseEntity>>{};

    for (final expense in expenses) {
      final dateKey =
          DateFormat('MMM dd').format(expense.createdAt).toUpperCase();

      grouped.putIfAbsent(dateKey, () => []).add(expense);
    }

    return grouped;
  }

  void _showAddExpenseSheet(BuildContext context, WidgetRef ref) async {
    final user = await ref.read(currentUserProvider.future);
    final trip = await ref.read(tripRepositoryProvider).getTrip(tripId);

    if (user == null) return;
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      //backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddExpenseBottomSheet(
        tripId: tripId,
        userId: user.id,
        members: trip.members.map((m) => m.userId).toList(),
      ),
    );
  }

  void _showEditExpenseSheet(
    BuildContext context,
    WidgetRef ref,
    ExpenseEntity expense,
  ) async {
    final user = await ref.read(currentUserProvider.future);
    final trip = await ref.read(tripRepositoryProvider).getTrip(tripId);

    if (user == null) return;
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddExpenseBottomSheet(
        tripId: tripId,
        userId: user.id,
        members: trip.members.map((m) => m.userId).toList(),
        expenseToEdit: expense,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(currentMemberProvider(tripId));
    final canManageAll =
        !isReadOnly && (member?.isHost == true || member?.isCoHost == true);
    final balances = _calculateBalances();
    final grouped = _groupByDate();
    final usedCurrencies = expenses.map((e) => e.currency).toSet().toList();

    return Scaffold(
      body: expenses.isEmpty
          ? _EmptyExpenses(
              onAdd:
                  isReadOnly ? null : () => _showAddExpenseSheet(context, ref),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummarySection(
                    expenses: expenses,
                    balances: balances,
                    usedCurrencies: usedCurrencies,
                  ),
                  const SizedBox(height: 8),
                  ...grouped.entries.map((entry) {
                    return _ExpenseDateGroup(
                      date: entry.key,
                      expenses: entry.value,
                      canManageAll: canManageAll,
                      userId: ref.watch(currentUserProvider).value?.id,
                      isReadOnly: isReadOnly,
                      onDelete: (id) => ref
                          .read(expenseControllerProvider.notifier)
                          .deleteExpense(id),
                      onEdit: (expense) =>
                          _showEditExpenseSheet(context, ref, expense),
                    );
                  }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      floatingActionButton: isReadOnly
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddExpenseSheet(context, ref),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }
}

String currencySymbol(String currency) {
  switch (currency) {
    case 'EUR':
      return '€';
    case 'USD':
      return '\$';
    case 'GBP':
      return '£';
    case 'CNY':
      return '¥';
    default:
      return currency;
  }
}

// ================= SUMMARY =================
class _SummarySection extends ConsumerStatefulWidget {
  final List<ExpenseEntity> expenses;
  final Map<String, Map<String, double>> balances;
  final List<String> usedCurrencies;

  const _SummarySection({
    required this.expenses,
    required this.balances,
    required this.usedCurrencies,
  });

  @override
  ConsumerState<_SummarySection> createState() => _SummarySectionState();
}

class _SummarySectionState extends ConsumerState<_SummarySection> {
  late String _selectedCurrency;

  double _calculateTotal(Map<String, double> rates) {
    return widget.expenses.fold(0, (total, expense) {
      final rate = rates[expense.currency] ?? 1;
      return total + (expense.amount * rate);
    });
  }

  Map<String, double> _calculateConvertedBalances(
    Map<String, double> rates,
  ) {
    final convertedBalances = <String, double>{};

    widget.balances.forEach((currency, currencyBalances) {
      final rate = rates[currency] ?? 1;

      currencyBalances.forEach((userId, balance) {
        convertedBalances[userId] =
            (convertedBalances[userId] ?? 0) + (balance * rate);
      });
    });

    return convertedBalances;
  }

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.usedCurrencies.first;

    ref.listenManual(currentUserProvider, (previous, next) {
      final preferredCurrency = next.valueOrNull?.preferredCurrency;

      if (preferredCurrency != null &&
          widget.usedCurrencies.contains(preferredCurrency)) {
        setState(() {
          _selectedCurrency == widget.usedCurrencies.first;
        });
      }
    });
  }

  void _showCurrencySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  context.tr('currency'),
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 20),
                ...widget.usedCurrencies.map((currency) {
                  final isSelected = _selectedCurrency == currency;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCurrency = currency;
                      });
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$currency (${currencySymbol(currency)})',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check,
                              color: AppColors.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Calcula quién debe a quién y cuánto
  Map<String, List<Map<String, dynamic>>> _calculateDebts(
    Map<String, double> rates,
  ) {
    final balances = _calculateConvertedBalances(rates);

    final debtors = <String, double>{};
    final creditors = <String, double>{};

    balances.forEach((userId, balance) {
      if (balance < -0.01) {
        debtors[userId] = balance.abs();
      } else if (balance > 0.01) {
        creditors[userId] = balance;
      }
    });

    final debts = <Map<String, dynamic>>[];

    final debtorList = debtors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final creditorList = creditors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    int i = 0;
    int j = 0;

    while (i < debtorList.length && j < creditorList.length) {
      final debtor = debtorList[i];
      final creditor = creditorList[j];

      final amount =
          debtor.value < creditor.value ? debtor.value : creditor.value;

      if (amount > 0.01) {
        debts.add({
          'from': debtor.key,
          'to': creditor.key,
          'amount': amount,
        });
      }

      debtorList[i] = MapEntry(debtor.key, debtor.value - amount);
      creditorList[j] = MapEntry(creditor.key, creditor.value - amount);

      if (debtorList[i].value < 0.01) i++;
      if (creditorList[j].value < 0.01) j++;
    }

    return {
      _selectedCurrency: debts,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ratesAsync = ref.watch(
      currencyRatesProvider(
        CurrencyRatesParams(
          sourceCurrencies: widget.usedCurrencies,
          targetCurrency: _selectedCurrency,
        ),
      ),
    );

    ratesAsync.when(
      data: (rates) {
        print('Currency rates received: $rates');
      },
      loading: () {
        print('Currency rates loading...');
      },
      error: (error, stackTrace) {
        print('Currency rates error: $error');
      },
    );

    final debts = ratesAsync.maybeWhen(
      data: (rates) => _calculateDebts(rates),
      orElse: () => <String, List<Map<String, dynamic>>>{},
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('total_spent'),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary(context),
                  letterSpacing: 1.2,
                ),
              ),
              InkWell(
                onTap: _showCurrencySheet,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedCurrency,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          ratesAsync.when(
            loading: () => const SizedBox(
              height: 43,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stackTrace) => Text(
              'Error loading currency rates',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary(context),
              ),
            ),
            data: (rates) {
              final total = _calculateTotal(rates);

              return Text(
                '${currencySymbol(_selectedCurrency)} ${total.toStringAsFixed(2)}',
                style: AppTextStyles.h1.copyWith(
                  fontSize: 36,
                  letterSpacing: -1,
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Balances por persona
          if (widget.balances.isNotEmpty) ...[
            Text(
              context.tr('balances').toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary(context),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.balances.entries.expand((currencyEntry) {
              final currency = currencyEntry.key;
              final currencyBalances = currencyEntry.value;

              return currencyBalances.entries.map((e) {
                final userAsync = ref.watch(userNameProvider(e.key));
                final name = userAsync.maybeWhen(
                  data: (n) => n,
                  orElse: () => '...',
                );
                final positive = e.value >= 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.card(context),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: AppTextStyles.labelLarge,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: AppTextStyles.bodyMedium),
                            Text(
                              positive
                                  ? context.tr('gets_back')
                                  : context.tr('owes'),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textTertiary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${positive ? '+' : ''}${currencySymbol(currency)} ${e.value.toStringAsFixed(2)}',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: positive ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                );
              });
            }),
          ],

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: AppColors.divider),
          ),

          // Quién debe a quién
          if (debts.isNotEmpty) ...[
            Text(
              context.tr('settlements').toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary(context),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            ...debts.entries.expand((currencyEntry) {
              final currency = currencyEntry.key;

              return currencyEntry.value.map((debt) {
                final fromAsync = ref.watch(userNameProvider(debt['from']));
                final toAsync = ref.watch(userNameProvider(debt['to']));

                final fromName = fromAsync.maybeWhen(
                  data: (n) => n,
                  orElse: () => '...',
                );
                final toName = toAsync.maybeWhen(
                  data: (n) => n,
                  orElse: () => '...',
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            fromName.isNotEmpty
                                ? fromName[0].toUpperCase()
                                : '?',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppColors.textTertiary(context),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            toName.isNotEmpty ? toName[0].toUpperCase() : '?',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodySmall,
                            children: [
                              TextSpan(
                                text: fromName,
                                style: TextStyle(
                                  color: AppColors.textPrimary(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: ' ${context.tr('owes')} ',
                                style: TextStyle(
                                  color: AppColors.textTertiary(context),
                                ),
                              ),
                              TextSpan(
                                text: toName,
                                style: TextStyle(
                                  color: AppColors.textPrimary(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        '${currencySymbol(currency)} ${(debt['amount'] as double).toStringAsFixed(2)}',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                );
              });
            }),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: AppColors.divider),
            ),
          ],

          // Si todo está saldado
          if (debts.isEmpty && widget.balances.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('all_settled'),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ================= DATE GROUP =================

class _ExpenseDateGroup extends StatelessWidget {
  final String date;
  final List<ExpenseEntity> expenses;
  final Function(String) onDelete;
  final bool canManageAll;
  final String? userId;
  final bool isReadOnly;
  final Function(ExpenseEntity) onEdit;

  const _ExpenseDateGroup({
    required this.date,
    required this.expenses,
    required this.canManageAll,
    required this.userId,
    required this.isReadOnly,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            date,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary(context),
              letterSpacing: 1.2,
              fontSize: 11,
            ),
          ),
        ),
        ...expenses.map((e) => _ExpenseRow(
              expense: e,
              canManage: !isReadOnly && (canManageAll || e.paidBy == userId),
              onDelete: () => onDelete(e.id),
              onEdit: () => onEdit(e),
            )),
      ],
    );
  }
}

// ================= ROW =================

class _ExpenseRow extends ConsumerWidget {
  final ExpenseEntity expense;
  final VoidCallback onDelete;
  final bool canManage;
  final VoidCallback onEdit;

  const _ExpenseRow({
    required this.expense,
    required this.canManage,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameAsync = ref.watch(userNameProvider(expense.paidBy));
    final paidByName = nameAsync.maybeWhen(
      data: (n) => n,
      orElse: () => '...',
    );

    final symbol = currencySymbol(expense.currency);

    return Dismissible(
      key: Key(expense.id),
      direction:
          canManage ? DismissDirection.endToStart : DismissDirection.none,
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface(context),
            title: Text(context.tr('delete_expense'), style: AppTextStyles.h4),
            content: Text(expense.title,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary(context))),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.tr('cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.tr('delete'),
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error.withValues(alpha: 0.15),
        child: Icon(Icons.delete_outline, color: AppColors.error),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji categoría
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  expense.category.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.title, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 3),
                  Text(
                    context.tr(
                      'paid_by_with_count',
                      params: {
                        'name': paidByName,
                        'count': expense.participants.length.toString(),
                      },
                    ),
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textTertiary(context)),
                  ),
                ],
              ),
            ),

            if (canManage)
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

            const SizedBox(width: 12),

// Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$symbol ${expense.amount.toStringAsFixed(2)}',
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 3),
                Text(
                  '$symbol ${expense.splitAmount.toStringAsFixed(2)}/p',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textTertiary(context)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// ================= EMPTY =================

class _EmptyExpenses extends StatelessWidget {
  final VoidCallback? onAdd;

  const _EmptyExpenses({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💸', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(context.tr('no_expenses_yet'), style: AppTextStyles.h4),
            const SizedBox(height: 8),
            Text(
              context.tr('expenses_description'),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            if (onAdd != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: Text(context.tr('add_expense')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Add Expense Bottom Sheet
class AddExpenseBottomSheet extends ConsumerStatefulWidget {
  final String tripId;
  final String userId;
  final List<String> members;
  final ExpenseEntity? expenseToEdit;

  const AddExpenseBottomSheet({
    super.key,
    required this.tripId,
    required this.userId,
    required this.members,
    this.expenseToEdit,
  });

  @override
  ConsumerState<AddExpenseBottomSheet> createState() =>
      _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends ConsumerState<AddExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  ExpenseCategory _category = ExpenseCategory.food;
  String _currency = 'EUR';
  late List<String> _selectedParticipants;

  // Currencies con símbolo
  final _currencies = {
    'EUR': '€',
    'USD': '\$',
    'GBP': '£',
    'CNY': '¥',
  };

  @override
  void initState() {
    super.initState();

    final expense = widget.expenseToEdit;

    if (expense != null) {
      _titleController.text = expense.title;
      _amountController.text = expense.amount.toStringAsFixed(2);
      _category = expense.category;
      _currency = expense.currency;
      _selectedParticipants = List.from(expense.participants);
    } else {
      _selectedParticipants = List.from(widget.members);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _toggleParticipant(String userId) {
    setState(() {
      if (_selectedParticipants.contains(userId)) {
        // No permitir deseleccionar si solo queda uno
        if (_selectedParticipants.length > 1) {
          _selectedParticipants.remove(userId);
        }
      } else {
        _selectedParticipants.add(userId);
      }
    });
  }

  double get _splitAmount {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (_selectedParticipants.isEmpty) return 0;
    return amount / _selectedParticipants.length;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final expense = widget.expenseToEdit;
    final controller = ref.read(expenseControllerProvider.notifier);

    final success = expense == null
        ? await controller.createExpense(
            tripId: widget.tripId,
            title: _titleController.text.trim(),
            amount: double.parse(_amountController.text),
            currency: _currency,
            paidBy: widget.userId,
            participants: _selectedParticipants,
            category: _category,
          )
        : await controller.updateExpense(
            expenseId: expense.id,
            title: _titleController.text.trim(),
            amount: double.parse(_amountController.text),
            currency: _currency,
            participants: _selectedParticipants,
            category: _category,
          );

    if (!mounted) return;
    if (success) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expenseControllerProvider);
    final symbol = _currencies[_currency] ?? _currency;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr(
                        widget.expenseToEdit == null
                            ? 'add_expense'
                            : 'edit_expense',
                      ),
                      style: AppTextStyles.h3,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Category
              Text(
                context.tr('category').toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary(context),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ExpenseCategory.values.map((cat) {
                  final isSelected = _category == cat;
                  return InkWell(
                    onTap: () => setState(() => _category = cat),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.card(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat.emoji),
                          const SizedBox(width: 6),
                          Text(
                            cat.value,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: context.tr('title'),
                  hintText: context.tr('title_required'),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? context.tr('title_required')
                    : null,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 16),

              // Currency selector
              Text(
                context.tr('currency').toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary(context),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: _currencies.entries.map((entry) {
                  final isSelected = _currency == entry.key;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _currency = entry.key),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : AppColors.card(context),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                entry.value,
                                style: AppTextStyles.h4.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary(context),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.key,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textTertiary(context),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: context.tr('amount'),
                  hintText: context.tr('amount_hint'),
                  prefixText: '$symbol  ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}), // Actualizar split preview
                validator: (v) {
                  if (v == null || v.isEmpty) return context.tr('required');
                  if (double.tryParse(v) == null)
                    return context.tr('invalid_amount');
                  if (double.parse(v) <= 0)
                    return context.tr('amount_greater_than_zero');
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Participants
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr('split_with').toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary(context),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Text(
                    '${_selectedParticipants.length} of ${widget.members.length}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Members list
              ...widget.members.map((memberId) {
                final nameAsync = ref.watch(userNameProvider(memberId));
                final name = nameAsync.maybeWhen(
                  data: (n) => n,
                  orElse: () => '...',
                );
                final isSelected = _selectedParticipants.contains(memberId);
                final isCurrentUser = memberId == widget.userId;

                return InkWell(
                  onTap: () => _toggleParticipant(memberId),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : AppColors.card(context),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary(context),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Name
                        Expanded(
                          child: Text(
                            isCurrentUser
                                ? context.tr(
                                    'you_label',
                                    params: {'name': name},
                                  )
                                : name,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),

                        // Split amount preview
                        if (isSelected && _splitAmount > 0)
                          Text(
                            '$symbol ${_splitAmount.toStringAsFixed(2)}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textTertiary(context),
                            ),
                          ),

                        const SizedBox(width: 12),

                        // Checkbox
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textTertiary(context)
                                      .withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 13,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Split preview total
              if (_splitAmount > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 18,
                        color: AppColors.textSecondary(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.tr(
                          'each_person_pays',
                          params: {
                            'amount': _splitAmount.toStringAsFixed(2),
                            'currency': symbol,
                          },
                        ),
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Submit
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _submit,
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          context.tr(widget.expenseToEdit == null
                              ? 'add_expense'
                              : 'edit_expense'),
                          style: AppTextStyles.h3,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
