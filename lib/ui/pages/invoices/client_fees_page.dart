import 'package:flutter/material.dart';
import 'package:lefni/services/firestore/finance_service.dart';
import 'package:lefni/models/finance_model.dart';
import 'package:lefni/ui/widgets/search_app_bar.dart';
import 'package:lefni/ui/widgets/list_tiles/finance_list_tile.dart';

class ClientFeesPage extends StatelessWidget {
  const ClientFeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: SearchAppBar(
        title: 'أتعاب العملاء',
        searchHint: 'بحث في الأتعاب...',
      ),
      body: StreamBuilder(
        stream: FinanceService().getFinancesByType(FinanceType.fee),
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
                'لا توجد أتعاب',
                style: textTheme.bodyLarge,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: snapshot.data!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return FinanceListTile(finance: snapshot.data![index]);
            },
          );
        },
      ),
    );
  }
}

