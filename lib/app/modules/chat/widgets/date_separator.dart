import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSeparator extends StatelessWidget {
  final DateTime date;

  const DateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _formatDate(context, date),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    final labels = {
      'fr': {'today': 'Aujourd’hui', 'yesterday': 'Hier'},
      'en': {'today': 'Today', 'yesterday': 'Yesterday'},
      'ru': {'today': 'Сегодня', 'yesterday': 'Вчера'},
    };

    if (messageDate == today) return labels[locale]?['today'] ?? 'Today';
    if (messageDate == yesterday)
      return labels[locale]?['yesterday'] ?? 'Yesterday';

    return DateFormat('dd MMM yyyy', locale).format(date);
  }
}
