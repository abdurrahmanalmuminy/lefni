import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lefni/models/appointment_model.dart';
import 'package:lefni/services/firestore/appointment_service.dart';
import 'package:lefni/services/firestore/client_service.dart';
import 'package:lefni/services/firestore/user_service.dart';
import 'package:lefni/ui/widgets/entity_header.dart';
import 'package:uicons/uicons.dart';
import 'package:intl/intl.dart';

class AppointmentDetailPage extends StatelessWidget {
  final String appointmentId;

  const AppointmentDetailPage({
    super.key,
    required this.appointmentId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: FutureBuilder<AppointmentModel?>(
        future: AppointmentService().getAppointment(appointmentId),
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

          final appointment = snapshot.data;
          if (appointment == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'الموعد غير موجود',
                    style: textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: EntityHeader(
                  title: appointment.purpose,
                  subtitle: DateFormat('yyyy-MM-dd HH:mm').format(appointment.dateTime),
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      UIcons.regularRounded.calendar_check,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  actions: [
                    Chip(
                      label: Text(_getStatusLabel(appointment.status)),
                      backgroundColor: _getStatusColor(context, appointment.status),
                    ),
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
                              'المعلومات الأساسية',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              context,
                              'الغرض',
                              appointment.purpose,
                            ),
                            _buildInfoRow(
                              context,
                              'التاريخ والوقت',
                              DateFormat('yyyy-MM-dd HH:mm').format(appointment.dateTime),
                            ),
                            _buildInfoRow(
                              context,
                              'الحالة',
                              _getStatusLabel(appointment.status),
                            ),
                            _buildInfoRow(
                              context,
                              'تاريخ الإنشاء',
                              DateFormat('yyyy-MM-dd').format(appointment.createdAt),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Related Entities
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الكيانات المرتبطة',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FutureBuilder(
                              future: ClientService().getClient(appointment.clientId),
                              builder: (context, clientSnapshot) {
                                if (clientSnapshot.hasData && clientSnapshot.data != null) {
                                  final client = clientSnapshot.data!;
                                  return InkWell(
                                    onTap: () => context.go('/clients/${client.id}'),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            UIcons.regularRounded.user,
                                            size: 20,
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'العميل',
                                                  style: textTheme.bodySmall?.copyWith(
                                                    color: colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                                Text(
                                                  client.name,
                                                  style: textTheme.bodyMedium?.copyWith(
                                                    color: colorScheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            UIcons.regularRounded.arrow_left,
                                            size: 16,
                                            color: colorScheme.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return _buildInfoRow(context, 'العميل', appointment.clientId);
                              },
                            ),
                            FutureBuilder(
                              future: UserService().getUser(appointment.createdBy),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.hasData && userSnapshot.data != null) {
                                  final user = userSnapshot.data!;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.person_add,
                                          size: 20,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'أنشئ بواسطة',
                                                style: textTheme.bodySmall?.copyWith(
                                                  color: colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                              Text(
                                                user.profile.name ?? user.email,
                                                style: textTheme.bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return _buildInfoRow(context, 'أنشئ بواسطة', appointment.createdBy);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Reminder Information
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'معلومات التذكير',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              context,
                              'تم إرسال التذكير',
                              appointment.smsReminderSent ? 'نعم' : 'لا',
                            ),
                            if (appointment.reminderSentAt != null)
                              _buildInfoRow(
                                context,
                                'تاريخ الإرسال',
                                DateFormat('yyyy-MM-dd HH:mm').format(appointment.reminderSentAt!),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/appointments/edit/$appointmentId');
        },
        child: const Icon(Icons.edit),
      ),
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

  String _getStatusLabel(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'مجدولة';
      case AppointmentStatus.cancelled:
        return 'ملغاة';
      case AppointmentStatus.done:
        return 'منتهية';
    }
  }

  Color _getStatusColor(BuildContext context, AppointmentStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case AppointmentStatus.scheduled:
        return colorScheme.primaryContainer;
      case AppointmentStatus.cancelled:
        return colorScheme.errorContainer;
      case AppointmentStatus.done:
        return colorScheme.tertiaryContainer;
    }
  }
}

