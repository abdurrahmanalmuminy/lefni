import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lefni/models/consultation_model.dart';
import 'package:lefni/models/user_model.dart';
import 'package:lefni/services/firestore/consultation_service.dart';
import 'package:lefni/services/firestore/client_service.dart';
import 'package:lefni/services/firestore/user_service.dart';
import 'package:lefni/services/court_classifications_service.dart';
import 'package:lefni/providers/user_session_provider.dart';
import 'package:lefni/ui/widgets/entity_header.dart';
import 'package:lefni/utils/file_viewer.dart';
import 'package:intl/intl.dart';

class ConsultationDetailPage extends StatefulWidget {
  final String consultationId;

  const ConsultationDetailPage({
    super.key,
    required this.consultationId,
  });

  @override
  State<ConsultationDetailPage> createState() => _ConsultationDetailPageState();
}

class _ConsultationDetailPageState extends State<ConsultationDetailPage> {
  final _consultationService = ConsultationService();
  final _userService = UserService();
  final _responseController = TextEditingController();
  String? _selectedLawyerId;
  ConsultationStatus? _selectedStatus;
  bool _isLoading = false;

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _assignLawyer() async {
    if (_selectedLawyerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار محامي')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _consultationService.assignConsultation(widget.consultationId, _selectedLawyerId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تكليف المحامي بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedLawyerId = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
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

  Future<void> _updateStatus() async {
    if (_selectedStatus == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final consultation = await _consultationService.getConsultation(widget.consultationId);
      if (consultation != null) {
        await _consultationService.updateConsultation(
          consultation.copyWith(status: _selectedStatus!),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث الحالة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
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

  Future<void> _submitResponse() async {
    if (_responseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال الرد')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final consultation = await _consultationService.getConsultation(widget.consultationId);
      if (consultation != null) {
        await _consultationService.updateConsultation(
          consultation.copyWith(
            response: _responseController.text.trim(),
            responseAt: DateTime.now(),
            status: ConsultationStatus.completed,
          ),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرسال الرد بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          _responseController.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final userSession = Provider.of<UserSessionProvider>(context, listen: false);
    final isAdmin = userSession.userRole == UserRole.admin;
    final isLawyer = userSession.userRole == UserRole.lawyer;
    final currentUserId = userSession.firebaseUser?.uid;

    return Scaffold(
      body: FutureBuilder<ConsultationModel?>(
        future: _consultationService.getConsultation(widget.consultationId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'حدث خطأ أثناء تحميل البيانات',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ),
            );
          }

          final consultation = snapshot.data;
          if (consultation == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'الاستشارة غير موجودة',
                    style: textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          final canEdit = isAdmin || 
                         (isLawyer && consultation.assignedLawyerId == currentUserId);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: EntityHeader(
                  title: 'استشارة قانونية',
                  subtitle: _getCategoryDisplayName(consultation),
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.chat_bubble_outline,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  actions: [
                    _StatusChip(status: consultation.status),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Basic Information
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'معلومات الاستشارة',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              context,
                              'التصنيف الرئيسي',
                              _getCategoryDisplayName(consultation),
                            ),
                            if (consultation.subCategory != null)
                              FutureBuilder<String>(
                                future: CourtClassificationsService.getSubCategoryNameAr(
                                  consultation.category,
                                  consultation.subCategory!,
                                ),
                                builder: (context, snapshot) {
                                  return _buildInfoRow(
                                    context,
                                    'التصنيف الفرعي',
                                    snapshot.data ?? consultation.subCategory ?? '',
                                  );
                                },
                              ),
                            if (consultation.caseType != null)
                              _buildInfoRow(
                                context,
                                'نوع القضية',
                                consultation.caseType!['ar'] as String? ?? '',
                              ),
                            _buildInfoRow(
                              context,
                              'تاريخ الإنشاء',
                              DateFormat('yyyy-MM-dd HH:mm').format(consultation.createdAt),
                            ),
                            if (consultation.assignedAt != null)
                              _buildInfoRow(
                                context,
                                'تاريخ التكليف',
                                DateFormat('yyyy-MM-dd HH:mm').format(consultation.assignedAt!),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'وصف الاستشارة',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              consultation.description,
                              style: textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Client Information
                    FutureBuilder(
                      future: ClientService().getClient(consultation.clientId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final client = snapshot.data!;
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.person),
                              title: const Text('العميل'),
                              subtitle: Text(client.name),
                              trailing: IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                                onPressed: () => context.go('/clients/${client.id}'),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Assigned Lawyer
                    if (consultation.assignedLawyerId != null)
                      FutureBuilder(
                        future: _userService.getUser(consultation.assignedLawyerId!),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            final lawyer = snapshot.data!;
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.gavel),
                                title: const Text('المحامي المكلف'),
                                subtitle: Text(lawyer.profile.name ?? lawyer.email),
                                trailing: IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onPressed: () => context.go('/users/${lawyer.uid}'),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    if (consultation.assignedLawyerId != null)
                      const SizedBox(height: 16),
                    
                    // Response (if exists)
                    if (consultation.response != null) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الرد',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                consultation.response!,
                                style: textTheme.bodyLarge,
                              ),
                              if (consultation.responseAt != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'تاريخ الرد: ${DateFormat('yyyy-MM-dd HH:mm').format(consultation.responseAt!)}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Attachments
                    if (consultation.attachments.isNotEmpty) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'المرفقات',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...consultation.attachments.map((url) => ListTile(
                                    leading: const Icon(Icons.attach_file),
                                    title: Text(url.split('/').last),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.open_in_new),
                                      onPressed: () => FileViewer.openFile(context, url),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Admin/Lawyer Actions
                    if (canEdit) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الإجراءات',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Assign Lawyer (Admin only, if not assigned)
                              if (isAdmin && consultation.assignedLawyerId == null) ...[
                                StreamBuilder<List<UserModel>>(
                                  stream: _userService.getUsersByRole(UserRole.lawyer),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    final lawyers = snapshot.data ?? [];
                                    
                                    return DropdownButtonFormField<String>(
                                      value: _selectedLawyerId,
                                      decoration: InputDecoration(
                                        labelText: 'اختر محامي',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      items: lawyers.map((lawyer) {
                                        return DropdownMenuItem<String>(
                                          value: lawyer.uid,
                                          child: Text(lawyer.profile.name ?? lawyer.email),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedLawyerId = value;
                                        });
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _isLoading ? null : _assignLawyer,
                                    icon: const Icon(Icons.person_add),
                                    label: const Text('تكليف المحامي'),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              
                              // Update Status
                              DropdownButtonFormField<ConsultationStatus>(
                                value: _selectedStatus ?? consultation.status,
                                decoration: InputDecoration(
                                  labelText: 'تغيير الحالة',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: ConsultationStatus.values.map((status) {
                                  return DropdownMenuItem<ConsultationStatus>(
                                    value: status,
                                    child: Text(_getStatusLabel(status)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedStatus = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading || _selectedStatus == null
                                      ? null
                                      : _updateStatus,
                                  icon: const Icon(Icons.update),
                                  label: const Text('تحديث الحالة'),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Add Response (Lawyer or Admin)
                              if (consultation.assignedLawyerId != null || isAdmin) ...[
                                TextFormField(
                                  controller: _responseController,
                                  decoration: InputDecoration(
                                    labelText: 'الرد على الاستشارة',
                                    hintText: 'أدخل ردك هنا...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  maxLines: 5,
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _isLoading ? null : _submitResponse,
                                    icon: const Icon(Icons.send),
                                    label: const Text('إرسال الرد'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                context.go('/consultations/edit/${widget.consultationId}');
              },
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(ConsultationModel consultation) {
    // This will be loaded asynchronously in the UI
    return consultation.category;
  }

  String _getStatusLabel(ConsultationStatus status) {
    switch (status) {
      case ConsultationStatus.pending:
        return 'معلقة';
      case ConsultationStatus.assigned:
        return 'مُكلفة';
      case ConsultationStatus.inProgress:
        return 'قيد المعالجة';
      case ConsultationStatus.completed:
        return 'مكتملة';
      case ConsultationStatus.cancelled:
        return 'ملغاة';
    }
  }
}

class _StatusChip extends StatelessWidget {
  final ConsultationStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case ConsultationStatus.pending:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        label = 'معلقة';
        break;
      case ConsultationStatus.assigned:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        label = 'مُكلفة';
        break;
      case ConsultationStatus.inProgress:
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade900;
        label = 'قيد المعالجة';
        break;
      case ConsultationStatus.completed:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        label = 'مكتملة';
        break;
      case ConsultationStatus.cancelled:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        label = 'ملغاة';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
