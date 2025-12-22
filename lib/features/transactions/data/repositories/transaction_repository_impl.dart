import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource local;

  const TransactionRepositoryImpl({required this.local});

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    try {
      final models = await local.getAll();
      return models.map((m) => m.toEntity()).toList();
    } on StorageException catch (e) {
      throw StorageFailure(e.message);
    } catch (_) {
      throw const UnknownFailure();
    }
  }

  @override
  Future<void> addTransaction(TransactionEntity transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await local.upsert(model);
    } on StorageException catch (e) {
      throw StorageFailure(e.message);
    } catch (_) {
      throw const UnknownFailure();
    }
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await local.upsert(model);
    } on StorageException catch (e) {
      throw StorageFailure(e.message);
    } catch (_) {
      throw const UnknownFailure();
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await local.deleteById(id);
    } on StorageException catch (e) {
      throw StorageFailure(e.message);
    } catch (_) {
      throw const UnknownFailure();
    }
  }
}
