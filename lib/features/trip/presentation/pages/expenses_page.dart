import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/expense_entity.dart';
import '../providers/expenses_provider.dart';
import '../providers/trip_provider.dart';
import '../providers/users_provider.dart';

class ExpensesPage extends ConsumerWidget {
  final String tripId;

  const ExpensesPage({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(tripExpensesProvider(tripId));

    return expensesAsync.when(
      data: (expenses) => _ExpensesContent(
        tripId: tripId,
        expenses: expenses,
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ExpensesContent extends ConsumerWidget {
  final String tripId;
  final List<ExpenseEntity> expenses;

  const _ExpensesContent({
    required this.tripId,
    required this.expenses,
  });

  Map<String, double> _calculateBalances() {
    final balances = <String, double>{};

    for (final expense in expenses) {
      if (expense.participants.isEmpty) continue;

      final splitAmount = expense.amount / expense.participants.length;

      balances[expense.paidBy] =
          (balances[expense.paidBy] ?? 0) + expense.amount;

      for (final participant in expense.participants) {
        balances[participant] =
            (balances[participant] ?? 0) - splitAmount;
      }
    }

    return balances;
  }

  Map<String, List<ExpenseEntity>> _groupByDate() {
    final grouped = <String, List<ExpenseEntity>>{};

    for (final expense in expenses) {
      final dateKey = DateFormat('MMM dd')
          .format(expense.createdAt)
          .toUpperCase();

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
      backgroundColor: AppColors.surfaceDark,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final balances = _calculateBalances();
    final grouped = _groupByDate();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,

      body: expenses.isEmpty
          ? _EmptyExpenses(
        onAdd: () => _showAddExpenseSheet(context, ref),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummarySection(
              total: total,
              balances: balances,
            ),

            const SizedBox(height: 8),

            ...grouped.entries.map((entry) {
              return _ExpenseDateGroup(
                date: entry.key,
                expenses: entry.value,
                onDelete: (id) => ref
                    .read(expenseControllerProvider.notifier)
                    .deleteExpense(id),
              );
            }),

            const SizedBox(height: 100),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseSheet(context, ref),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ================= SUMMARY =================

class _SummarySection extends ConsumerWidget {
  final double total;
  final Map<String, double> balances;

  const _SummarySection({
    required this.total,
    required this.balances,
  });

  /// Calcula quién debe a quién y cuánto
  List<Map<String, dynamic>> _calculateDebts() {
    // Separar deudores (negativo) y acreedores (positivo)
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

    // Algoritmo greedy para minimizar transacciones
    final debtorList = debtors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final creditorList = creditors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    int i = 0, j = 0;

    while (i < debtorList.length && j < creditorList.length) {
      final debtor = debtorList[i];
      final creditor = creditorList[j];

      final amount = debtor.value < creditor.value
          ? debtor.value
          : creditor.value;

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

    return debts;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = _calculateDebts();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total
          Text(
            'Total spent',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '€${total.toStringAsFixed(2)}',
            style: AppTextStyles.h1.copyWith(
              fontSize: 36,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 20),

          // Balances por persona
          if (balances.isNotEmpty) ...[
            Text(
              'BALANCES',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            ...balances.entries.map((e) {
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
                        color: AppColors.cardDark,
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
                            positive ? 'gets back' : 'owes',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${positive ? '+' : ''}€${e.value.toStringAsFixed(2)}',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: positive ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              );
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
              'SETTLEMENTS',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            ...debts.map((debt) {
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
                    // Avatar from
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.15),
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

                    // Arrow
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),

                    const SizedBox(width: 8),

                    // Avatar to
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          toName.isNotEmpty
                              ? toName[0].toUpperCase()
                              : '?',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Texto
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodySmall,
                          children: [
                            TextSpan(
                              text: fromName,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: ' owes ',
                              style: TextStyle(color: AppColors.textTertiary),
                            ),
                            TextSpan(
                              text: toName,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Cantidad
                    Text(
                      '€${(debt['amount'] as double).toStringAsFixed(2)}',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: AppColors.divider),
            ),
          ],

          // Si todo está saldado
          if (debts.isEmpty && balances.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
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
                    'All settled up! 🎉',
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

  const _ExpenseDateGroup({
    required this.date,
    required this.expenses,
    required this.onDelete,
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
              color: AppColors.textTertiary,
              letterSpacing: 1.2,
              fontSize: 11,
            ),
          ),
        ),
        ...expenses.map((e) => _ExpenseRow(
          expense: e,
          onDelete: () => onDelete(e.id),
        )),
      ],
    );
  }
}

// ================= ROW =================

class _ExpenseRow extends ConsumerWidget {
  final ExpenseEntity expense;
  final VoidCallback onDelete;

  const _ExpenseRow({
    required this.expense,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameAsync = ref.watch(userNameProvider(expense.paidBy));
    final paidByName = nameAsync.maybeWhen(
      data: (n) => n,
      orElse: () => '...',
    );

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            title: Text('Delete expense?', style: AppTextStyles.h4),
            content: Text(expense.title,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete',
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
        color: AppColors.error.withOpacity(0.15),
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
                color: AppColors.cardDark,
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
                    'Paid by $paidByName · ${expense.participants.length} ${expense.participants.length == 1 ? 'person' : 'people'}',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${expense.currency} ${expense.amount.toStringAsFixed(2)}',
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 3),
                Text(
                  '${expense.currency} ${expense.splitAmount.toStringAsFixed(2)}/p',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textTertiary),
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
  final VoidCallback onAdd;

  const _EmptyExpenses({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onAdd,
        child: const Text('Add Expense'),
      ),
    );
  }
}

// Add Expense Bottom Sheet
class AddExpenseBottomSheet extends ConsumerStatefulWidget {
  final String tripId;
  final String userId;
  final List<String> members;

  const AddExpenseBottomSheet({
    super.key,
    required this.tripId,
    required this.userId,
    required this.members,
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
    // Por defecto todos los miembros participan
    _selectedParticipants = List.from(widget.members);
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

    final success = await ref
        .read(expenseControllerProvider.notifier)
        .createExpense(
      tripId: widget.tripId,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      currency: _currency,
      paidBy: widget.userId,
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
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Header
              Row(
                children: [
                  Expanded(
                    child: Text('Add Expense', style: AppTextStyles.h3),
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
                'CATEGORY',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
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
                            ? AppColors.primary.withOpacity(0.15)
                            : AppColors.cardDark,
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
                                  : AppColors.textSecondary,
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
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g., Dinner at restaurant',
                ),
                validator: (v) =>
                v == null || v.isEmpty ? 'Title is required' : null,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 16),

              // Currency selector
              Text(
                'CURRENCY',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
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
                                ? AppColors.primary.withOpacity(0.15)
                                : AppColors.cardDark,
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
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.key,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textTertiary,
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
                  labelText: 'Amount',
                  hintText: '0.00',
                  prefixText: '$symbol  ',
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}), // Actualizar split preview
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid amount';
                  if (double.parse(v) <= 0) return 'Must be greater than 0';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Participants
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'SPLIT WITH',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Text(
                    '${_selectedParticipants.length} of ${widget.members.length}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
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
                                ? AppColors.primary.withOpacity(0.15)
                                : AppColors.cardDark,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Name
                        Expanded(
                          child: Text(
                            isCurrentUser ? '$name (you)' : name,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),

                        // Split amount preview
                        if (isSelected && _splitAmount > 0)
                          Text(
                            '$symbol ${_splitAmount.toStringAsFixed(2)}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textTertiary,
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
                                  : AppColors.textTertiary.withOpacity(0.4),
                              width: 1.5,
                            ),
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.2)
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
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Each person pays $symbol ${_splitAmount.toStringAsFixed(2)}',
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
                      : const Text('Add Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}