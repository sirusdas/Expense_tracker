import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/parser/message_parser_pipeline.dart';
import 'package:expense_tracker/models/payment.dart';

void main() {
  group('Card Payment vs Account Income Filtering Tests', () {
    final parser = MessageParserPipeline.instance;

    test('Payment received towards Credit Card is Expense (Debit), not Income', () {
      const sms = 'Payment of Rs. 12,500.00 received towards your HDFC Bank Credit Card ending 9876 on 01-Nov-2026. Avl Limit: Rs. 1,50,000.00';
      final res = parser.parse(sms);

      expect(res.isSuccess, isTrue);
      expect(res.payment?.amount, 12500.0);
      expect(res.payment?.type, TransactionType.debit, reason: 'Payment to a card must be treated as Expense (bill repayment), not income');
      expect(res.payment?.paymentMode, PaymentMode.card);
      expect(res.payment?.accountReference, 'HDFC Card 9876');
      expect(res.payment?.category, 'Bills & Utilities');
    });

    test('Credited to Credit Card towards outstanding bill is Expense (Debit), not Income', () {
      const sms = 'Dear Customer, Rs 15,000 credited to your SBI Credit Card XX4455 towards outstanding payment on 01/11/2026.';
      final res = parser.parse(sms);

      expect(res.isSuccess, isTrue);
      expect(res.payment?.amount, 15000.0);
      expect(res.payment?.type, TransactionType.debit, reason: 'Credit card bill payment cannot be income');
      expect(res.payment?.paymentMode, PaymentMode.card);
      expect(res.payment?.accountReference, 'SBI Card XX4455');
    });

    test('Thank you for payment towards Card is Expense (Debit)', () {
      const sms = 'Thank you for your payment of Rs 5,400 towards Axis Bank Credit Card ending 1234 on 01-Nov-26.';
      final res = parser.parse(sms);

      expect(res.isSuccess, isTrue);
      expect(res.payment?.amount, 5400.0);
      expect(res.payment?.type, TransactionType.debit);
      expect(res.payment?.paymentMode, PaymentMode.card);
    });

    test('Salary credited to Bank Account remains genuine Income', () {
      const sms = 'Your HDFC Bank A/c XX1234 is credited with Rs 75,000.00 on 01-Nov-2026 by Salary Payroll. Avl Bal Rs 82,450.00';
      final res = parser.parse(sms);

      expect(res.isSuccess, isTrue);
      expect(res.payment?.amount, 75000.0);
      expect(res.payment?.type, TransactionType.credit, reason: 'Bank account deposits must remain genuine Income');
      expect(res.payment?.accountReference, 'HDFC A/c XX1234');
      expect(res.payment?.category, 'Salary');
    });

    test('Refund credited to Credit Card remains Refund Credit', () {
      const sms = 'ICICI Bank: Refund of INR 899.00 credited to Credit Card XX7788 by FLIPKART on 01-Nov-26.';
      final res = parser.parse(sms);

      expect(res.isSuccess, isTrue);
      expect(res.payment?.amount, 899.0);
      expect(res.payment?.type, TransactionType.credit, reason: 'Refunds must remain credits');
      expect(res.payment?.category, 'Refund');
      expect(res.payment?.accountReference, 'ICICI Card XX7788');
    });

    test('HDFC Bank Cardmember Online Payment credited to card is Expense', () {
      const sms = 'HDFC Bank Cardmember, Online Payment of Rs.14951 vide Ref# 275064009GziCze was credited to your card ending 0321 On 02/OCT/2026_value Date 02/OCT/2026.';
      final res = parser.parse(sms);

      expect(res.isSuccess, isTrue);
      expect(res.payment?.amount, 14951.0);
      expect(res.payment?.type, TransactionType.debit, reason: 'Card payment credited to card is Expense, not income');
      expect(res.payment?.paymentMode, PaymentMode.card);
      expect(res.payment?.accountReference, 'HDFC Card 0321');
    });
  });
}
