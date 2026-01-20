import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/collection_record_model.dart';
import 'package:lefni/models/finance_model.dart';
import 'package:lefni/models/payment_method_model.dart';
import 'package:lefni/services/firestore/collection_record_service.dart';
import 'package:lefni/services/firestore/finance_service.dart';
import 'package:lefni/services/storage/file_service.dart';
import 'package:lefni/ui/widgets/form_dialog.dart';
import 'package:intl/intl.dart';

class CreateCollectionRecordForm extends StatefulWidget {
  final CollectionRecordModel? model;
  
  const CreateCollectionRecordForm({super.key, this.model});

  @override
  State<CreateCollectionRecordForm> createState() => _CreateCollectionRecordFormState();
}

class _CreateCollectionRecordFormState extends State<CreateCollectionRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _collectionRecordService = CollectionRecordService();
  final _financeService = FinanceService();
  final _fileService = FileService();
  
  String? _selectedInvoiceId;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  DateTime _selectedDate = DateTime.now();
  File? _receiptFile;
  List<FinanceModel> _availableInvoices = [];
  bool _isLoading = false;
  bool _isLoadingInvoices = true;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
    if (widget.model != null) {
      final record = widget.model!;
      _selectedInvoiceId = record.invoiceId;
      _amountController.text = record.amount.toString();
      _selectedPaymentMethod = PaymentMethod.fromString(record.paymentMethod);
      _selectedDate = record.paymentDate;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadInvoices() async {
    try {
      // Load unpaid invoices
      final snapshot = await _financeService.getFinancesByStatus(
        FinanceStatus.unpaid,
      ).first;
      setState(() {
        _availableInvoices = snapshot;
        _isLoadingInvoices = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingInvoices = false;
      });
    }
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

    if (_selectedInvoiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار الفاتورة')),
      );
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

      String? receiptUrl = widget.model?.receiptUrl;

      // Upload receipt file if provided
      if (_receiptFile != null) {
        final fileName = _receiptFile!.path.split('/').last;
        // Use receipt upload method - store in receipts folder with record ID
        final recordId = widget.model?.id ?? 'temp';
        receiptUrl = await _fileService.uploadReceiptImage(
          file: _receiptFile!,
          expenseId: recordId, // Reusing the method with record ID
          fileName: fileName,
        );
      }

      if (widget.model != null) {
        // Update existing record
        final record = CollectionRecordModel(
          id: widget.model!.id,
          invoiceId: _selectedInvoiceId!,
          amount: double.parse(_amountController.text.trim()),
          paymentDate: _selectedDate,
          paymentMethod: _selectedPaymentMethod.value,
          receiptUrl: receiptUrl,
          recordedBy: widget.model!.recordedBy,
          createdAt: widget.model!.createdAt,
        );
        await _collectionRecordService.updateRecord(record);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث سجل التحصيل بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Create new record
        final record = CollectionRecordModel(
          id: '',
          invoiceId: _selectedInvoiceId!,
          amount: double.parse(_amountController.text.trim()),
          paymentDate: _selectedDate,
          paymentMethod: _selectedPaymentMethod.value,
          receiptUrl: receiptUrl,
          recordedBy: currentUser.uid,
          createdAt: DateTime.now(),
        );
        await _collectionRecordService.createRecord(record);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء سجل التحصيل بنجاح'),
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
      title: widget.model != null ? 'تعديل سجل التحصيل' : 'إضافة سجل تحصيل',
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
              // Invoice selection
              if (_isLoadingInvoices)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<String>(
                  value: _selectedInvoiceId,
                  decoration: const InputDecoration(
                    labelText: 'الفاتورة',
                    prefixIcon: Icon(Icons.receipt),
                  ),
                  items: _availableInvoices.map((invoice) {
                    return DropdownMenuItem<String>(
                      value: invoice.id,
                      child: Text(
                        '${invoice.total.toStringAsFixed(2)} ر.س - ${DateFormat('yyyy-MM-dd').format(invoice.createdAt)}',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedInvoiceId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'يرجى اختيار الفاتورة';
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
              // Payment Date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'تاريخ الدفع',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Payment Method
              DropdownButtonFormField<PaymentMethod>(
                value: _selectedPaymentMethod,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.paymentMethod,
                  prefixIcon: const Icon(Icons.payment),
                ),
                items: PaymentMethod.values.map((method) {
                  return DropdownMenuItem<PaymentMethod>(
                    value: method,
                    child: Text(method.localized(AppLocalizations.of(context)!)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return AppLocalizations.of(context)!.paymentMethodRequired;
                  }
                  return null;
                },
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
                              : widget.model?.receiptUrl != null
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

