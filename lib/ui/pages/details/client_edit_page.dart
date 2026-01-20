import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lefni/services/firestore/client_service.dart';
import 'package:lefni/ui/widgets/forms/create_client_form.dart';

class ClientEditPage extends StatefulWidget {
  final String clientId;

  const ClientEditPage({
    super.key,
    required this.clientId,
  });

  @override
  State<ClientEditPage> createState() => _ClientEditPageState();
}

class _ClientEditPageState extends State<ClientEditPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showEditDialog();
    });
  }

  Future<void> _showEditDialog() async {
    final client = await ClientService().getClient(widget.clientId);
    if (!mounted) return;
    
    if (client == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('العميل غير موجود')),
        );
        context.pop();
      }
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CreateClientForm(model: client),
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

