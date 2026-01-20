import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lefni/services/firestore/collection_record_service.dart';
import 'package:lefni/ui/widgets/forms/create_collection_record_form.dart';

class CollectionRecordEditPage extends StatefulWidget {
  final String recordId;

  const CollectionRecordEditPage({
    super.key,
    required this.recordId,
  });

  @override
  State<CollectionRecordEditPage> createState() => _CollectionRecordEditPageState();
}

class _CollectionRecordEditPageState extends State<CollectionRecordEditPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showEditDialog();
    });
  }

  Future<void> _showEditDialog() async {
    final record = await CollectionRecordService().getRecord(widget.recordId);
    if (!mounted) return;
    
    if (record == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('سجل التحصيل غير موجود')),
        );
        context.pop();
      }
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CreateCollectionRecordForm(model: record),
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

