import 'package:flutter/material.dart';

import '../../domain/models/clarification_question.dart';

class ClarificationCard extends StatelessWidget {
  const ClarificationCard({
    required this.question,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final ClarificationQuestion question;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (question.options != null && question.options!.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: question.options!.map((option) {
                  return ChoiceChip(
                    label: Text(option),
                    selected: value == option,
                    onSelected: (_) => onChanged(option),
                  );
                }).toList(),
              )
            else
              TextField(
                controller: TextEditingController(text: value)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: value.length),
                  ),
                onChanged: onChanged,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
          ],
        ),
      ),
    );
  }
}
