import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lefni/services/firestore/user_service.dart';

class UserEditPage extends StatefulWidget {
  final String userId;

  const UserEditPage({
    super.key,
    required this.userId,
  });

  @override
  State<UserEditPage> createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMessage();
    });
  }

  Future<void> _showMessage() async {
    final user = await UserService().getUser(widget.userId);
    if (!mounted) return;
    
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('المستخدم غير موجود')),
        );
        context.pop();
      }
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تعديل المستخدم'),
          content: const Text('تعديل المستخدمين غير متاح حالياً. يرجى استخدام صفحة الملف الشخصي.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
              child: const Text('موافق'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

