import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_finance_tracker/core/constants/app_strings.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';

class AddTransactionPage extends StatefulWidget {
  final TransactionEntity? initial; // null => add, non-null => edit

  const AddTransactionPage({super.key, this.initial});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  TransactionCategory _category = TransactionCategory.general;
  DateTime _date = DateTime.now();

  bool _saving = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();

    final init = widget.initial;
    if (init != null) {
      _amountCtrl.text = init.amount.toStringAsFixed(2);
      _notesCtrl.text = init.notes ?? '';
      _type = init.type;
      _category = init.category;
      _date = init.date;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  double? _parseAmount(String raw) {
    final cleaned = raw.trim().replaceAll(',', '');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  Future<void> _submit() async {
    if (_saving) return;

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final amount = _parseAmount(_amountCtrl.text)!;

    setState(() => _saving = true);

    final tx = TransactionEntity(
      id: widget.initial?.id ?? const Uuid().v4(),
      type: _type,
      amount: amount,
      category: _category,
      date: _date,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    if (_isEdit) {
      context.read<TransactionBloc>().add(UpdateTransactionRequested(tx));
    } else {
      context.read<TransactionBloc>().add(AddTransactionRequested(tx));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (!_saving) return;

        if (state.status == TransactionStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEdit ? AppStrings.updatedTransaction : AppStrings.savedTransaction,
              ),
            ),
          );
          Navigator.of(context).pop();
        }

        if (state.status == TransactionStatus.failure) {
          setState(() => _saving = false);
          final msg = state.errorMessage ?? AppStrings.errorSaving;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? AppStrings.editTransaction : AppStrings.addTransaction),
          actions: [
            if (_saving)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: AbsorbPointer(
                absorbing: _saving,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: AppStrings.amount,
                        hintText: AppStrings.amountHint,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final amt = _parseAmount(value ?? '');
                        if (amt == null) return AppStrings.amountRequired;
                        if (amt <= 0) return AppStrings.amountGreaterThanZero;
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: AppStrings.type,
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: RadioListTile<TransactionType>(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(AppStrings.expense),
                              value: TransactionType.expense,
                              groupValue: _type,
                              onChanged: (v) => setState(() => _type = v!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<TransactionType>(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(AppStrings.income),
                              value: TransactionType.income,
                              groupValue: _type,
                              onChanged: (v) => setState(() => _type = v!),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<TransactionCategory>(
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: AppStrings.category,
                        border: OutlineInputBorder(),
                      ),
                      items: TransactionCategory.values
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                    const SizedBox(height: 12),

                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: AppStrings.date,
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(Formatters.date(_date))),
                            const Text(AppStrings.pick),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: AppStrings.notes,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: _saving ? null : _submit,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(
                        _saving
                            ? AppStrings.saving
                            : (_isEdit
                                  ? AppStrings.updatedTransaction
                                  : AppStrings.addTransaction),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
