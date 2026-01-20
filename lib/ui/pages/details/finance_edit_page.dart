import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lefni/services/firestore/finance_service.dart';
import 'package:lefni/ui/widgets/forms/create_finance_form.dart';

class FinanceEditPage extends StatefulWidget {
  final String financeId;

  const FinanceEditPage({
    super.key,
    required this.financeId,
  });

  @override
  State<FinanceEditPage> createState() => _FinanceEditPageState();
}

class _FinanceEditPageState extends State<FinanceEditPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showEditDialog();
    });
  }

  Future<void> _showEditDialog() async {
    final finance = await FinanceService().getFinance(widget.financeId);
    if (!mounted) return;
    
    if (finance == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('السجل المالي غير موجود')),
        );
        context.pop();
      }
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CreateFinanceForm(model: finance),
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

