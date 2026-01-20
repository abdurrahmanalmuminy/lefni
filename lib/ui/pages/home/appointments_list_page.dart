import 'package:flutter/material.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/services/firestore/session_service.dart';
import 'package:lefni/models/session_model.dart';
import 'package:lefni/ui/widgets/search_app_bar.dart';
import 'package:lefni/ui/widgets/action_floating_button.dart';
import 'package:lefni/ui/widgets/list_tiles/session_list_tile.dart';
import 'package:lefni/ui/widgets/forms/create_appointment_form.dart';
import 'package:uicons/uicons.dart';

class AppointmentsListPage extends StatelessWidget {
  const AppointmentsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: SearchAppBar(
        title: localizations.appointments,
        searchHint: 'بحث في المواعيد...',
      ),
      body: StreamBuilder(
              stream: SessionService().getUpcomingSessions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
                  return Center(child: Text('خطأ: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد مواعيد',
                      style: textTheme.bodyLarge,
                    ),
                  );
                }

                final appointments = snapshot.data!
                    .where((s) => s.type == SessionType.consultation)
                    .toList();

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: appointments.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return SessionListTile(session: appointments[index]);
                  },
                );
              },
            ),
      floatingActionButton: ActionFloatingButton(
        labelKey: 'newAppointment',
        icon: UIcons.regularRounded.plus,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CreateAppointmentForm(),
          );
        },
      ),
    );
  }
}

