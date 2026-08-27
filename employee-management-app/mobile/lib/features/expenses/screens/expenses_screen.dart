import 'package:flutter/material.dart';
import '../../common/module_screen.dart';
import '../providers/expense_provider.dart';
class ExpensesScreen extends StatelessWidget { const ExpensesScreen({super.key}); @override Widget build(BuildContext context) => const ModuleScreen<ExpenseProvider>(title: 'Expense Reimbursement'); }
