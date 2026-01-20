import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/models/task_model.dart';
import 'package:lefni/models/user_model.dart';
import 'package:lefni/models/case_model.dart';
import 'package:lefni/models/client_model.dart';
import 'package:lefni/models/contract_model.dart';
import 'package:lefni/services/firestore/task_service.dart';
import 'package:lefni/services/firestore/user_service.dart';
import 'package:lefni/services/firestore/case_service.dart';
import 'package:lefni/services/firestore/client_service.dart';
import 'package:lefni/services/firestore/contract_service.dart';
import 'package:lefni/providers/user_session_provider.dart';
import 'package:lefni/ui/widgets/form_dialog.dart';
import 'package:intl/intl.dart';

class CreateTaskForm extends StatefulWidget {
  final TaskModel? model;
  
  const CreateTaskForm({super.key, this.model});

  @override
  State<CreateTaskForm> createState() => _CreateTaskFormState();
}

class _CreateTaskFormState extends State<CreateTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();
  final _taskService = TaskService();
  final _userService = UserService();
  final _caseService = CaseService();
  final _clientService = ClientService();
  final _contractService = ContractService();
  
  String? _selectedAssignedTo;
  RelatedType _selectedRelatedType = RelatedType.case_;
  String? _selectedRelatedId;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _startDate;
  DateTime? _dueDate;
  List<String> _tags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      final task = widget.model!;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedAssignedTo = task.assignedTo;
      _selectedRelatedType = task.relatedType;
      _selectedRelatedId = task.relatedId;
      _selectedPriority = task.priority;
      _startDate = task.deadlines.start;
      _dueDate = task.deadlines.end;
      _tags = List.from(task.tags);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? (_startDate ?? DateTime.now()),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _addTag() {
    if (_tagController.text.trim().isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _submit() async {
    final localizations = AppLocalizations.of(context)!;
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAssignedTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.pleaseSelectAssignee)),
      );
      return;
    }

    if (_selectedRelatedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.pleaseSelectRelatedItem)),
      );
      return;
    }

    if (_startDate == null || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.pleaseSelectDates)),
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

      if (widget.model != null) {
        // Update existing task
        final task = TaskModel(
          id: widget.model!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          assignedTo: _selectedAssignedTo!,
          relatedId: _selectedRelatedId!,
          relatedType: _selectedRelatedType,
          deadlines: TaskDeadlines(
            start: _startDate!,
            end: _dueDate!,
          ),
          status: widget.model!.status,
          priority: _selectedPriority,
          tags: _tags,
          completionReport: widget.model!.completionReport,
          completedAt: widget.model!.completedAt,
          createdAt: widget.model!.createdAt,
          createdBy: widget.model!.createdBy,
        );
        await _taskService.updateTask(task);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث المهمة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Create new task
      final task = TaskModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        assignedTo: _selectedAssignedTo!,
        relatedId: _selectedRelatedId!,
        relatedType: _selectedRelatedType,
        deadlines: TaskDeadlines(
          start: _startDate!,
          end: _dueDate!,
        ),
        status: TaskStatus.pending,
        priority: _selectedPriority,
        tags: _tags,
        createdAt: DateTime.now(),
        createdBy: currentUser.uid,
      );

      await _taskService.createTask(task);

      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.taskCreatedSuccessfully),
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

  Widget _buildRelatedIdDropdown() {
    switch (_selectedRelatedType) {
      case RelatedType.case_:
        return StreamBuilder<List<CaseModel>>(
          stream: _caseService.getCasesByStatus(CaseStatus.active),
          builder: (context, snapshot) {
            final cases = snapshot.data ?? [];
            final localizations = AppLocalizations.of(context)!;
            return DropdownButtonFormField<String>(
              value: _selectedRelatedId,
              decoration: FormFieldStyle.styled(
                labelText: localizations.caseLabel,
                prefixIcon: Icons.folder_outlined,
              ),
              items: cases.map((case_) {
                return DropdownMenuItem<String>(
                  value: case_.id,
                  child: Text(case_.caseNumber),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRelatedId = value;
                });
              },
            );
          },
        );
      case RelatedType.client:
        return StreamBuilder<List<ClientModel>>(
          stream: _clientService.getAllClients(),
          builder: (context, snapshot) {
            final clients = snapshot.data ?? [];
            final localizations = AppLocalizations.of(context)!;
            return DropdownButtonFormField<String>(
              value: _selectedRelatedId,
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
                  _selectedRelatedId = value;
                });
              },
            );
          },
        );
      case RelatedType.contract:
        return StreamBuilder<List<ContractModel>>(
          stream: _contractService.getAllContracts(),
          builder: (context, snapshot) {
            final contracts = snapshot.data ?? [];
            final localizations = AppLocalizations.of(context)!;
            return DropdownButtonFormField<String>(
              value: _selectedRelatedId,
              decoration: FormFieldStyle.styled(
                labelText: localizations.contractLabel,
                prefixIcon: Icons.description_outlined,
              ),
              items: contracts.map((contract) {
                return DropdownMenuItem<String>(
                  value: contract.id,
                  child: Text(contract.title),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRelatedId = value;
                });
              },
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return FormDialog(
      title: widget.model != null ? 'تعديل المهمة' : localizations.assignTask,
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
              // Title
              TextFormField(
                controller: _titleController,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.title,
                  prefixIcon: Icons.title_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localizations.titleRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.description,
                  prefixIcon: Icons.description_outlined,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localizations.descriptionRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Assigned To
              StreamBuilder<List<UserModel>>(
                stream: _userService.getAllActiveUsers(),
                builder: (context, snapshot) {
                  final users = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    value: _selectedAssignedTo,
                    decoration: FormFieldStyle.styled(
                      labelText: localizations.assignTo,
                      prefixIcon: Icons.person_outline,
                    ),
                    items: users.map((user) {
                      return DropdownMenuItem<String>(
                        value: user.uid,
                        child: Text(user.profile.name ?? user.email),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAssignedTo = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.assigneeRequired;
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              // Related Type
              DropdownButtonFormField<RelatedType>(
                value: _selectedRelatedType,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.relatedTo,
                  prefixIcon: Icons.link_outlined,
                ),
                items: RelatedType.values.map((type) {
                  return DropdownMenuItem<RelatedType>(
                    value: type,
                    child: Text(type.localized(localizations)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRelatedType = value;
                      _selectedRelatedId = null; // Reset when type changes
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Related ID (dynamic based on type)
              _buildRelatedIdDropdown(),
              const SizedBox(height: 16),
              // Priority
              DropdownButtonFormField<TaskPriority>(
                value: _selectedPriority,
                decoration: FormFieldStyle.styled(
                  labelText: localizations.priority,
                  prefixIcon: Icons.flag_outlined,
                ),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem<TaskPriority>(
                    value: priority,
                    child: Text(priority.localized(localizations)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Start Date
              InkWell(
                onTap: _selectStartDate,
                child: InputDecorator(
                  decoration: FormFieldStyle.styled(
                    labelText: localizations.startDate,
                    prefixIcon: Icons.calendar_today,
                  ),
                  child: Text(
                    _startDate != null
                        ? DateFormat('yyyy-MM-dd').format(_startDate!)
                        : localizations.selectStartDate,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Due Date
              InkWell(
                onTap: _selectDueDate,
                child: InputDecorator(
                  decoration: FormFieldStyle.styled(
                    labelText: localizations.dueDate,
                    prefixIcon: Icons.event_outlined,
                  ),
                  child: Text(
                    _dueDate != null
                        ? DateFormat('yyyy-MM-dd').format(_dueDate!)
                        : localizations.selectDueDate,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Tags
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tagController,
                      decoration: FormFieldStyle.styled(
                        labelText: localizations.addTag,
                        prefixIcon: Icons.label_outline,
                      ),
                      onFieldSubmitted: (_) => _addTag(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addTag,
                  ),
                ],
              ),
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      onDeleted: () => _removeTag(tag),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

