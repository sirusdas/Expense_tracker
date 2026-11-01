import 'package:flutter/material.dart';

class BankCardStyle {
  final String bankName;
  final List<Color> gradientColors;
  final Color accentColor;
  final IconData icon;

  const BankCardStyle({
    required this.bankName,
    required this.gradientColors,
    required this.accentColor,
    required this.icon,
  });
}

class CardUiHelper {
  static BankCardStyle getCardStyle(String? bankOrCard) {
    final upper = (bankOrCard ?? '').toUpperCase();

    if (upper.contains('HDFC')) {
      return const BankCardStyle(
        bankName: 'HDFC Bank',
        gradientColors: [Color(0xFF002D62), Color(0xFF0056B3)],
        accentColor: Color(0xFF60A5FA),
        icon: Icons.account_balance_rounded,
      );
    } else if (upper.contains('SBI')) {
      return const BankCardStyle(
        bankName: 'State Bank of India',
        gradientColors: [Color(0xFF003865), Color(0xFF0072B5)],
        accentColor: Color(0xFF38BDF8),
        icon: Icons.account_balance_rounded,
      );
    } else if (upper.contains('ICICI')) {
      return const BankCardStyle(
        bankName: 'ICICI Bank',
        gradientColors: [Color(0xFF8B2500), Color(0xFFD9531E)],
        accentColor: Color(0xFFFB923C),
        icon: Icons.account_balance_rounded,
      );
    } else if (upper.contains('AXIS')) {
      return const BankCardStyle(
        bankName: 'Axis Bank',
        gradientColors: [Color(0xFF800032), Color(0xFFA8124C)],
        accentColor: Color(0xFFF472B6),
        icon: Icons.account_balance_rounded,
      );
    } else if (upper.contains('KOTAK')) {
      return const BankCardStyle(
        bankName: 'Kotak Bank',
        gradientColors: [Color(0xFFB3141C), Color(0xFFDC2626)],
        accentColor: Color(0xFFF87171),
        icon: Icons.account_balance_rounded,
      );
    } else if (upper.contains('AMEX')) {
      return const BankCardStyle(
        bankName: 'American Express',
        gradientColors: [Color(0xFF005A87), Color(0xFF0082BA)],
        accentColor: Color(0xFF67E8F9),
        icon: Icons.credit_card_rounded,
      );
    } else if (upper.contains('ONECARD')) {
      return const BankCardStyle(
        bankName: 'OneCard',
        gradientColors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        accentColor: Color(0xFFFBBF24),
        icon: Icons.credit_score_rounded,
      );
    } else if (upper.contains('BOB') || upper.contains('BARODA')) {
      return const BankCardStyle(
        bankName: 'Bank of Baroda',
        gradientColors: [Color(0xFFC04000), Color(0xFFEA580C)],
        accentColor: Color(0xFFFDBA74),
        icon: Icons.account_balance_rounded,
      );
    } else if (upper.contains('PNB')) {
      return const BankCardStyle(
        bankName: 'Punjab National Bank',
        gradientColors: [Color(0xFF7A1528), Color(0xFF9E1C38)],
        accentColor: Color(0xFFFDA4AF),
        icon: Icons.account_balance_rounded,
      );
    } else if (upper.contains('RBL')) {
      return const BankCardStyle(
        bankName: 'RBL Bank',
        gradientColors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
        accentColor: Color(0xFF93C5FD),
        icon: Icons.account_balance_rounded,
      );
    } else if (upper.contains('IDFC')) {
      return const BankCardStyle(
        bankName: 'IDFC FIRST Bank',
        gradientColors: [Color(0xFF831843), Color(0xFF9D174D)],
        accentColor: Color(0xFFF472B6),
        icon: Icons.account_balance_rounded,
      );
    }

    return const BankCardStyle(
      bankName: 'Card',
      gradientColors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
      accentColor: Color(0xFF60A5FA),
      icon: Icons.credit_card_rounded,
    );
  }

  /// Formats clean masked card display string, e.g. "•••• 1234"
  static String formatMaskedCardNumber(String lastDigits) {
    if (lastDigits.isEmpty) return '•••• ••••';
    return '•••• $lastDigits';
  }
}
