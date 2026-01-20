import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lefni/models/expense_model.dart';
import 'package:lefni/services/firestore/expense_service.dart';
import 'package:lefni/services/storage/file_service.dart';
import 'package:lefni/ui/widgets/form_dialog.dart';

class CreateExpenseForm extends StatefulWidget {
  final ExpenseModel? model;
  
  const CreateExpenseForm({super.key, this.model});

  @override
  State<CreateExpenseForm> createState() => _CreateExpenseFormState();
}

class _CreateExpenseFormState extends State<CreateExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _expenseService = ExpenseService();
  final _fileService = FileService();
  
  DateTime _selectedDate = DateTime.now();
  File? _receiptFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      final expense = widget.model!;
      _categoryController.text = expense.category;
      _amountController.text = expense.amount.toString();
      _descriptionController.text = expense.description ?? '';
      _selectedDate = expense.date;
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickReceiptFile() async {
    try {
      final result = await file_picker.FilePicker.platform.pickFiles(
        type: file_picker.FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _receiptFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      String? receiptImageUrl = widget.model?.receiptImageUrl;

      // Upload receipt file if provided
      if (_receiptFile != null) {
        final fileName = _receiptFile!.path.split('/').last;
        final expenseId = widget.model?.id ?? 'temp';
        receiptImageUrl = await _fileService.uploadReceiptImage(
          file: _receiptFile!,
          expenseId: expenseId,
          fileName: fileName,
        );
      }

      if (widget.model != null) {
        // Update existing expense
        final expense = ExpenseModel(
          id: widget.model!.id,
          category: _categoryController.text.trim(),
          amount: double.parse(_amountController.text.trim()),
          date: _selectedDate,
          receiptImageUrl: receiptImageUrl,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          createdBy: widget.model!.createdBy,
          createdAt: widget.model!.createdAt,
        );
        await _expenseService.updateExpense(expense);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث المصروف بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Create new expense
        final expense = ExpenseModel(
          id: '',
          category: _categoryController.text.trim(),
          amount: double.parse(_amountController.text.trim()),
          date: _selectedDate,
          receiptImageUrl: receiptImageUrl,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          createdBy: currentUser.uid,
          createdAt: DateTime.now(),
        );
        await _expenseService.createExpense(expense);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء المصروف بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: widget.model != null ? 'تعديل المصروف' : 'إضافة مصروف',
      isLoading: _isLoading,
      onSubmit: _submit,
      onCancel: () => Navigator.of(context).pop(),
      submitLabel: widget.model != null ? 'تحديث' : null,
      formContent: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'الفئة',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الفئة مطلوبة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'المبلغ',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'المبلغ مطلوب';
                  }
                  if (double.tryParse(value) == null) {
                    return 'يرجى إدخال رقم صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'التاريخ',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'الوصف (اختياري)',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Receipt
              InkWell(
                onTap: _pickReceiptFile,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _receiptFile != null
                              ? _receiptFile!.path.split('/').last
                              : widget.model?.receiptImageUrl != null
                                  ? 'إيصال موجود'
                                  : 'اختر إيصال (اختياري)',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

