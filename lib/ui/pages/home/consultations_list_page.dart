import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lefni/models/consultation_model.dart';
import 'package:lefni/models/user_model.dart';
import 'package:lefni/services/firestore/consultation_service.dart';
import 'package:lefni/services/firestore/client_service.dart';
import 'package:lefni/services/firestore/user_service.dart';
import 'package:lefni/services/court_classifications_service.dart';
import 'package:lefni/ui/widgets/search_app_bar.dart';
import 'package:lefni/providers/user_session_provider.dart';
import 'package:lefni/utils/permissions_helper.dart';
import 'package:lefni/ui/widgets/action_floating_button.dart';
import 'package:lefni/ui/widgets/forms/create_consultation_form.dart';
import 'package:lefni/providers/user_session_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ConsultationsListPage extends StatefulWidget {
  const ConsultationsListPage({super.key});

  @override
  State<ConsultationsListPage> createState() => _ConsultationsListPageState();
}

class _ConsultationsListPageState extends State<ConsultationsListPage> {
  final TextEditingController _searchController = TextEditingController();
  ConsultationStatus? _statusFilter;
  final _consultationService = ConsultationService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final userSession = Provider.of<UserSessionProvider>(context, listen: false);
    final isClient = userSession.userRole == UserRole.client;
    final userId = userSession.firebaseUser?.uid;

    return Scaffold(
      appBar: SearchAppBar(
        title: 'الاستشارات',
        searchHint: 'بحث في الاستشارات...',
        searchController: _searchController,
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterChip(
                  label: const Text('الكل'),
                  selected: _statusFilter == null,
                  onSelected: (selected) {
                    setState(() {
                      _statusFilter = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('معلقة'),
                  selected: _statusFilter == ConsultationStatus.pending,
                  onSelected: (selected) {
                    setState(() {
                      _statusFilter = ConsultationStatus.pending;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('مُكلفة'),
                  selected: _statusFilter == ConsultationStatus.assigned,
                  onSelected: (selected) {
                    setState(() {
                      _statusFilter = ConsultationStatus.assigned;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('قيد المعالجة'),
                  selected: _statusFilter == ConsultationStatus.inProgress,
                  onSelected: (selected) {
                    setState(() {
                      _statusFilter = ConsultationStatus.inProgress;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('مكتملة'),
                  selected: _statusFilter == ConsultationStatus.completed,
                  onSelected: (selected) {
                    setState(() {
                      _statusFilter = ConsultationStatus.completed;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: userId == null
                ? const Center(child: Text('يرجى تسجيل الدخول'))
                : StreamBuilder<List<ConsultationModel>>(
                    stream: isClient
                        ? _consultationService.getConsultationsByClient(userId)
                        : _consultationService.getAllConsultations(
                            status: _statusFilter,
                          ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('خطأ: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'لا توجد استشارات',
                            style: textTheme.bodyLarge,
                          ),
                        );
                      }

                      var consultations = snapshot.data!;
                      if (_searchController.text.isNotEmpty) {
                        consultations = consultations.where((c) {
                          return c.description
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase());
                        }).toList();
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: consultations.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return _ConsultationListTile(
                            consultation: consultations[index],
                            onTap: () {
                              context.go('/consultations/${consultations[index].id}');
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: isClient
          ? Consumer<UserSessionProvider>(
              builder: (context, userSession, child) {
                // Clients can always create consultations (they're active after onboarding)
                // For lawyers, check write permission
                final canWrite = isClient || PermissionsHelper.canWrite(userSession);
                return ActionFloatingButton(
                  labelKey: 'consultation',
                  icon: Icons.chat_bubble_outline,
                  enabled: canWrite,
                  onPressed: canWrite ? () {
                    showDialog(
                      context: context,
                      builder: (context) => const CreateConsultationForm(),
                    );
                  } : null,
                );
              },
            )
          : Consumer<UserSessionProvider>(
              builder: (context, userSession, child) {
                final canWrite = PermissionsHelper.canWrite(userSession);
                return ActionFloatingButton(
                  labelKey: 'consultation',
                  icon: Icons.chat_bubble_outline,
                  enabled: canWrite,
                  onPressed: canWrite ? () {
                    showDialog(
                      context: context,
                      builder: (context) => const CreateConsultationForm(),
                    );
                  } : null,
                );
              },
            ),
    );
  }
}

class _ConsultationListTile extends StatelessWidget {
  final ConsultationModel consultation;
  final VoidCallback onTap;

  const _ConsultationListTile({
    required this.consultation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<Map<String, String>>(
                          future: _getCategoryName(),
                          builder: (context, snapshot) {
                            final categoryName = snapshot.data?['ar'] ?? consultation.category;
                            return Text(
                              categoryName,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        if (consultation.caseType != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            consultation.caseType!['ar'] as String? ?? '',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _StatusChip(status: consultation.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                consultation.description,
                style: textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  FutureBuilder<String>(
                    future: _getClientName(),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? consultation.clientId,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  if (consultation.assignedLawyerId != null) ...[
                    Icon(Icons.gavel, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    FutureBuilder<String>(
                      future: _getLawyerName(),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? consultation.assignedLawyerId!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                  ],
                  Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('yyyy-MM-dd').format(consultation.createdAt),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, String>> _getCategoryName() async {
    final ar = await CourtClassificationsService.getCategoryNameAr(consultation.category);
    final en = await CourtClassificationsService.getCategoryNameEn(consultation.category);
    return {'ar': ar, 'en': en};
  }

  Future<String> _getClientName() async {
    try {
      final client = await ClientService().getClient(consultation.clientId);
      return client?.name ?? consultation.clientId;
    } catch (e) {
      return consultation.clientId;
    }
  }

  Future<String> _getLawyerName() async {
    if (consultation.assignedLawyerId == null) return '';
    try {
      final user = await UserService().getUser(consultation.assignedLawyerId!);
      return user?.profile.name ?? user?.email ?? consultation.assignedLawyerId!;
    } catch (e) {
      return consultation.assignedLawyerId!;
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
