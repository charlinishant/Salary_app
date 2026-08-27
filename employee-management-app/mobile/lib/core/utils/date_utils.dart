import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);
  static String today() => formatDate(DateTime.now());
}
