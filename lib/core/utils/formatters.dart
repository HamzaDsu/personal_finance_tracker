import 'package:intl/intl.dart';

class Formatters {
  static String money(double value) => NumberFormat.currency(symbol: '\$').format(value);
  static String date(DateTime dt) => DateFormat.yMMMd().format(dt);
}
