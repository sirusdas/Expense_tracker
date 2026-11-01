import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/payment.dart';

class ExcelExportService {
  static const MethodChannel _channel = MethodChannel('com.allwin.expensetracker/export');

  /// Formats all payments into clean RFC 4180 CSV with UTF-8 BOM for Microsoft Excel
  static String generateCsv(List<Payment> payments) {
    final buffer = StringBuffer();
    // Prepend UTF-8 Byte Order Mark so Excel opens with proper character encoding (rupee symbols, etc.)
    buffer.write('\uFEFF');

    // CSV Header row
    buffer.writeln(
      'Transaction ID,Date,Time,Type,Amount (INR),Category,Description,Payment Mode,Account / Card,Notes / Ref,Excluded from Budget,Raw SMS'
    );

    for (final p in payments) {
      final dateStr = DateFormat('yyyy-MM-dd').format(p.date);
      final timeStr = DateFormat('HH:mm:ss').format(p.date);
      final typeStr = p.type == TransactionType.debit ? 'Expense' : 'Income';
      final modeStr = p.paymentMode.name.toUpperCase();
      final excluded = p.isExcludedFromBudget ? 'Yes' : 'No';

      buffer.writeln([
        p.id?.toString() ?? '',
        dateStr,
        timeStr,
        typeStr,
        p.amount.toStringAsFixed(2),
        _escapeCsv(p.category),
        _escapeCsv(p.description),
        modeStr,
        _escapeCsv(p.accountReference ?? ''),
        _escapeCsv(p.notes ?? ''),
        excluded,
        _escapeCsv(p.rawMessage ?? ''),
      ].join(','));
    }

    return buffer.toString();
  }

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n') || value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Exports payments to Excel CSV and prompts download/save/open via Android
  static Future<bool> exportAndDownload(List<Payment> payments, {String? customFileName}) async {
    if (payments.isEmpty) return false;

    final csvContent = generateCsv(payments);
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = customFileName ?? 'Expense_Tracker_$timestamp.csv';

    try {
      final result = await _channel.invokeMethod<bool>('exportToExcel', {
        'fileName': fileName,
        'content': csvContent,
        'title': 'Download / Open in Excel',
      });
      return result ?? true;
    } catch (e) {
      debugPrint('Export error: $e');
      return false;
    }
  }
}
