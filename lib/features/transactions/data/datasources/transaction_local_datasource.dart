import 'package:hive/hive.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/transaction_model.dart';

class TransactionLocalDataSource {
  static const String _boxName = 'transactions';

  Box<TransactionModel> get _box => Hive.box<TransactionModel>(_boxName);

  Future<List<TransactionModel>> getAll() async {
    try {
      final values = _box.values.toList();
      values.sort((a, b) => b.date.compareTo(a.date)); // newest first
      return values;
    } catch (_) {
      throw const StorageException('Failed to read transactions');
    }
  }

  Future<void> upsert(TransactionModel model) async {
    try {
      await _box.put(model.id, model); // put by id => update or insert
    } catch (_) {
      throw const StorageException('Failed to save transaction');
    }
  }

  Future<void> deleteById(String id) async {
    try {
      await _box.delete(id);
    } catch (_) {
      throw const StorageException('Failed to delete transaction');
    }
  }

  bool exists(String id) {
    try {
      return _box.containsKey(id);
    } catch (_) {
      return false;
    }
  }
}
