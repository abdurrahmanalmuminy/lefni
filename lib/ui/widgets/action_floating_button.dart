import 'package:flutter/material.dart';
import 'package:lefni/l10n/app_localizations.dart';

class ActionFloatingButton extends StatelessWidget {
  final String labelKey;
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  const ActionFloatingButton({
    super.key,
    required this.labelKey,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (isMobile) {
      return FloatingActionButton(
        onPressed: onPressed,
        tooltip: tooltip ?? _getLabel(context),
        child: Icon(icon),
      );
    }

    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(_getLabel(context)),
      tooltip: tooltip,
    );
  }

  String _getLabel(BuildContext context) {
    // Map label keys to localization keys
    final localizations = AppLocalizations.of(context)!;
    switch (labelKey) {
      case 'createContract':
        return localizations.createContract;
      case 'addCase':
        return localizations.addCase;
      case 'scheduleSession':
        return localizations.sessionSchedule;
      case 'newAppointment':
        return localizations.appointmentScheduling;
      case 'addClient':
        return localizations.addClient;
      case 'uploadDocument':
        return localizations.uploadFiles;
      case 'assignTask':
        return localizations.assignTask;
      case 'createInvoice':
        return localizations.createInvoice;
      case 'addFee':
        return localizations.clientFees;
      case 'issueReceipt':
        return localizations.receiptVouchers;
      case 'recordExpense':
        return localizations.expensesAndPayments;
      case 'addLawyer':
        return localizations.addUser;
      case 'addStudent':
        return localizations.studentRegistration;
      case 'addEngineer':
        return localizations.addUser;
      case 'addAccountant':
        return localizations.addUser;
      case 'addTranslator':
        return localizations.addUser;
      default:
        return labelKey;
    }
  }
}

