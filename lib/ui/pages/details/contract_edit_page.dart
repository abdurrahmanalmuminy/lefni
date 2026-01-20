import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lefni/services/firestore/contract_service.dart';
import 'package:lefni/ui/widgets/forms/create_contract_form.dart';

class ContractEditPage extends StatefulWidget {
  final String contractId;

  const ContractEditPage({
    super.key,
    required this.contractId,
  });

  @override
  State<ContractEditPage> createState() => _ContractEditPageState();
}

class _ContractEditPageState extends State<ContractEditPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showEditDialog();
    });
  }

  Future<void> _showEditDialog() async {
    final contract = await ContractService().getContract(widget.contractId);
    if (!mounted) return;
    
    if (contract == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('العقد غير موجود')),
        );
        context.pop();
      }
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CreateContractForm(model: contract),
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

