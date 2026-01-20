import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/finance_model.dart';
import 'package:lefni/models/client_model.dart';
import 'package:lefni/models/case_model.dart';
import 'package:lefni/services/firestore/finance_service.dart';
import 'package:lefni/services/firestore/client_service.dart';
import 'package:lefni/services/firestore/case_service.dart';
import 'package:lefni/providers/user_session_provider.dart';
import 'package:lefni/ui/widgets/form_dialog.dart';
import 'package:intl/intl.dart';

class CreateFinanceForm extends StatefulWidget {
  final FinanceModel? model;
  
  const CreateFinanceForm({super.key, this.model});

  @override
  State<CreateFinanceForm> createState() => _CreateFinanceFormState();
}

class _CreateFinanceFormState extends State<CreateFinanceForm> {
  final _formKey = GlobalKey<FormState>();
  final _serviceController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _financeService = FinanceService();
  final _clientService = ClientService();
  final _caseService = CaseService();
  
  String? _selectedClientId;
  String? _selectedCaseId;
  FinanceType _selectedType = FinanceType.invoice;
  FinanceStatus _selectedStatus = FinanceStatus.draft;
  DateTime? _dueDate;
  List<FinanceItem> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      final finance = widget.model!;
      _selectedClientId = finance.clientId;
      _selectedCaseId = finance.caseId;
      _selectedType = finance.type;
      _selectedStatus = finance.status;
      _dueDate = finance.dueDate;
      _items = List.from(finance.items);
      _notesController.text = finance.notes ?? '';
    }
  }

  @override
  void dispose() {
    _serviceController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _addItem() {
    final localizations = AppLocalizations.of(context)!;
    
    if (_serviceController.text.trim().isEmpty || _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.serviceAndPriceRequired)),
      );
      return;
    }

    setState(() {
      _items.add(
        FinanceItem(
          service: _serviceController.text.trim(),
          price: double.tryParse(_priceController.text.trim()) ?? 0.0,
          quantity: _quantityController.text.trim().isEmpty
              ? null
              : int.tryParse(_quantityController.text.trim()),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        ),
      );
      _serviceController.clear();
      _priceController.clear();
      _quantityController.clear();
      _descriptionController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  double _calculateSubtotal() {
    return _items.fold(0.0, (sum, item) {
      return sum + (item.price * (item.quantity ?? 1));
    });
  }

  double _calculateVAT() {
    return _calculateSubtotal() * 0.15; // 15% VAT
  }

  double _calculateTotal() {
    return _calculateSubtotal() + _calculateVAT();
  }

  Future<void> _submit() async {
    final localizations = AppLocalizations.of(context)!;
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.pleaseSelectClient)),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.pleaseAddAtLeastOneItem)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userSession = Provider.of<UserSessionProvider>(context, listen: false);
      final currentUser = userSession.firebaseUser;
      
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final subtotal = _calculateSubtotal();
      final vat = _calculateVAT();
      final total = _calculateTotal();

      if (widget.model != null) {
        // Update existing finance record
        final finance = FinanceModel(
          id: widget.model!.id,
          type: _selectedType,
          clientId: _selectedClientId!,
          caseId: _selectedCaseId,
          items: _items,
          subtotal: subtotal,
          vat: vat,
          total: total,
          currency: widget.model!.currency,
          status: _selectedStatus,
          pdfUrl: widget.model!.pdfUrl,
          dueDate: _dueDate,
          paidAt: widget.model!.paidAt,
          paymentMethod: widget.model!.paymentMethod,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          createdAt: widget.model!.createdAt,
          createdBy: widget.model!.createdBy,
        );
        await _financeService.updateFinance(finance);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث السجل المالي بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Create new finance record
        final finance = FinanceModel(
          id: '',
          type: _selectedType,
          clientId: _selectedClientId!,
          caseId: _selectedCaseId,
          items: _items,
          subtotal: subtotal,
          vat: vat,
          total: total,
          currency: 'SAR',
          status: _selectedStatus,
          dueDate: _dueDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          createdAt: DateTime.now(),
          createdBy: currentUser.uid,
        );

        await _financeService.createFinance(finance);

        if (mounted) {
          final localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.financeRecordCreatedSuccessfully),
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
    final localizations = AppLocalizations.of(context)!;

    return FormDialog(
      title: widget.model != null ? 'تعديل السجل المالي' : localizations.createInvoice,
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
              // Type
              DropdownButtonFormField<FinanceType>(
                value: _selectedType,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.type,
                  prefixIcon: Icons.category_outlined,
                ),
                items: FinanceType.values.map((type) {
                  return DropdownMenuItem<FinanceType>(
                    value: type,
                    child: Text(type.value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Client
              StreamBuilder<List<ClientModel>>(
                stream: _clientService.getAllClients(),
                builder: (context, snapshot) {
                  final clients = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    value: _selectedClientId,
                    decoration: FormFieldStyle.styled(
                      labelText: localizations.clients,
                      prefixIcon: Icons.person_outline,
                    ),
                    items: clients.map((client) {
                      return DropdownMenuItem<String>(
                        value: client.id,
                        child: Text(client.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClientId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.pleaseSelectClient;
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              // Case (optional)
              StreamBuilder<List<CaseModel>>(
                stream: _caseService.getCasesByStatus(CaseStatus.active),
                builder: (context, snapshot) {
                  final cases = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    value: _selectedCaseId,
                    decoration: FormFieldStyle.styled(
                      labelText: localizations.caseOptional,
                      prefixIcon: Icons.folder_outlined,
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(localizations.none),
                      ),
                      ...cases.map((case_) {
                        return DropdownMenuItem<String>(
                          value: case_.id,
                          child: Text(case_.caseNumber),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCaseId = value;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              // Status
              DropdownButtonFormField<FinanceStatus>(
                value: _selectedStatus,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.status,
                  prefixIcon: Icons.info_outline,
                ),
                items: FinanceStatus.values.map((status) {
                  return DropdownMenuItem<FinanceStatus>(
                    value: status,
                    child: Text(status.value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Due Date (optional)
              InkWell(
                onTap: _selectDueDate,
                child: InputDecorator(
                  decoration: FormFieldStyle.styled(
                    labelText: localizations.dueDateOptional,
                    prefixIcon: Icons.calendar_today,
                  ),
                  child: Text(
                    _dueDate != null
                        ? DateFormat('yyyy-MM-dd').format(_dueDate!)
                        : localizations.selectDueDateOptional,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Items section
              Text(
                '${localizations.items}:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Add item fields
              TextFormField(
                controller: _serviceController,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.service,
                  prefixIcon: Icons.work_outline,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: FormFieldStyle.styled(
                        labelText: localizations.price,
                        prefixIcon: Icons.attach_money,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: FormFieldStyle.styled(
                        labelText: localizations.quantityOptional,
                        prefixIcon: Icons.numbers_outlined,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.descriptionOptional,
                  prefixIcon: Icons.description_outlined,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: Text(localizations.addItem),
              ),
              const SizedBox(height: 16),
              // Items list
              if (_items.isNotEmpty) ...[
                ..._items.asMap().entries.map((entry) {
                  return Card(
                    child: ListTile(
                      title: Text(entry.value.service),
                      subtitle: Text(
                        '${entry.value.price} SAR ${entry.value.quantity != null ? 'x ${entry.value.quantity}' : ''}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeItem(entry.key),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                // Totals
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${localizations.subtotal}:'),
                            Text('${_calculateSubtotal().toStringAsFixed(2)} SAR'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${localizations.vat}:'),
                            Text('${_calculateVAT().toStringAsFixed(2)} SAR'),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${localizations.total}:',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${_calculateTotal().toStringAsFixed(2)} SAR',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.notesOptional,
                  prefixIcon: Icons.note_outlined,
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

