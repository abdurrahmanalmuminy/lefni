import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lefni/services/firestore/expense_service.dart';
import 'package:lefni/ui/widgets/forms/create_expense_form.dart';

class ExpenseEditPage extends StatefulWidget {
  final String expenseId;

  const ExpenseEditPage({
    super.key,
    required this.expenseId,
  });

  @override
  State<ExpenseEditPage> createState() => _ExpenseEditPageState();
}

class _ExpenseEditPageState extends State<ExpenseEditPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showEditDialog();
    });
  }

  Future<void> _showEditDialog() async {
    final expense = await ExpenseService().getExpense(widget.expenseId);
    if (!mounted) return;
    
    if (expense == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('المصروف غير موجود')),
        );
        context.pop();
      }
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CreateExpenseForm(model: expense),
      ).then((_) {
        if (mounted) {
          context.pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

