import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'features/transactions/data/models/transaction_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TransactionModelAdapter());

  // One box for all transactions
  await Hive.openBox<TransactionModel>('transactions');

  runApp(const FinanceApp());
}
