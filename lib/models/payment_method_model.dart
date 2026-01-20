import 'package:lefni/l10n/app_localizations.dart';

enum PaymentMethod {
  cash('cash'),
  bankTransfer('bank_transfer'),
  check('check'),
  creditCard('credit_card'),
  onlinePayment('online_payment'),
  other('other');

  final String value;
  const PaymentMethod(this.value);

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentMethod.other,
    );
  }
}

extension PaymentMethodLocalization on PaymentMethod {
  String localized(AppLocalizations localizations) {
    switch (this) {
      case PaymentMethod.cash:
        return localizations.paymentMethodCash;
      case PaymentMethod.bankTransfer:
        return localizations.paymentMethodBankTransfer;
      case PaymentMethod.check:
        return localizations.paymentMethodCheck;
      case PaymentMethod.creditCard:
        return localizations.paymentMethodCreditCard;
      case PaymentMethod.onlinePayment:
        return localizations.paymentMethodOnlinePayment;
      case PaymentMethod.other:
        return localizations.paymentMethodOther;
    }
  }
}

