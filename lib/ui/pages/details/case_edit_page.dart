import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lefni/services/firestore/case_service.dart';
import 'package:lefni/ui/widgets/forms/create_case_form.dart';

class CaseEditPage extends StatefulWidget {
  final String caseId;

  const CaseEditPage({
    super.key,
    required this.caseId,
  });

  @override
  State<CaseEditPage> createState() => _CaseEditPageState();
}

class _CaseEditPageState extends State<CaseEditPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showEditDialog();
    });
  }

  Future<void> _showEditDialog() async {
    final case_ = await CaseService().getCase(widget.caseId);
    if (!mounted) return;
    
    if (case_ == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('القضية غير موجودة')),
        );
        context.pop();
      }
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CreateCaseForm(model: case_),
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

