import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lefni/models/user_model.dart';
import 'package:lefni/services/firestore/user_service.dart';
import 'package:lefni/ui/widgets/entity_header.dart';
import 'package:uicons/uicons.dart';
import 'package:intl/intl.dart';

class UserDetailPage extends StatelessWidget {
  final String userId;

  const UserDetailPage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: FutureBuilder<UserModel?>(
        future: UserService().getUser(userId),
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

          final user = snapshot.data;
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'المستخدم غير موجود',
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
                  title: user.profile.name ?? user.email,
                  subtitle: _getRoleLabel(user.role),
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      UIcons.regularRounded.user,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  actions: [
                    Chip(
                      label: Text(user.isActive ? 'نشط' : 'غير نشط'),
                      backgroundColor: user.isActive
                          ? colorScheme.tertiaryContainer
                          : colorScheme.errorContainer,
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
                              'البريد الإلكتروني',
                              user.email,
                            ),
                            if (user.phoneNumber != null)
                              _buildInfoRow(
                                context,
                                'رقم الهاتف',
                                user.phoneNumber!,
                              ),
                            _buildInfoRow(
                              context,
                              'الدور',
                              _getRoleLabel(user.role),
                            ),
                            _buildInfoRow(
                              context,
                              'الحالة',
                              user.isActive ? 'نشط' : 'غير نشط',
                            ),
                            _buildInfoRow(
                              context,
                              'تاريخ الإنشاء',
                              DateFormat('yyyy-MM-dd').format(user.createdAt),
                            ),
                            if (user.lastLogin != null)
                              _buildInfoRow(
                                context,
                                'آخر تسجيل دخول',
                                DateFormat('yyyy-MM-dd HH:mm').format(user.lastLogin!),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Profile Information
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'معلومات الملف الشخصي',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (user.profile.name != null)
                              _buildInfoRow(
                                context,
                                'الاسم',
                                user.profile.name!,
                              ),
                            // Role-specific fields
                            ..._buildRoleSpecificFields(context, user),
                          ],
                        ),
                      ),
                    ),
                    if (user.permissions.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      // Permissions
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الصلاحيات',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: user.permissions.map((permission) => Chip(
                                      label: Text(permission),
                                      backgroundColor: colorScheme.surfaceContainerHighest,
                                    )).toList(),
                              ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/users/edit/$userId');
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

  List<Widget> _buildRoleSpecificFields(BuildContext context, UserModel user) {
    final fields = <Widget>[];

    switch (user.role) {
      case UserRole.lawyer:
        if (user.profile.specialization != null) {
          fields.add(_buildInfoRow(context, 'التخصص', user.profile.specialization!));
        }
        break;

      case UserRole.student:
        if (user.profile.university != null) {
          fields.add(_buildInfoRow(context, 'الجامعة', user.profile.university!));
        }
        if (user.profile.isTraining != null) {
          fields.add(_buildInfoRow(
            context,
            'حالة التدريب',
            user.profile.isTraining! ? 'قيد التدريب' : 'منتهي',
          ));
        }
        if (user.profile.cooperationType != null) {
          fields.add(_buildInfoRow(
            context,
            'نوع التعاون',
            user.profile.cooperationType == CooperationType.training
                ? 'تدريب'
                : 'مصدر قضايا',
          ));
        }
        if (user.profile.bankAccount != null) {
          fields.add(_buildInfoRow(context, 'الحساب البنكي', user.profile.bankAccount!));
        }
        if (user.profile.cvUrl != null) {
          fields.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: InkWell(
                onTap: () {
                  // TODO: Open CV
                },
                child: Row(
                  children: [
                    Icon(
                      UIcons.regularRounded.file,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'عرض السيرة الذاتية',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        break;

      case UserRole.engineer:
      case UserRole.accountant:
        if (user.profile.licenseNumber != null) {
          fields.add(_buildInfoRow(context, 'رقم الترخيص', user.profile.licenseNumber!));
        }
        if (user.profile.firmName != null) {
          fields.add(_buildInfoRow(context, 'اسم الشركة', user.profile.firmName!));
        }
        break;

      default:
        break;
    }

    return fields;
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'مدير';
      case UserRole.lawyer:
        return 'محامي';
      case UserRole.student:
        return 'طالب';
      case UserRole.engineer:
        return 'مهندس';
      case UserRole.accountant:
        return 'محاسب';
      case UserRole.translator:
        return 'مترجم';
      case UserRole.client:
        return 'عميل';
    }
  }
}

